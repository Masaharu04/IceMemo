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
            .padding(.top, 16)
            .onAppear {
                vm.onAppear()
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
                    .clipped()
                    .cornerRadius(20)
                    .frame(maxWidth: 200, maxHeight: 200)
            } else {
                Image("sampleImage")
            }
        }
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
    }
}
