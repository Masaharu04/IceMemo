import SwiftUI

struct AlbumView: View {
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible()),
                    count: 2,
                ),
                spacing: 32
            ) {
                photoCell(imageName: "m3")
                photoCell(imageName: "sampleImage")
                photoCell(imageName: "m3")
                photoCell(imageName: "m3")
                photoCell(imageName: "sampleImage")
                photoCell(imageName: "sampleImage")
                photoCell(imageName: "m3")
                photoCell(imageName: "m3")
                photoCell(imageName: "m3")
                photoCell(imageName: "m3")
                photoCell(imageName: "sampleImage")
            }
            .padding(.horizontal, 24)
        }
    }
}
extension AlbumView {
    func photoCell(imageName: String) -> some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .clipped()
            .cornerRadius(20)
            .frame(maxWidth: 200, maxHeight: 200)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
    }
}

#Preview {
    AlbumView()
}
