//
//  GridView.swift
//  IceImageMemo
//
//  Created by Masaharu on 2023/07/25.
//

import SwiftUI
import Foundation

struct GridView: View {
    @StateObject var manger = ManagerClass()
    @Binding var image_url: [URL]
    var columns : [GridItem] = [ GridItem(.flexible()),GridItem(.flexible())]
    @State var Gshow = false
    @State var viewstate :CGSize = .zero
    @Binding var show : Bool
    @State var shet = false
    @State var selected_image : UIImage?
    @State var selected_url : URL?
    //@State var image_url2:[URL]
    
    
    
    var body: some View {
        ZStack{

            ScrollView{
                
                LazyVGrid(columns: columns){
                    //let is_bool = print_view(url_image:image_url)
                    ForEach(image_url.indices,id: \.self){index in
                        let is_exist = check_image_exist(image_url: image_url[index])
                        if is_exist {
                            if(judge_format(file_url: image_url[index]) == "jpg"){
                                Image(uiImage: read_image2(image_url: image_url[index]))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 170, height: 200)
                                    .cornerRadius(20)
                                    .offset(y: self.Gshow ? 0 :UIScreen.main.bounds.height)
                                    .animation(Animation.spring().delay(Double(index) * 0.1), value: Gshow)
                                    .shadow(color: Color.black.opacity(0.2),radius: 10,x: 0,y: 10)
                                    .padding(.vertical)
                                
                                    .onTapGesture {
                                        shet.toggle()
                                        selected_url = image_url[index]
                                        selected_image = read_image2(image_url: image_url[index])
                                        manger.stop()
                                        manger.reset()
                                    }
                            }else if(judge_format(file_url: image_url[index]) == "txt"){
                                Button(read_text(text_url: image_url[index])){
                                    @Environment(\.openURL) var openurl
                                    if(can_openURL(url_string: read_text(text_url: image_url[index]))){
                                        openurl(URL(string: read_text(text_url: image_url[index]))!)
                                    }else{
                                        let google_url = jump_google_Search(word: read_text(text_url: image_url[index]))
                                        openurl(google_url!)
                                        
                                    }
                                }
                                .frame(width: 170, height: 200)
                                .background(Color.black)
                                .cornerRadius(20)
                                .offset(y: self.Gshow ? 0 :UIScreen.main.bounds.height)
                                .animation(Animation.spring().delay(Double(index) * 0.1), value: Gshow)
                                .shadow(color: Color.black.opacity(0.2),radius: 10,x: 0,y: 10)
                                .padding(.vertical)
                            }
                        }
                    }
                }
                .padding(.horizontal,12)
                .padding(.top,60)
                
                .fullScreenCover(isPresented: $shet, onDismiss:{
                    manger.start()
                },
                content:{
                    showImage(Viewsheet: $shet,select_url: $selected_url, image_url: $image_url, select_image: $selected_image)
                    
                })
            }
            arrow( is_fade: $manger.is_fade, is_anime: $manger.is_anime, is_move: $manger.is_move )
        }
        
        .mask(RoundedRectangle(cornerRadius: viewstate.width.magnitude, style: .continuous))
        .scaleEffect(viewstate.width / 500 + 1)
        .gesture(
            DragGesture()
                .onChanged{value in
                    manger.reset()
                    manger.start()
                    if value.startLocation.x > UIScreen.main.bounds.width - 100{
                        viewstate = value.translation
                    }
                }
                .onEnded({value in
                    
                    if viewstate.width < -50{
                        show = false
                    }
                    withAnimation{
                        viewstate = .zero
                    }
                })
        )
        .gesture(
            TapGesture()
                .onEnded{
                    manger.reset()
                    manger.start()
                    print("touch!")
                }
        )
        .onAppear(){
            manger.start()
            withAnimation{
                (self.Gshow = true)
            }
        }
        .ignoresSafeArea()
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView(image_url:.constant([change_name_to_url(image_name: "")]), show: .constant(true))
    }
}

struct arrow: View {
    
    @State var xOffset: CGFloat = 0
    @Binding var is_fade:Bool
    @Binding var is_anime:Bool
    @Binding var is_move:Bool
    var body: some View{
        VStack{
            Spacer()
            HStack{
                Spacer()
                    Text("スワイプでホームヘ戻る")
                    .font(.system(size: 20))
                    Image(systemName: "arrowshape.left.fill")
                    .font(.system(size: 75))
            }
            .foregroundColor(Color.black.opacity(0.8))
            .offset(x:is_move ? 0:20,y:0)
            .animation(Animation.easeInOut(duration: 1.0)
                .delay(1.0)
                .repeatForever(autoreverses: true),value:is_anime)
            .opacity(is_fade ? 1.0 : 0.0)
            .animation(Animation.linear, value: is_fade)

        }
    }
}

class ManagerClass: ObservableObject {
    @Published var is_fade = false
    @Published var is_anime = false
    @Published var is_move  = false

    @Published var Elapsed_time: Int = 0
    @Published var isTimerRunning: Bool = false
    
    var timer = Timer()
    
    func start() {
        isTimerRunning = true
        self.stop()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ timer in
            self.Elapsed_time += 1
            print(self.Elapsed_time)
            if self.Elapsed_time >= 3{
                self.is_fade = true
                self.is_anime = true
                self.is_move = true
                self.stop()
            }
        }
    }
    func stop() {
        isTimerRunning = false
        timer.invalidate()
    }
    func reset() {
        Elapsed_time = 0
        self.is_fade = false
        self.is_anime = false
        self.is_move = false
    }
    
}
