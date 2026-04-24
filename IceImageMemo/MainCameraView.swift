import SwiftUI

struct MainCameraView<VM: MainCameraViewModel>: View {
  @Bindable var vm: VM
  var body: some View {
    ZStack {
      // カメラプレビュー（全画面）
      CameraServiceView(session: vm.session)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .ignoresSafeArea()
        .gesture(
          MagnifyGesture()
            .onChanged { value in
              vm.onPinchChanged(scale: value.magnification)
            }
            .onEnded { _ in
              vm.onPinchEnded()
            }
        )
      VStack(spacing: 0) {
        Spacer()

        // 下部オーバーレイ
        VStack(spacing: 16) {
          // Segmented Control
          Picker("Expiration", selection: $vm.expirationType) {
            ForEach(Expiration.allCases) { item in
              Text(item.rawValue).tag(item)
            }
          }
          .pickerStyle(.segmented)
          .onAppear {
            let appearance = UISegmentedControl.appearance()
            appearance.setTitleTextAttributes(
              [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 14)],
              for: .normal
            )
            appearance.setTitleTextAttributes(
              [.foregroundColor: UIColor.black, .font: UIFont.boldSystemFont(ofSize: 14)],
              for: .selected
            )
            appearance.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            appearance.selectedSegmentTintColor = UIColor.white.withAlphaComponent(0.9)
          }
          .onChange(of: vm.expirationType) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
          }

          // 下段: サムネイル / シャッター / 空スペース（3等分で中央固定）
          HStack(alignment: .center, spacing: 0) {
            // 左: サムネイル（円形・写真がなければ非表示）
            ZStack {
              if let url = vm.lastPhotoURL,
                let uiImage = UIImage(contentsOfFile: url.path)
              {
                Image(uiImage: uiImage)
                  .resizable()
                  .scaledToFill()
                  .frame(width: 60, height: 60)
                  .clipShape(Circle())
                  .onTapGesture {
                    vm.onTapAlbumButton()
                  }
              }
            }
            .frame(maxWidth: .infinity, minHeight: 60)

            // 中央: シャッターボタン
            Button(action: vm.onTakePhoto) {
              ZStack {
                Circle()
                  .fill(Color.white)
                  .frame(width: 65, height: 65)
                Circle()
                  .stroke(Color.white, lineWidth: 2)
                  .frame(width: 75, height: 75)
              }
            }
            .frame(maxWidth: .infinity)

            // 右: 空スペース
            Color.clear
              .frame(width: 60, height: 60)
              .frame(maxWidth: .infinity)
          }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
        .padding(.top, 12)
        .background(
          LinearGradient(
            colors: [.clear, .black.opacity(0.6)],
            startPoint: .top,
            endPoint: .bottom
          )
          .ignoresSafeArea(edges: .bottom)
        )
      }
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
  case day
  case week
  case month
  case year
  var id: Self {
    self
  }
}
