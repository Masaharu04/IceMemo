import Foundation

@MainActor
protocol AlbumViewModel: AnyObject, Observable {
  var photoUrls: [URL] { get }
  func fetch() -> [URL]
  func onAppear()
  func isExpiringSoon(_ url: URL) -> Bool
}

@Observable
final class AlbumViewModelImpl: AlbumViewModel {
  var photoUrls: [URL] = []
  private var photoUseCase: PhotoUseCase

  init(photoUseCase: PhotoUseCase) {
    self.photoUseCase = photoUseCase
  }

  func fetch() -> [URL] {
    photoUseCase.fetch()
  }

  func onAppear() {
    photoUseCase.autoDelete()
    let urls = fetch()
    photoUrls = urls
  }

  func isExpiringSoon(_ url: URL) -> Bool {
    let remainString = photoUseCase.getRemainDate(imageUrl: url)
    if remainString.contains("期限切れ") { return false }
    let pattern = #"残り (\d+)日"#
    if let regex = try? NSRegularExpression(pattern: pattern),
       let match = regex.firstMatch(
         in: remainString, range: NSRange(remainString.startIndex..., in: remainString)
       ),
       let range = Range(match.range(at: 1), in: remainString),
       let days = Int(remainString[range]) {
      return days <= 3
    }
    return false
  }
}
