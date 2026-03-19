import AVFoundation
import Combine
import SwiftUI
import UIKit

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
        AVCaptureDevice.authorizationStatus(for: .video)
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

        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInTripleCamera,
            .builtInDualWideCamera,
            .builtInDualCamera,
            .builtInWideAngleCamera,
        ]

        let mediaType: AVMediaType = .video

        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: mediaType,
            position: .back
        )

        let devices = discovery.devices

        if let device =
            devices.first(where: { $0.deviceType == .builtInTripleCamera }) ??
            devices.first(where: { $0.deviceType == .builtInDualWideCamera }) ??
            devices.first(where: { $0.deviceType == .builtInDualCamera }) ??
            devices.first(where: { $0.deviceType == .builtInWideAngleCamera }) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                    deviceInput = input

                    try device.lockForConfiguration()
                    if let switchOverFactor = device.virtualDeviceSwitchOverVideoZoomFactors.first {
                        device.videoZoomFactor = CGFloat(switchOverFactor.floatValue)
                    } else {
                        device.videoZoomFactor = 1.0
                    }
                    device.unlockForConfiguration()
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
    func photoOutput(_: AVCapturePhotoOutput,
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
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        super.init(frame: .zero)
        backgroundColor = .black
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
        guard let connection = previewLayer.connection else { return }
        connection.videoRotationAngle = 90
    }
}

struct CameraServiceView: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context _: Context) -> CameraPreviewContainerView {
        CameraPreviewContainerView(session: session)
    }

    func updateUIView(_: CameraPreviewContainerView, context _: Context) {}
}
