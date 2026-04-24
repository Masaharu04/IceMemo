import Foundation
import SwiftUI

enum AppRoute: Identifiable {
  case album
  case detail(URL)

  var id: String {
    switch self {
    case .album:
      "album"
    case .detail:
      "detail"
    }
  }
}

@MainActor
struct AppContainer {
  let makePhotoUseCase: () -> PhotoUseCase

  func makeAlbumViewModel() -> AlbumViewModelImpl {
    AlbumViewModelImpl(photoUseCase: makePhotoUseCase())
  }

  func makeDetailViewModel(imageUrl: URL, onDelete: (() -> Void)? = nil) -> DetailViewModelImpl {
    DetailViewModelImpl(photoUseCase: makePhotoUseCase(), imageURL: imageUrl, onDelete: onDelete)
  }
}

@MainActor
protocol AppCoordinatorProtocol: AnyObject, Observable {
  var presentedRoute: AppRoute? { get set }
  func present(_ route: AppRoute)
  func dismiss()
}

@Observable
@MainActor
final class AppCoordinator: AppCoordinatorProtocol {
  var presentedRoute: AppRoute?
  private let container: AppContainer
  var onPhotoDeleted: (() -> Void)?

  init(container: AppContainer) {
    self.container = container
  }

  func present(_ route: AppRoute) {
    presentedRoute = route
  }

  func dismiss() {
    presentedRoute = nil
  }

  @ViewBuilder
  func destinationView(for route: AppRoute) -> some View {
    switch route {
    case .album:
      AlbumView(vm: container.makeAlbumViewModel())
    case .detail(let imageUrl):
      DetailView(vm: container.makeDetailViewModel(imageUrl: imageUrl, onDelete: onPhotoDeleted))
    }
  }
}
