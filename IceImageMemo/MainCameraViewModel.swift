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
    
    func zoomIn() {
        //TODO: 拡大
    }
    
    func zoomOut() {
        //TODO: 縮小
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
}

