/*
 MainCameraViewModel.swift
 --------------------------------------------
 カメラ画面の ViewModel。CameraService で撮影・プレビューを管理し、
 撮影データを PhotoUseCase で保存します。アルバム画面への遷移は
 AppCoordinator 経由で行います。

 ■ 何をする？
 - カメラ起動/停止：onAppear() で configure → start、onDisappear() で stop
 - 撮影：onTakePhoto() → CameraService が JPEG/HEIC Data を発行
 - 保存：photoPublisher を購読し、Expiration に応じたフォルダへ JPEG(品質0.5) を保存
 - 表示制御：isPresented でシート表示、expirationType の変更ログ出力
 - 画面遷移：onTapAlbumButton() で .album を present
 - 補助：fetchLastPhoto() で最新1枚の URL を取得、viewdidLoad() で保存先フォルダ作成

 ■ 主なプロパティ
 - session: AVCaptureSession（CameraService から取得）
 - expirationType: Expiration（保存先フォルダ day/week/month/year の選択）
 - isPresented: シート表示フラグ
 - coordinator: AppCoordinator（アルバム画面遷移用。weak 参照）

 ■ Combine パイプライン
 CameraService.photoPublisher (Data)
   → UIImage 化
   → main スレッドに切替
   → storePhoto(expiration:image:) で Documents/<expiration>/ に保存

 ■ 使い方（例）
   @StateObject var vm = MainCameraViewModelImpl(
     service: CameraServiceImpl(),
     coordinator: coordinator,
     photoUseCase: PhotoUseCaseImpl(...)
   )
   .onAppear { vm.onAppear() }
   .onDisappear { vm.onDisappear() }

   CameraServiceView(session: vm.session)
   Button("シャッター") { vm.onTakePhoto() }
   Button("アルバム") { vm.onTapAlbumButton() }

 ■ 実装メモ / 改善提案
 - 命名:
   - `viewdidLoad()` → iOS 慣習に合わせ `viewDidLoad()` へ。
 - 型/依存:
   - 初期化子の引数は `photoUseCase: PhotoUseCase` とプロトコル型で受けると DI が柔軟。
   - ViewModel は UI 状態を扱うため `@MainActor` を付与すると安全。
 - パフォーマンス:
   - `UIImage.jpegData` は重い場合があるため、保存処理をバックグラウンドキューに逃がす検討。
 - ディレクトリ管理:
   - フォルダ作成は UseCase/Repository 層に寄せると責務分離が明確。
 - その他:
   - `objectWillChange.send()` は @Published を更新しない限り不要（ここでは保存だけ）。削除可。
   - ズーム（zoomIn/Out）は AVCaptureDevice の videoZoomFactor で実装可能。
   - 例外/エラーは現在 print のみ。ユーザー通知やリトライ方針が必要なら拡張を。
*/

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

