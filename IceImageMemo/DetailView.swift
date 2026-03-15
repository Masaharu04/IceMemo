import SwiftUI

struct DetailView<VM: DetailViewModel>: View {
    @ObservedObject var vm: VM
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            if let uiImage = UIImage(contentsOfFile: vm.imageURL.path) {
                ZStack {
                    Color(.systemBackground).ignoresSafeArea()

                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                vm.isTapped.toggle()
                                vm.didTapImage(isTapoed: vm.isTapped)
                            }
                        }

                }
                .toolbar(vm.isTapped ? .hidden : .visible, for: .navigationBar)
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
