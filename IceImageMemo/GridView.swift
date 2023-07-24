//
//  GridView.swift
//  IceImageMemo
//
//  Created by Masaharu on 2023/07/25.
//

import SwiftUI

struct GridView: View {
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
        ScrollView{
            LazyVGrid(columns: columns){
                //let is_bool = print_view(url_image:image_url)
                ForEach(image_url.indices,id: \.self){index in
                     let is_exist = check_image_exist(image_url: image_url[index])
                    if is_exist {
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
                            }
                    }
                }
            }
            .padding(.horizontal,12)
            .padding(.top,60)
            
            .fullScreenCover(isPresented: $shet, content:{
                showImage(Viewsheet: $shet,select_url: $selected_url, image_url: $image_url, select_image: $selected_image)
                
            })
            
        }
        
        .mask(RoundedRectangle(cornerRadius: viewstate.width.magnitude, style: .continuous))
        .scaleEffect(viewstate.width / 500 + 1)
        .gesture(
            DragGesture()
                .onChanged{value in
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
        .onAppear(){
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
