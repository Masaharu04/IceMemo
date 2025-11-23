import SwiftUI
import AVFoundation
import Combine

struct MainCameraView<VM: MainCameraViewModel>: View {
    @ObservedObject var vm: VM
    var body: some View {
        ZStack {
            CameraServiceView(session: vm.session)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                HStack(alignment: .center){
                    Group {
                        if let url = vm.fetchLastPhoto(),
                           let uiImage = UIImage(contentsOfFile: url.path) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 72, height: 72)
                                .clipped()
                                .cornerRadius(10)
                        }else{
                            Rectangle()
                                .frame(width: 72, height: 72)
                                .background(Color.gray.opacity(0.2))
                                .clipped()
                                .cornerRadius(10)
                        }
                    }
                    .onTapGesture {
                        vm.onTapAlbumButton()
                    }
                    Spacer()
                    Button(
                        action: vm.onTakePhoto
                    ){
                        ZStack{
                            Circle()
                                .fill(Color.white)
                                .frame(width: 65, height: 65)
                            Circle()
                                .stroke(Color.white,lineWidth: 2)
                                .frame(width: 75, height: 75)
                        }
                    }
                    Spacer()
                    expirationDateButton(selection: $vm.expirationType)
                        .frame(width: 80, height: 64)
                }
            }
            .padding(.bottom, 64)
            .padding(.horizontal, 16)
        }
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
    }
}

enum Expiration: String, CaseIterable, Identifiable {
    case day = "day"
    case week = "week"
    case month = "month"
    case year = "year"
    var id: Self { self }

    var next: Expiration {
        let all = Self.allCases
        let i = all.firstIndex(of: self)!
        return all[(i + 1) % all.count]
    }
}
extension MainCameraView {
    struct expirationDateButton: View  {
        @Binding var selection: Expiration
        var body : some View {
            Button {
                selection = selection.next
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Text(selection.rawValue)
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .contextMenu {
                ForEach(Expiration.allCases) { item in
                    Button {
                        selection = item
                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    } label: {
                        if selection == item {
                            Label(item.rawValue, systemImage: "checkmark")
                        } else {
                            Text(item.rawValue)
                        }
                    }
                }
            }
            .accessibilityValue(Text(selection.rawValue))
        }
    }
}
