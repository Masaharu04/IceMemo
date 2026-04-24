import SwiftUI

struct DetailView<VM: DetailViewModel>: View {
    @ObservedObject var vm: VM
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            let displayImage = vm.showingCropped ? vm.croppedImage : UIImage(contentsOfFile: vm.imageURL.path)
            let originalImage = UIImage(contentsOfFile: vm.imageURL.path)
            if let uiImage = displayImage ?? originalImage {
                let imgSize = uiImage.size
                ZStack {
                    Color(.systemBackground).ignoresSafeArea()

                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .scaleEffect(vm.scale)
                        .offset(vm.offset)
                        .gesture(
                            MagnifyGesture()
                                .onChanged { value in
                                    vm.onPinchChanged(
                                        magnification: value.magnification,
                                        anchor: CGPoint(x: value.startAnchor.x, y: value.startAnchor.y),
                                        viewSize: geometry.size,
                                        imageSize: imgSize
                                    )
                                }
                                .onEnded { _ in
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        vm.onPinchEnded(viewSize: geometry.size, imageSize: imgSize)
                                    }
                                }
                                .simultaneously(with:
                                    DragGesture()
                                        .onChanged { value in
                                            vm.onDragChanged(
                                                translation: value.translation,
                                                viewSize: geometry.size,
                                                imageSize: imgSize
                                            )
                                        }
                                        .onEnded { _ in
                                            vm.onDragEnded()
                                        })
                        )
                        .onTapGesture(count: 2) { location in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                vm.onDoubleTap(
                                    location: location,
                                    viewSize: geometry.size,
                                    imageSize: imgSize
                                )
                            }
                        }

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ShareLink(
                                item: ShareableUIImage(uiImage: originalImage ?? uiImage),
                                preview: SharePreview(
                                    "",
                                    image: Image(uiImage: originalImage ?? uiImage)
                                )
                            ) {
                                if #available(iOS 26, *) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                        .frame(width: 52, height: 52)
                                        .glassEffect(in: .circle)
                                } else {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.title2)
                                        .foregroundStyle(.primary)
                                        .frame(width: 52, height: 52)
                                        .background(.ultraThinMaterial, in: Circle())
                                }
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 8)
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        if #available(iOS 26, *) {
                            Text(vm.remainDate)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .glassEffect(in: .capsule)
                        } else {
                            Text(vm.remainDate)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                        }
                    }
                    if vm.isCropAvailable {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                vm.toggleCropView()
                            } label: {
                                Image(systemName: vm.showingCropped ? "photo" : "doc.viewfinder")
                            }
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
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
                    Button("キャンセル", role: .cancel) {}
                }
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vm.fetchRemainDate()
            Task { await vm.loadCroppedImageIfNeeded() }
        }
    }
}
