import Foundation
import SwiftUI
import Combine
import AVFoundation

protocol MainCameraViewModel: ObservableObject {
    var session: AVCaptureSession { get }
    var isPresented: Bool { get }
    var expirationType: Expiration { get set }
    func presentSheet()
    func onAppear()
    func onDisappear()
    func viewdidLoad()
    func onTakePhoto()
    func onTapAlbumButton()
    func onPinchChanged(scale: CGFloat)
    func onPinchEnded()
    func zoomIn()
    func zoomOut()
    func fetchLastPhoto() -> URL?
}

final class MainCameraViewModelImpl: MainCameraViewModel {
    @Published var expirationType: Expiration = .day {
        didSet {
            print("選択肢が変更されました: \(expirationType.rawValue)")
        }
    }
    @Published var isPresented: Bool = false
    private let service: CameraService
    private var photoUseCase: PhotoUseCase
    private var bag = Set<AnyCancellable>()
    private var lastScale: CGFloat = 1.0
    private let zoomStep: CGFloat = 0.5
    private let maxZoom: CGFloat = 5.0
    private let pinchThreshold: CGFloat = 0.0
    var session: AVCaptureSession{
        service.session
    }
    private weak var coordinator: AppCoordinator?
    init(
        service: CameraService,
        coordinator: AppCoordinator,
        photoUseCase: photoUseCaseImpl
    ) {
        self.service = service
        self.coordinator = coordinator
        self.photoUseCase = photoUseCase
        service.photoPublisher
            .compactMap { UIImage(data: $0) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.objectWillChange.send()
                if let expiration = self?.expirationType {
                    self?.storePhoto(expiration: expiration, image: image)
                }
            }
            .store(in: &bag)
    }
    
    func onAppear() {
        //TODO: カメラセッションの起動や権限の確認
        Task {
            await service.configure()
            service.startRunning()
        }
    }
    
    func onDisappear() {
        service.stopRunning()
    }
    
    func presentSheet() {
        isPresented = true
    }
    
    func viewdidLoad() {
        makeDirectories()
    }
    
    func onPinchChanged(scale: CGFloat) {
        let delta = scale / lastScale
        if delta > 1 + pinchThreshold {
            zoomIn()
            lastScale = scale
        } else if delta < 1 - pinchThreshold {
            zoomOut()
            lastScale = scale
        }
    }
    func onPinchEnded() {
        lastScale = 1.0
    }
    
    func zoomIn() {
        changeZoom(by: zoomStep)
    }
    
    func zoomOut() {
        changeZoom(by: -zoomStep)
    }
    
    func onTakePhoto() {
        service.capturePhoto()
    }
    
    func onTapAlbumButton() {
        coordinator?.present(.album)
    }
    
}
extension MainCameraViewModelImpl {
    
    func storePhoto(expiration: Expiration, image: UIImage) {
        let saveUrl = makeUrl(expiration: expiration)
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        photoUseCase.savePhoto(data: imageData,url: saveUrl)
    }
    
    func fetchLastPhoto() -> URL? {
        let photoUrls =  self.photoUseCase.fetch()
        return photoUrls.first
    }
    
    private func makeUrl(expiration: Expiration) -> URL {
        let formatter = DateFormatter()
        formatter.calendar = .init(identifier: .gregorian)
        formatter.timeZone = .current
        formatter.locale = .current
        formatter.dateFormat = "yyyyMMddHHmmss"
        
        let timestamp = formatter.string(from: Date())
        let filename = "\(expiration.rawValue)/\(timestamp).jpg"
        
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory,
                                                          in: .userDomainMask).first else {
            fatalError("ドキュメントディレクトリのURL取得に失敗しました")
        }
        return documentsURL.appendingPathComponent(filename)
    }
    
    private func makeDirectories() {
        guard let docURL = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first else {
            fatalError("ドキュメントディレクトリのURL取得に失敗")
        }
        
        let subfolders = ["day", "week", "month", "year"]
        let fileManager = FileManager.default
        
        for name in subfolders {
            let dirURL = docURL.appendingPathComponent(name)
            if !fileManager.fileExists(atPath: dirURL.path) {
                do {
                    try fileManager.createDirectory(at: dirURL,
                                                    withIntermediateDirectories: false)
                } catch {
                    print("ディレクトリ作成に失敗: \(name), error: \(error)")
                }
            }
        }
    }
    
    private func changeZoom(by: CGFloat) {
        guard let deviceInput = session.inputs.first as? AVCaptureDeviceInput else {
            print("Failed to get AVCaptureDeviceInput")
            return
        }
        let device = deviceInput.device
        
        do {
            try device.lockForConfiguration()
            var newFactor = device.videoZoomFactor + by
            
            let minFactor: CGFloat = 1.0
            let maxFactor = min(device.activeFormat.videoMaxZoomFactor, maxZoom)
            newFactor = max(minFactor, min(newFactor, maxFactor))
            
            device.ramp(toVideoZoomFactor: newFactor, withRate: 5.0)
            device.unlockForConfiguration()
        } catch {
            print("Failed to change zoom: \(error)")
        }
    }
}

