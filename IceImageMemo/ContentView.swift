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
var is_first:Bool = true


struct ContentView: View{
    init(){
        make_directory_2()
    }
    var body: some View{
        if is_first == true{
            tutroial_View()
        }else{
            CameraView()
        }
    }
}

struct ContentView_Preiews: PreviewProvider{
    static var previews: some View{
        ContentView()
    }
}
