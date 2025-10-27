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
                        .frame(width: geometry.size.width + vm.position.width, height: geometry.size.height + vm.position.height,alignment: .center)
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
        }
    }
}

