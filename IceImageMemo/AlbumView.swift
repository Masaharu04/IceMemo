import SwiftUI


struct AlbumView<VM: AlbumViewModel>: View {
    @ObservedObject var vm: VM
    @EnvironmentObject var coordinator: AppCoordinator
    
    private let spacing: CGFloat = 8
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: spacing),
                              GridItem(.flexible(), spacing: spacing)],
                    spacing: spacing
                ) {
                    ForEach(vm.photoUrls, id: \.self) { url in
                        NavigationLink(value: url) {
                            photoCell(url: url)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(spacing)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { coordinator.dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("写メモ帳")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .onAppear { vm.onAppear() }
            .navigationDestination(for: URL.self) { url in
                coordinator.destinationView(for: .detail(url))
            }
        }
    }
}

extension AlbumView {
    func photoCell(url: URL) -> some View {
        GeometryReader { geo in
            ZStack {
                if let uiImage = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.width)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: geo.size.width, height: geo.size.width)
                        .cornerRadius(12)
                }
                
                if vm.isExpiringSoon(url) {
                    Color.black.opacity(0.3)
                        .cornerRadius(12)
                    VStack {
                        Spacer()
                        Text("もうすぐ消えます")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(6)
                            .padding(4)
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}
