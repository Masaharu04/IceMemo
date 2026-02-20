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
    var remainDate: String { get }
    func didTapImage(isTapoed: Bool)
    func didTapDelteButton()
    func fetchRemainDate()
    func getShotDate(imageUrl: URL) -> Date?
}

final class DetailViewModelImpl: DetailViewModel {
    func getShotDate(imageUrl: URL) -> Date? {
            // 例: ファイルの作成日時を取得する場合
            let attributes = try? FileManager.default.attributesOfItem(atPath: imageUrl.path)
            return attributes?[.creationDate] as? Date
            
            // あるいは、DB等からURLをキーに検索してDateを返すロジックをここに書く
        }
    private var photoUseCase: PhotoUseCase
    private let cancelNoticeUseCase = CancelDeleteNoticeForPhotoUseCase()
    @Published var position: pos = .init(width: 0, height: 0)
    @Published var isTapped: Bool = false
    @Published var isDelete: Bool = false
    @Published var remainDate: String = ""
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
        let attributes = try? FileManager.default.attributesOfItem(atPath: imageURL.path)
            if let shotDate = attributes?[.creationDate] as? Date {
                cancelNoticeUseCase.execute(shotDate: shotDate)
            }
        
        isDelete = false
        photoUseCase.deletePhoto(imageUrl: imageURL)
    }
    
    func fetchRemainDate() {
        remainDate = photoUseCase.getRemainDate(imageUrl: imageURL)
        print("DetailViewModelImpl")
        print(imageURL)
    }

}
