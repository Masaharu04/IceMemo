/*
 AlbumViewModel.swift
 --------------------------------------------
 アルバム画面の ViewModel。PhotoUseCase から画像URL一覧を取得し、
 画面表示用に @Published な配列として公開します。

 ■ 何をする？
 - photoUrls: 画面表示用の画像 URL 配列（@Published）
 - onAppear(): 画面表示時に PhotoUseCase.fetch() を呼び出し、photoUrls を更新
 - fetch(): UseCase の取得結果をそのまま返す（内部利用想定）

 ■ 使い方（例）
   @StateObject var vm = AlbumViewModelImpl(photoUseCase: makePhotoUseCase())
   GridView(urls: vm.photoUrls)
     .onAppear { vm.onAppear() }

 ■ 設計メモ / 改善提案
 - インポート:
   - @Published を使うため `import Combine`（または `import SwiftUI`）が必要です。
 - スレッド安全:
   - UI 状態を更新するため、クラスに `@MainActor` を付けると安全です。
 - API 形:
   - View からは `onAppear()` だけ呼べれば十分なので、
     `fetch()` を `private` にして内部実装に閉じ込めるのも手です。
 - アクセス制御:
   - `@Published private(set) var photoUrls` とすると外部からの書き換えを防げます。
 - 更新検知:
   - 写真の追加/削除を他画面から行う場合は、通知や Publisher を介して
     自動で `onAppear()` 相当の再読み込みを行うと UX が向上します。
*/

import Foundation

protocol AlbumViewModel: ObservableObject {
    var photoUrls: [URL] { get }
    func fetch() -> [URL]
    func onAppear()
}

final class AlbumViewModelImpl: AlbumViewModel {
    @Published var photoUrls: [URL]
    private var photoUseCase: PhotoUseCase
    
    init(photoUseCase: PhotoUseCase) {
        self.photoUseCase = photoUseCase
        self.photoUrls = []
    }
    
    func fetch() -> [URL] {
        self.photoUseCase.fetch()
    }
    
    func onAppear() {
        let urls = fetch()
        self.photoUrls = urls
    }

}

