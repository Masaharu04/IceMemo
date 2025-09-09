import Foundation
import SwiftUI
import Combine
import AVFoundation

protocol MainCameraViewModel: ObservableObject {
    var capturedImage: UIImage? { get }
    var session: AVCaptureSession { get }
    var expirationDate: Expiration { get set }
    func onAppear()
    func viewdidLoad()
    func onTakePhoto()
    func onTapAlbumButton()
    func zoomIn()
    func zoomOut()
}

final class MainCameraViewModelImpl: MainCameraViewModel {
    @Published var capturedImage: UIImage?
    @Published var expirationDate: Expiration = .day {
        didSet {
            print("選択肢が変更されました: \(expirationDate.rawValue)")
        }
    }
    private let service: CameraService
    private var bag = Set<AnyCancellable>()
    var session: AVCaptureSession{
        service.session
    }
    init(
        service: CameraService,
    ) {
        self.service = service
        service.photoPublisher
            .compactMap { UIImage(data: $0) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.capturedImage = image
                if let expiration = self?.expirationDate {
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
    
    func viewdidLoad() {
        //TODO: ロードした時
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
        //TODO: 画面遷移できればcordinatorパターンを使用したい
    }
    
}
extension MainCameraViewModelImpl {
    
    func storePhoto(expiration: Expiration, image: UIImage) {
        let saveUrl = makeUrl(expiration: expiration)
        guard let imageJpg = image.jpegData(compressionQuality: 0.0) else {
            return
        }
        do {
            try imageJpg.write(to: saveUrl)
        } catch {
            return
        }
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
}

