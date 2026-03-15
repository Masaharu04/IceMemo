import SwiftUI

struct DetailView<VM: DetailViewModel>: View {
    @ObservedObject var vm: VM
    @Environment(\.dismiss) private var dismiss

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 5.0

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

    var body: some View {
        GeometryReader { geometry in
            if let uiImage = UIImage(contentsOfFile: vm.imageURL.path) {
                let imgSize = uiImage.size
                ZStack {
                    Color(.systemBackground).ignoresSafeArea()

                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            MagnifyGesture()
                                .onChanged { value in
                                    let newScale = min(max(lastScale * value.magnification, minScale), maxScale)
                                    let anchor = value.startAnchor
                                    let viewSize = geometry.size
                                    // ピンチポイントからビュー中心までの距離
                                    let anchorOffset = CGSize(
                                        width: (anchor.x - 0.5) * viewSize.width,
                                        height: (anchor.y - 0.5) * viewSize.height
                                    )
                                    // スケール変化に応じてオフセットを調整
                                    let scaleDelta = newScale / scale
                                    let newOffset = CGSize(
                                        width: anchorOffset.width * (1 - scaleDelta) + offset.width * scaleDelta,
                                        height: anchorOffset.height * (1 - scaleDelta) + offset.height * scaleDelta
                                    )
                                    scale = newScale
                                    offset = clampedOffset(newOffset, imageSize: imgSize, viewSize: viewSize)
                                }
                                .onEnded { _ in
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if scale < minScale {
                                            scale = minScale
                                        }
                                        lastScale = scale
                                        if scale == minScale {
                                            offset = .zero
                                            lastOffset = .zero
                                        } else {
                                            offset = clampedOffset(offset, imageSize: imgSize, viewSize: geometry.size)
                                            lastOffset = offset
                                        }
                                    }
                                }
                                .simultaneously(with:
                                    DragGesture()
                                        .onChanged { value in
                                            guard scale > minScale else { return }
                                            let newOffset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                            offset = clampedOffset(newOffset, imageSize: imgSize, viewSize: geometry.size)
                                        }
                                        .onEnded { _ in
                                            lastOffset = offset
                                        }
                                )
                        )
                        .onTapGesture(count: 2) { location in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if scale > minScale {
                                    scale = minScale
                                    lastScale = minScale
                                    offset = .zero
                                    lastOffset = .zero
                                } else {
                                    let newScale: CGFloat = 3.0
                                    let viewSize = geometry.size
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
                                    offset = clampedOffset(newOffset, imageSize: imgSize, viewSize: viewSize)
                                    lastOffset = offset
                                }
                            }
                        }

                }
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        ShareLink(
                            item: ShareableUIImage(uiImage: uiImage),
                            preview: SharePreview(
                                "",
                                image: Image(uiImage: uiImage)
                            )
                        ) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(.primary)
                        }

                        Spacer()

                        Text(vm.remainDate)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.horizontal, 10)

                        Spacer()

                        Button {
                            vm.isDelete = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(.primary)
                        }
                    }
                }
                .alert("本当に削除しますか？", isPresented: $vm.isDelete) {
                    Button("削除", role: .destructive) {
                        vm.didTapDelteButton()
                        dismiss()
                    }
                    Button("キャンセル", role: .cancel) { }
                }
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vm.fetchRemainDate()
        }
    }
}
