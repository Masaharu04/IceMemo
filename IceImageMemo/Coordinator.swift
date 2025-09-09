import Foundation

enum sheetDestination {
    case album
    case setting
    case tutorial
}

final class AppCoordinator: ObservableObject {
    @Published var sheet: sheetDestination? = nil
    
    func dismissSheet() { self.sheet = nil }
    func showSheet(route: sheetDestination) { sheet = route }
    
    
}
