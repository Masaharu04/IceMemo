import SwiftUI

struct AlbumView<VM: AlbumViewModelImpl>: View {
    @StateObject var vm: VM
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible()),
                    count: 2,
                ),
                spacing: 32
            ) {
                if !vm.photoUrls.isEmpty {
                    ForEach(vm.photoUrls, id: \.self) { url in
                        photoCell(url: url)
                    }
                    .padding(.horizontal, 24)
                } else {
                    Image("sampleImage")
                        .resizable()
                        .scaledToFit()
                        .clipped()
                        .cornerRadius(20)
                        .frame(maxWidth: 200, maxHeight: 200)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                }
            }
            .onAppear {
                Task {
                    await vm.onAppear()
                }
            }
        }
    }
}
extension AlbumView {
    func photoCell(url: URL) -> some View {
        Group {
            if let uiImage = UIImage(contentsOfFile: url.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Color.gray // 読み込み失敗時のプレースホルダー
            }
        }
        .clipped()
        .cornerRadius(20)
        .frame(maxWidth: 200, maxHeight: 200)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
    }
}
