import Photos
import SwiftUI
import UIKit

// TODO: 入れなくなったら消す
struct TapItems: Identifiable {
  var id = UUID()
  var icon: String
  var tap: Tap
}

var tapItems = [
  TapItems(icon: "d.circle", tap: .day),
  TapItems(icon: "w.circle", tap: .week),
  TapItems(icon: "m.circle", tap: .month),
  TapItems(icon: "y.circle", tap: .year),
]

enum Tap: String {
  case day
  case week
  case month
  case year
}

var isFirst: Bool = false

struct ContentView: View {
  @State private var coordinator: AppCoordinator
  let vm: MainCameraViewModelImpl

  init() {
    let photoRepository = PhotoRepositoryImpl()
    let container = AppContainer(
      makePhotoUseCase: { PhotoUseCaseImpl(repository: photoRepository) }
    )
    let coordinator = AppCoordinator(container: container)
    _coordinator = State(wrappedValue: coordinator)
    let service = CameraServiceImpl()
    let photoUseCase = PhotoUseCaseImpl(repository: photoRepository)
    vm = MainCameraViewModelImpl(
      service: service, coordinator: coordinator, photoUseCase: photoUseCase
    )
    vm.viewdidLoad()
  }

  var body: some View {
    @Bindable var coordinator = coordinator
    if isFirst == true {
      // tutroial_View()
    } else {
      MainCameraView(vm: vm)
        .sheet(
          item: $coordinator.presentedRoute,
          onDismiss: {
            vm.refreshLastPhoto()
          },
          content: { route in
            coordinator.destinationView(for: route)
          }
        )
        .environment(coordinator)
    }
  }
}

struct ContentViewPreviews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
