import Foundation
import SwiftUICore

enum AppRoute: Identifiable {
    case album
    case setting
    case tutorial
    
    var id: String {
        switch self {
        case .album:
            return "album"
        case .setting:
            return "setting"
        case .tutorial:
            return "tutorial"
        } 
    }
}

struct AppContainer {
    let makePhotoUseCase: () -> PhotoUseCase
    
    func makeAlbumViewModel() -> AlbumViewModelImpl {
        AlbumViewModelImpl(photoUseCase: makePhotoUseCase())
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
        }
    }
}


