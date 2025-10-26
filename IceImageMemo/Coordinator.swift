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


