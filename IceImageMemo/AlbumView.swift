import SwiftUI

struct AlbumView<VM: AlbumViewModel>: View {
    @ObservedObject var vm: VM
    @EnvironmentObject var coordinator: AppCoordinator
    var body: some View {
        NavigationStack {
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
                            NavigationLink(value: url) {
                                photoCell(url: url)
                            }
                            .buttonStyle(.plain)
                            .disabled(false)
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
                .padding(.horizontal, 16)
                .onAppear {
                    vm.onAppear()
                }
            }
            .simultaneousGesture(DragGesture(minimumDistance: 0))
            .navigationTitle("Album")
            .navigationDestination(for: URL.self) { url in
                coordinator.destinationView(for: .detail(url))
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
