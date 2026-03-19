import CoreImage
import UIKit
import Vision

protocol DocumentCropService {
    func detectAndCrop(from image: UIImage) async -> UIImage?
}

struct DocumentCropServiceImpl: DocumentCropService {
    func detectAndCrop(from image: UIImage) async -> UIImage? {
        await Task.detached(priority: .userInitiated) {
            guard let cgImage = image.cgImage else { return nil }

            let request = VNDetectRectanglesRequest()
            request.maximumObservations = 1
            request.minimumConfidence = 0.8
            request.minimumAspectRatio = 0.3

            let orientation = CGImagePropertyOrientation(image.imageOrientation)
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            do {
                try handler.perform([request])
            } catch {
                return nil
            }

            guard let observation = (request.results as? [VNRectangleObservation])?.first else {
                return nil
            }

            return Self.applyPerspectiveCorrection(cgImage: cgImage, observation: observation)
        }.value
    }

    private static func applyPerspectiveCorrection(
        cgImage: CGImage,
        observation: VNRectangleObservation
    ) -> UIImage? {
        let ciImage = CIImage(cgImage: cgImage)
        let w = CGFloat(cgImage.width)
        let h = CGFloat(cgImage.height)

        // Vision 正規化座標（左下原点）→ CIImage ピクセル座標（左下原点）
        func toCI(_ p: CGPoint) -> CIVector {
            CIVector(x: p.x * w, y: p.y * h)
        }

        guard let filter = CIFilter(name: "CIPerspectiveCorrection") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(toCI(observation.topLeft), forKey: "inputTopLeft")
        filter.setValue(toCI(observation.topRight), forKey: "inputTopRight")
        filter.setValue(toCI(observation.bottomLeft), forKey: "inputBottomLeft")
        filter.setValue(toCI(observation.bottomRight), forKey: "inputBottomRight")

        guard let outputImage = filter.outputImage else { return nil }

        let context = CIContext(options: [.useSoftwareRenderer: false])
        guard let cgOutput = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgOutput)
    }
}

// MARK: - UIImageOrientation → CGImagePropertyOrientation

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
