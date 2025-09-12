//
//  ContentView.swift
//  IceImageMemo
//
//  Created by Masaharu on 2023/07/24.
//

import SwiftUI
import UIKit
import Photos

struct TapItems:Identifiable{
    var id = UUID()
    var icon : String
    var tap:Tap
}

var tapItems = [
    TapItems(icon: "d.circle", tap: .day),
    TapItems(icon: "w.circle", tap: .week),
    TapItems(icon: "m.circle", tap: .month),
    TapItems(icon: "y.circle", tap: .year)]

enum Tap :String{
    case day
    case week
    case month
    case year
}
var is_first:Bool = false

struct ContentView: View{
    @StateObject private var coordinator: AppCoordinator
    let vm: MainCameraViewModelImpl

    init() {
        let container = AppContainer(
            makePhotoUseCase: { photoUseCaseImpl() }
        )
        let coordinator = AppCoordinator(container: container)
        _coordinator = StateObject(wrappedValue: coordinator)
        let service = CameraServiceImpl()
        self.vm = MainCameraViewModelImpl(service: service, coordinator: coordinator)
        vm.viewdidLoad()
    }
    var body: some View{
        if is_first == true{
            tutroial_View()
        }else{
//            CameraView()
            MainCameraView(vm: vm)
                .fullScreenCover(item: $coordinator.presentedRoute) { route in
                    coordinator.destinationView(for: route)
                }
        }
    }
}

struct ContentView_Preiews: PreviewProvider{
    static var previews: some View{
        ContentView()
    }
}
