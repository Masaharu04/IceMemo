import SwiftUI

struct DetailView<VM: DetailViewModel>: View {
    @ObservedObject var vm: VM
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        GeometryReader { geometry in
            if let uiImage = UIImage(contentsOfFile: vm.imageURL.path) {
                VStack(spacing: 10) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipped()
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                        .onTapGesture {
                            vm.isTapped.toggle()
                            vm.didTapImage(isTapoed: vm.isTapped)
                        }
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    vm.isDelete = true
                                } label: {
                                    Text("Delete")
                                }
                            }
                            ToolbarItem(placement: .bottomBar) {
                                ShareLink(
                                    item: ShareableUIImage(uiImage: uiImage),
                                    preview: SharePreview("Image")
                                ) {
                                    Label("Share", systemImage: "square.and.arrow.up")
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
                    Text(vm.remainDate)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            vm.fetchRemainDate()
        }
    }
}

