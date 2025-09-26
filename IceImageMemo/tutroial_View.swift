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
    
    @State var shet = true
    @State var selected_image : UIImage?
    @State var selected_url : URL?


    var body: some View {
        ZStack{
            if select_view == "CameraView"{
                CameraView()
            }else if select_view == "GridView"{
                GridView(image_url: $image_url, show: $show)
            }else if select_view == "showImage"{
                Color.white
                    .ignoresSafeArea()
            }
            
            if is_tap == 0{
                SpotlightView(content: SelectTerm_text())
            }else if is_tap == 1{
                SpotlightView(content: go_GridView())
            }else if is_tap == 2{
                SpotlightView(content: gridView_tutorial())
            }else if is_tap == 3{
                showimage_tutorial(Viewsheet: $shet)
            }else if is_tap == 4{
                //SpotlightView(content: showImage_frame())
            }

        }
        .onTapGesture {
            is_tap += 1
            if is_tap == 2 {
                select_view = "GridView"
            }else if is_tap == 3{
                let photo = UIImage(named: "m3")!
                selected_url = tutorial_save(mode: 1, uiimage_data: photo)
                image_url = all_file_url(directory_url: change_name_to_url(image_name: ""))
                selected_image=read_image2(image_url: selected_url!)
                //select_view = "showImage"
            }else if is_tap == 4{
                //select_view = "GridView"
            }
        }

    }
}

func tutorial_save(mode: Int, uiimage_data: UIImage) -> URL{
    let directory_name = "day"
    let image_name = make_new_image_name()
    let image_url =  change_name_to_url(image_name: "\(directory_name)/\(image_name)")
    DispatchQueue.global().async {
        write_image(image_url: image_url, uiimage_data: uiimage_data)
    }
    print(image_url)
    return image_url
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
struct gridView_tutorial:View{
    var body: some View {
        ZStack{
            text_box(text: "Tapで画像の個別画面へ")
            gridView_frame()
        }
       
    }
}

struct showImage_tutorialView:View{
    var body: some View{
        ZStack{
            text_box(text:"tapで画像の詳細画面へ")
            showImage_frame()
        }
    }
}

struct showImage_frame:View{
    var body: some View{
        ZStack{
            Rectangle()
                .cornerRadius(20)
                .frame(maxWidth: UIScreen.main.bounds.width - 40,maxHeight: 460)
        }
    }
}


struct gridView_frame:View {
    var columns : [GridItem] = [ GridItem(.flexible()),GridItem(.flexible())]
    @State var Gshow = true
    var body: some View {
        ScrollView{
            LazyVGrid(columns: columns){
                Rectangle()
                    .frame(width: 185, height: 210)
                    .cornerRadius(20)
                    .offset(y: self.Gshow ? 0 :UIScreen.main.bounds.height)
            }
        }
        .padding(.horizontal,12)
        .padding(.top,70)
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


