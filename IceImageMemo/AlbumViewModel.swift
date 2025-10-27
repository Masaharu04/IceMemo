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

