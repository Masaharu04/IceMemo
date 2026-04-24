import Foundation
import UIKit

@MainActor
protocol AlbumViewModel: AnyObject, Observable {
  var photoUrls: [URL] { get }
  var croppedImageCache: [URL: UIImage] { get }
  func fetch() -> [URL]
  func onAppear()
  func isExpiringSoon(_ url: URL) -> Bool
  func croppedImage(for url: URL) -> UIImage?
}

@Observable
final class AlbumViewModelImpl: AlbumViewModel {
  var photoUrls: [URL] = []
  var croppedImageCache: [URL: UIImage] = [:]
  private var photoUseCase: PhotoUseCase
  private let cropService: DocumentCropService
  private var processedUrls: Set<URL> = []

  init(photoUseCase: PhotoUseCase, cropService: DocumentCropService) {
    self.photoUseCase = photoUseCase
    self.cropService = cropService
  }

  func fetch() -> [URL] {
    photoUseCase.fetch()
  }

  func onAppear() {
    photoUseCase.autoDelete()
    let urls = fetch()
    photoUrls = urls
    scheduleCropDetection(for: urls)
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

  func croppedImage(for url: URL) -> UIImage? {
    croppedImageCache[url]
  }

  // MARK: - Private

  private func scheduleCropDetection(for urls: [URL]) {
    for url in urls {
      guard !processedUrls.contains(url) else { continue }
      processedUrls.insert(url)
      Task {
        guard let image = UIImage(contentsOfFile: url.path) else { return }
        if let cropped = await cropService.detectAndCrop(from: image) {
          await MainActor.run { self.croppedImageCache[url] = cropped }
        }
      }
    }
  }
}
