import SwiftUI

struct DetailView<VM: DetailViewModel>: View {
    @ObservedObject var vm: VM
    @Environment(\.dismiss) private var dismiss

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
                                item: ShareableUIImage(uiImage: uiImage),
                                preview: SharePreview(
                                    "",
                                    image: Image(uiImage: uiImage)
                                )
                            ) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title2)
                                    .foregroundStyle(.primary)
                                    .padding(16)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(vm.remainDate)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
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
        }
    }
}
