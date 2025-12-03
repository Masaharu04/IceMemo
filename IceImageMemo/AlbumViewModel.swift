import Foundation

protocol AlbumViewModel: ObservableObject {
    var photoUrls: [URL] { get }
    func fetch() -> [URL]
    func onAppear()
    func isExpiringSoon(_ url: URL) -> Bool
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
    
    func isExpiringSoon(_ url: URL) -> Bool {
        let remainString = photoUseCase.getRemainDate(imageUrl: url)
        if remainString.contains("期限切れ") { return false }
        let pattern = #"残り (\d+)日"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: remainString, range: NSRange(remainString.startIndex..., in: remainString)),
           let range = Range(match.range(at: 1), in: remainString),
           let days = Int(remainString[range]) {
            return days <= 3
        }
        return false
    }
}

