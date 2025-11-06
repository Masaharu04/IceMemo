/*
 AppCoordinator.swift
 --------------------------------------------
 SwiftUI の画面遷移を MVVM + Coordinator で分離するためのファイルです。
 「どの画面へ遷移するか」と「遷移先に注入する ViewModel の生成」を集中管理します。

 ■ 構成
 - AppRoute: 画面の種類を表す enum。Identifiable 準拠なので
   .sheet(item:) や .navigationDestination(item:) にそのまま使えます。
   例) .detail(URL) は引数付きの画面遷移。
 - AppContainer: かんたんな DI コンテナ。各 ViewModel の Factory をまとめます。
 - AppCoordinator: ObservableObject。presentedRoute をトリガに表示/非表示を制御し、
   destinationView(for:) で Route → 実際の View を解決します。

 ■ 使い方（例）
   @StateObject var coordinator = AppCoordinator(
     container: AppContainer(makePhotoUseCase: { ... })
   )

   // モーダル表示の例
   .sheet(item: $coordinator.presentedRoute) { route in
     coordinator.destinationView(for: route)
   }

   // 起点から遷移
   Button("Open Album") { coordinator.present(.album) }

 ■ 拡張方法
 - 画面追加: AppRoute に case を追加 → destinationView の switch に分岐を追加
   → 必要に応じて AppContainer に ViewModel Factory を追加。
 - 引数付き画面: enum の associated value を活用（例: .detail(URL)）。

 ■ 注意点
 - presentedRoute を nil にすると閉じます（dismiss）。
 - UI 更新はメインスレッドで行ってください（@MainActor を検討）。
 - 深い階層のプッシュ遷移が必要なら NavigationStack と併用してください。
*/

import Foundation
import SwiftUI

enum AppRoute: Identifiable {
    case album
    case setting
    case tutorial
    case detail(URL)
    
    var id: String {
        switch self {
        case .album:
            return "album"
        case .setting:
            return "setting"
        case .tutorial:
            return "tutorial"
        case .detail:
            return "detail"
        }
    }
}

struct AppContainer {
    let makePhotoUseCase: () -> PhotoUseCase
    
    func makeAlbumViewModel() -> AlbumViewModelImpl {
        AlbumViewModelImpl(photoUseCase: makePhotoUseCase())
    }
    
    func makeDetailViewModel(imageUrl: URL) -> DetailViewModelImpl {
        DetailViewModelImpl(photoUseCase: makePhotoUseCase(), imageURL: imageUrl)
    }
}

protocol AppCoordinatorProtocol: ObservableObject {
    var presentedRoute: AppRoute? { get set }
    func present(_ route: AppRoute)
    func dismiss()
}

final class AppCoordinator: AppCoordinatorProtocol {
    @Published var presentedRoute: AppRoute?
    private let container: AppContainer
    
    init(container: AppContainer) {
        self.container = container
    }
    
    func present(_ route: AppRoute) { presentedRoute = route }
    func dismiss() { presentedRoute = nil }
    
    @ViewBuilder
    func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .album:
            AlbumView(vm: self.container.makeAlbumViewModel())
        case .setting:
            Text("Setting")
        case .tutorial:
            Text("Tutorial")
        case .detail(let imageUrl):
            DetailView(vm: self.container.makeDetailViewModel(imageUrl: imageUrl))
        }
    }
}


