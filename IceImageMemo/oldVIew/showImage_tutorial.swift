//
//  showImage.swift
//  IceImageMemo
//
//  Created by 山本聖留 on 2023/09/05.
//

import SwiftUI

struct showimage_tutorial: View {
    @State var show = false
    @Binding var Viewsheet:Bool
    @State var tap_count:Int = 0
    var photo_library = UIImage(named: "m3")!
    @State var offset:CGSize = .zero // drag value
    @State var lastOffset: CGSize = .zero // hold last drag value
    @State var scale:CGFloat = 1.0 // pinch scale value
    @State var lastScale: CGFloat = 1.0 // hold last scale value
    @State var imageWidth:CGFloat  = UIScreen.main.bounds.width - 40
    @State var imageHeight:CGFloat = 470 // object height for initial placement
    
    var dragGesture: some Gesture {
            DragGesture()
                .onChanged {
                    if show {
                        scale = 1.0
                        imageWidth = 0.0
                        imageHeight = 0.0
                    }else{
                        offset = CGSize(width: lastOffset.width + $0.translation.width/lastScale, height: lastOffset.height + $0.translation.height/lastScale)
                        print(offset)
                        print(lastScale)
                        if(offset.width > (imageWidth/2-imageWidth/2/lastScale)){
                            offset.width = (imageWidth/2-imageWidth/2/lastScale)
                        }
                        if(offset.width < -(imageWidth/2-imageWidth/2/lastScale)){
                            offset.width = -(imageWidth/2-imageWidth/2/lastScale)
                        }
                        if(offset.height > (imageHeight/2-imageHeight/2/lastScale)){
                            offset.height = (imageHeight/2-imageHeight/2/lastScale)
                        }
                        if(offset.height < -(imageHeight/2-imageHeight/2/lastScale)){
                            offset.height = -(imageHeight/2-imageHeight/2/lastScale)
                        }
                    }

                }
                .onEnded{ _ in
                    lastOffset = offset
                }
        }

    var scaleGuesture: some Gesture {
            MagnificationGesture()
                .onChanged {
                    if show {
                        scale = 1.0
                        imageWidth = 0.0
                        imageHeight = 0.0
                        
                    }else{
                        scale = $0 * lastScale
                        if scale < 1.0 {
                            scale = 1.0
                        }
                        offset = CGSize(width: lastOffset.width, height: lastOffset.height)
                        if(offset.width > (imageWidth/2-imageWidth/2/scale)){
                            offset.width = (imageWidth/2-imageWidth/2/scale)
                        }
                        if(offset.width < -(imageWidth/2-imageWidth/2/scale)){
                            offset.width = -(imageWidth/2-imageWidth/2/scale)
                        }
                        if(offset.height > (imageHeight/2-imageHeight/2/scale)){
                            offset.height = (imageHeight/2-imageHeight/2/scale)
                        }
                        if(offset.height < -(imageHeight/2-imageHeight/2/scale)){
                            offset.height = -(imageHeight/2-imageHeight/2/scale)
                        }
                    }

                }
                .onEnded{ _ in
                    lastScale = scale
                    lastOffset = offset
                }
        }

    var body: some View {
        ZStack{
            Color.white
                .ignoresSafeArea()
            ZStack(alignment: .top){
                    VStack{
                        Button(action: {
                            print("remove")
                            Viewsheet.toggle()
                        }, label: {
                            ZStack{
                            
                                Image(systemName: "trash.circle")
                                    .font(.system(size: 80))
                                    .foregroundColor(.red)
                                    .padding(.bottom)
                                    .padding(.top)
                            
                                   
                            }
                            
                        })
                        
                        
                        Label("あと1日", systemImage: "")
                                   .font(.largeTitle)
                                   .foregroundColor(.red)
                                   .padding(.bottom)
                        
                              
                        
                    }
                
                .padding(30)
                .frame(maxWidth: show ? .infinity : UIScreen.main.bounds.width - 60,maxHeight:show ? .infinity : 260, alignment: .top)
                .offset(y: show ? 450 : 40)
                    //Image(uiImage: select_image)
                        Image(uiImage: photo_library)
                            .resizable()
                            .aspectRatio(2.5/4,contentMode: .fit)
                            .scaledToFill()
                            .cornerRadius(20)
                            .onTapGesture {
                                scale = 1.0
                                offset = CGSize(width: 0, height: 0)
                                imageWidth = .infinity
                                imageHeight = 450
                                withAnimation(.spring(response: 0.4,dampingFraction: 0.6)){
                                    self.show.toggle()
                                }
                                tap_count += 1
                            }
                        
                            .frame(maxWidth: show ? .infinity : UIScreen.main.bounds.width - 40,maxHeight:show ?  450 : 460)
                            .offset(offset)
                            .scaleEffect(scale)
                            .gesture(dragGesture)
                            .simultaneousGesture(scaleGuesture)
                        
                            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                }
                        .overlay(alignment: .topTrailing, content: {
                            Image(systemName: "xmark.circle")
                                .font(.largeTitle)
                                .foregroundColor(.black)
                                .padding(show ? 30 : 20)
                                .onTapGesture {
                                    Viewsheet.toggle()
                                }
                            
                        })
            
            //spotlight
            if tap_count == 0{
                SpotlightView(content: showImage_tutorialView())
            }
        }

                }
            }


            struct showImage_tutorial_Previews: PreviewProvider {
                static var previews: some View {
                    showImage(Viewsheet: .constant(false),select_url: .constant(change_name_to_url(image_name: "")), image_url: .constant([change_name_to_url(image_name: "")]), select_image: .constant(read_image2(image_url: change_name_to_url(image_name: ""))))
                }
            }
