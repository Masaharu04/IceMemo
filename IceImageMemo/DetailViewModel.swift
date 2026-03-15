import Foundation
import SwiftUI

protocol DetailViewModel: ObservableObject {
    var imageURL: URL { get }
    var isDelete: Bool { get set }
    var remainDate: String { get }
    var scale: CGFloat { get set }
    var offset: CGSize { get set }

    func didTapDelteButton()
    func fetchRemainDate()
    func onPinchChanged(magnification: CGFloat, anchor: UnitPoint, viewSize: CGSize, imageSize: CGSize)
    func onPinchEnded(viewSize: CGSize, imageSize: CGSize)
    func onDragChanged(translation: CGSize, viewSize: CGSize, imageSize: CGSize)
    func onDragEnded()
    func onDoubleTap(location: CGPoint, viewSize: CGSize, imageSize: CGSize)
}

@MainActor
final class DetailViewModelImpl: DetailViewModel {
    private var photoUseCase: PhotoUseCase
    private let cancelNoticeUseCase = CancelDeleteNoticeForPhotoUseCase()

    @Published var isDelete: Bool = false
    @Published var remainDate: String = ""
    @Published var scale: CGFloat = 1.0
    @Published var offset: CGSize = .zero

    var imageURL: URL
    var onDelete: (() -> Void)?

    private var lastScale: CGFloat = 1.0
    private var lastOffset: CGSize = .zero
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 5.0

    init(
        photoUseCase: PhotoUseCase,
        imageURL: URL,
        onDelete: (() -> Void)? = nil
    ) {
        self.photoUseCase = photoUseCase
        self.imageURL = imageURL
        self.onDelete = onDelete
    }

    func didTapDelteButton() {
        let attributes = try? FileManager.default.attributesOfItem(atPath: imageURL.path)
        if let shotDate = attributes?[.creationDate] as? Date {
            cancelNoticeUseCase.execute(shotDate: shotDate)
        }

        isDelete = false
        photoUseCase.deletePhoto(imageUrl: imageURL)
        onDelete?()
    }

    func fetchRemainDate() {
        remainDate = photoUseCase.getRemainDate(imageUrl: imageURL)
    }

    // MARK: - Zoom & Pan

    func onPinchChanged(magnification: CGFloat, anchor: UnitPoint, viewSize: CGSize, imageSize: CGSize) {
        let newScale = min(max(lastScale * magnification, minScale), maxScale)
        let anchorOffset = CGSize(
            width: (anchor.x - 0.5) * viewSize.width,
            height: (anchor.y - 0.5) * viewSize.height
        )
        let scaleDelta = newScale / scale
        let newOffset = CGSize(
            width: anchorOffset.width * (1 - scaleDelta) + offset.width * scaleDelta,
            height: anchorOffset.height * (1 - scaleDelta) + offset.height * scaleDelta
        )
        scale = newScale
        offset = clampedOffset(newOffset, imageSize: imageSize, viewSize: viewSize)
    }

    func onPinchEnded(viewSize: CGSize, imageSize: CGSize) {
        if scale < minScale {
            scale = minScale
        }
        lastScale = scale
        if scale == minScale {
            offset = .zero
            lastOffset = .zero
        } else {
            offset = clampedOffset(offset, imageSize: imageSize, viewSize: viewSize)
            lastOffset = offset
        }
    }

    func onDragChanged(translation: CGSize, viewSize: CGSize, imageSize: CGSize) {
        guard scale > minScale else { return }
        let newOffset = CGSize(
            width: lastOffset.width + translation.width,
            height: lastOffset.height + translation.height
        )
        offset = clampedOffset(newOffset, imageSize: imageSize, viewSize: viewSize)
    }

    func onDragEnded() {
        lastOffset = offset
    }

    func onDoubleTap(location: CGPoint, viewSize: CGSize, imageSize: CGSize) {
        if scale > minScale {
            scale = minScale
            lastScale = minScale
            offset = .zero
            lastOffset = .zero
        } else {
            let newScale: CGFloat = 3.0
            let anchorOffset = CGSize(
                width: location.x - viewSize.width / 2,
                height: location.y - viewSize.height / 2
            )
            let newOffset = CGSize(
                width: anchorOffset.width * (1 - newScale),
                height: anchorOffset.height * (1 - newScale)
            )
            scale = newScale
            lastScale = newScale
            offset = clampedOffset(newOffset, imageSize: imageSize, viewSize: viewSize)
            lastOffset = offset
        }
    }

    // MARK: - Private

    private func displayedImageSize(imageSize: CGSize, viewSize: CGSize) -> CGSize {
        let imageAspect = imageSize.width / imageSize.height
        let viewAspect = viewSize.width / viewSize.height
        if imageAspect > viewAspect {
            let w = viewSize.width
            return CGSize(width: w, height: w / imageAspect)
        } else {
            let h = viewSize.height
            return CGSize(width: h * imageAspect, height: h)
        }
    }

    private func clampedOffset(_ newOffset: CGSize, imageSize: CGSize, viewSize: CGSize) -> CGSize {
        let displayed = displayedImageSize(imageSize: imageSize, viewSize: viewSize)
        let maxX = max((displayed.width * scale - viewSize.width) / 2, 0)
        let maxY = max((displayed.height * scale - viewSize.height) / 2, 0)
        return CGSize(
            width: min(max(newOffset.width, -maxX), maxX),
            height: min(max(newOffset.height, -maxY), maxY)
        )
    }
}
