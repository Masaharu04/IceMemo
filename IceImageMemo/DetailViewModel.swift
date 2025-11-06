/*
 DetailViewModel.swift
 --------------------------------------------
 画像詳細画面の ViewModel（ユースケースとの仲介・UI状態管理）をまとめたファイルです。
 選択中の画像URL・レイアウト用サイズ・タップ/削除フラグを保持し、
 削除操作は PhotoUseCase に委譲します。

 ■ 何をする？
 - imageURL: 表示対象の画像 URL（必須）
 - position: 画像ビューの幅/高さなどレイアウト計算用のサイズ
 - isTapped: 画像タップ状態の UI フラグ
 - isDelete: 削除確認用の UI フラグ（例: 確認ダイアログの表示制御）
 - didTapDeleteButton(): PhotoUseCase を呼び出して実ファイルを削除

 ■ 使い方（例）
   // View 側
   @StateObject var vm: DetailViewModelImpl
   Image(uiImage: ...)
     .onTapGesture { vm.isTapped.toggle() }
   Button("削除") { vm.didTapDelteButton() } // 確認ダイアログ表示→確定後に呼ぶ

 ■ 設計メモ / 改善提案
 - 命名:
   - `pos` は Swift の慣習に合わせ `Pos` もしくは用途が伝わる `ImageSize` などに変更を推奨。
     あるいは標準の `CGSize` を使うと依存が減ります。
   - `didTapDelteButton` は綴り誤り（Delte）→ `didTapDeleteButton`。
   - `didTapImage(isTapoed:)` も綴り誤り（Tapoed）→ `isTapped`。
     そもそも副作用がなければメソッド自体を削除して `isTapped.toggle()` で十分です。
 - スレッド/アクター:
   - UI 状態（@Published）を扱うため、`@MainActor` をクラスに付与すると安全です。
 - 依存の注入:
   - `photoUseCase` は変更しないので `private let` にできます。
 - インポート:
   - 本ファイルは `CGFloat` と `@Published` を使うため
     `import CoreGraphics`（または `import SwiftUI`）と `import Combine` が必要です。
 - 削除フロー:
   - `isDelete` は意味が曖昧なので `showDeleteConfirmation` のような命名がおすすめ。
   - 現行実装は「フラグを false に戻してから即削除」になっています。
     確認ダイアログ→確定→削除の順にしたい場合は、確定時にのみ `deletePhoto` を呼ぶ構成に。

 ■ 依存
 - PhotoUseCase: 実ファイルの削除・保存などのドメイン操作を委譲する境界
*/

import Foundation

struct pos {
    var width: CGFloat
    var height: CGFloat
    
    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
    }
}

protocol DetailViewModel: ObservableObject {
    var imageURL: URL { get }
    var position: pos { get }
    var isTapped: Bool { get set }
    var isDelete: Bool { get set }
    func didTapImage(isTapoed: Bool)
    func didTapDelteButton() 

}

final class DetailViewModelImpl: DetailViewModel {
    private var photoUseCase: PhotoUseCase
    @Published var position: pos = .init(width: 0, height: 0)
    @Published var isTapped: Bool = false
    @Published var isDelete: Bool = false
    var imageURL: URL
    
    init(
        photoUseCase: PhotoUseCase,
        imageURL: URL
    ) {
        self.photoUseCase = photoUseCase
        self.imageURL = imageURL
    }
    
    func didTapImage(isTapoed: Bool) {
        // TODO: 画像タップ時の処理追加←実装いらない説あり
    }
    
    func didTapDelteButton() {
        isDelete = false
        photoUseCase.deletePhoto(imageUrl: imageURL)
    }
}
