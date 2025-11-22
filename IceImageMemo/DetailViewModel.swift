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
