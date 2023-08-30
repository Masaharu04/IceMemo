//
//  tutroial_View.swift
//  FadeMemo
//
//  Created by 山本聖留 on 2023/08/30.
//

import SwiftUI

struct tutroial_View: View {
    @State var is_tap:Int = 0
    @State var select_view :String = "CameraView"
    @State var image_url:[URL]  = all_file_url(directory_url: change_name_to_url(image_name: ""))
    @State var show = false

    var body: some View {
        ZStack{
            if select_view == "CameraView"{
                CameraView()
            }else if select_view == "GridView"{
                GridView(image_url: $image_url, show: $show)
            }
            if is_tap == 0{
                SpotlightView(content: SelectTerm_text())
            }else if is_tap == 1{
                SpotlightView(content: go_GridView())
            }else if is_tap == 2{

                
            }
        }
        .onTapGesture {
            is_tap += 1
            if is_tap == 2 {
                select_view = "GridView"
            }
        }

    }
}

struct tutroial_View_Previews: PreviewProvider {
    static var previews: some View {
        tutroial_View()
    }
}

struct SpotlightView<Content: View>: View {
    let content: Content
    var opacity: CGFloat = 0.5
    
    var body: some View {
        Rectangle()
            .fill(Color.black.opacity(opacity))
            .mask(
                ZStack {
                    content.foregroundColor(.black)
                }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white)
                    .compositingGroup()
                    .luminanceToAlpha()
            )
            .ignoresSafeArea(.all)
    }
}


struct CustomShape: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 60)
            .frame(width: 200, height: 200)
    }
}

struct SelectTerm_text: View {
    var body: some View {
        ZStack{
            text_box(text: "保存する期間を選択します")
            SelectTerm_shape()
        }
    }
}
struct go_GridView: View {
    var body: some View {
        ZStack{
            text_box(text: "Tapで写真ライブラリへ")
            Circle()
                .frame(width: 100,height: 100)
        }
    }
}

struct text_box:View{
    @State var text:String
    var body: some View{
        ZStack{
            VStack{
                VStack{
                    Spacer()
                    VStack{
                        Spacer()
                    }
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 300, height: 100)
                        Text(text)
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    
                    VStack{
                        Spacer()
                    }
                }

                Spacer()
            }
        }
    }
}

struct SelectTerm_shape: View {
    var body: some View {
        ZStack{
            VStack{
                VStack{
                    Spacer()
                    VStack{
                        Spacer()
                        VStack{
                            Spacer()
                            VStack{
                                Spacer()
                                HStack{
                                    ForEach(0..<4){ i in
                                        
                                        Circle()
                                            .frame(width: 50,height: 50)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    Spacer()
                }
                Spacer()
            }
            Spacer()
        }
        
    }
}


