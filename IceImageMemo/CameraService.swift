import UIKit
import SwiftUI
import Combine
import AVFoundation

protocol CameraService {
    var session: AVCaptureSession { get }
    var photoPublisher: AnyPublisher<Data, Never> { get }
    func configure() async
    func startRunning()
    func stopRunning()
    func capturePhoto()
}

final class CameraServiceImpl: NSObject, CameraService {
    var session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var deviceInput: AVCaptureDeviceInput?
    private let photoOutput = AVCapturePhotoOutput()
    private let photoSubject = PassthroughSubject<Data, Never>()
    var photoPublisher: AnyPublisher<Data, Never> {
        photoSubject.eraseToAnyPublisher()
    }
    
    func checkAuthorization() -> AVAuthorizationStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        return status
    }
    
    func configure() async {
        let status = checkAuthorization()
        if status == .notDetermined {
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            guard granted else { return }
        }
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else { return }
        
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        if let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                    self.deviceInput = input
                }
            } catch {
                print("Input error:", error)
            }
        }
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        session.commitConfiguration()
    }
    
    func startRunning() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func stopRunning() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraServiceImpl: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error {
            print("Photo capture error: \(error)")
            return
        }
        if let data = photo.fileDataRepresentation() {
            photoSubject.send(data)
        }
    }
}

final class CameraPreviewContainerView: UIView {
    private let previewLayer: AVCaptureVideoPreviewLayer
    init(session: AVCaptureSession) {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        super.init(frame: .zero)
        backgroundColor = .black
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
        if let conn = previewLayer.connection, conn.isVideoOrientationSupported {
            conn.videoOrientation = .portrait
        }
    }
}

struct CameraServiceView: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> CameraPreviewContainerView {
        CameraPreviewContainerView(session: session)
    }
    func updateUIView(_ uiView: CameraPreviewContainerView, context: Context) {}
}
