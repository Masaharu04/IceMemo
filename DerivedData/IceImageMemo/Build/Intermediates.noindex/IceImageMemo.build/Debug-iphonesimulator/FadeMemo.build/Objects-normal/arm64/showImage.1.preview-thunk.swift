import func SwiftUI.__designTimeFloat
import func SwiftUI.__designTimeString
import func SwiftUI.__designTimeInteger
import func SwiftUI.__designTimeBoolean

#sourceLocation(file: "/Users/masaharu/Documents/xcode/IceMemo/IceImageMemo/showImage.swift", line: 1)
//
//  showImage.swift
//  IceImageMemo
//
//  Created by Masaharu on 2023/07/25.
//

import SwiftUI

struct showImage: View {
    @State var show = false
    @Binding var Viewsheet:Bool
    @Binding var select_url :URL?
    @Binding var image_url :[URL]
    @Binding var select_image :UIImage?
    
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
        ZStack(alignment: .top){
                VStack{
                   
                    Button(action: {
                        print(__designTimeString("#3654_0", fallback: "remove"))
                        //削除ボタンの処理
                        if let view_imageURL = select_url{
                            remove_image(image_url:view_imageURL)
                            //  image_url.removeAll(where:{$0 == view_imageURL})
                            image_url = all_file_url(directory_url: change_name_to_url(image_name: __designTimeString("#3654_1", fallback: "")))
                            auto_remove_image(all_image_url: image_url)
                            image_url = all_file_url(directory_url: change_name_to_url(image_name: __designTimeString("#3654_2", fallback: "")))
                            image_url = sort_url(all_image_url :image_url)
                            print(image_url)
                        }else{
                            
                        }
                        Viewsheet.toggle()
                    }, label: {
                        
                        ZStack{
                        
                            Image(systemName: __designTimeString("#3654_3", fallback: "trash.circle"))
                                .font(.system(size: __designTimeInteger("#3654_4", fallback: 80)))
                                .foregroundColor(.red)
                                .padding(.bottom)
                                .padding(.top)
                        
                               
                        }
                        
                    })
                    
                    
                    Label("あと\(remaining_days(image_url: select_url!))日", systemImage: __designTimeString("#3654_5", fallback: ""))
                               .font(.largeTitle)
                               .foregroundColor(.red)
                               .padding(.bottom)
                    
                          
                    
                }
            
            .padding(__designTimeInteger("#3654_6", fallback: 30))
            .frame(maxWidth: show ? .infinity : UIScreen.main.bounds.width - __designTimeInteger("#3654_7", fallback: 60),maxHeight:show ? .infinity : __designTimeInteger("#3654_8", fallback: 260), alignment: .top)
            .offset(y: show ? __designTimeInteger("#3654_9", fallback: 450) : __designTimeInteger("#3654_10", fallback: 40))
                //Image(uiImage: select_image)
                if let view_image = select_image{
                    Image(uiImage:view_image)
                        .resizable()
                        .aspectRatio(__designTimeFloat("#3654_11", fallback: 2.5)/__designTimeInteger("#3654_12", fallback: 4),contentMode: .fit)
                        .scaledToFill()
                        .cornerRadius(__designTimeInteger("#3654_13", fallback: 20))
                        .onTapGesture {
                            scale = __designTimeFloat("#3654_14", fallback: 1.0)
                            offset = CGSize(width: __designTimeInteger("#3654_15", fallback: 0), height: __designTimeInteger("#3654_16", fallback: 0))
                            imageWidth = .infinity
                            imageHeight = __designTimeInteger("#3654_17", fallback: 450)
                            withAnimation(.spring(response: __designTimeFloat("#3654_18", fallback: 0.4),dampingFraction: __designTimeFloat("#3654_19", fallback: 0.6))){
                                self.show.toggle()
                            }
                        }
                    
                        .frame(maxWidth: show ? .infinity : UIScreen.main.bounds.width - __designTimeInteger("#3654_20", fallback: 40),maxHeight:show ?  __designTimeInteger("#3654_21", fallback: 450) : __designTimeInteger("#3654_22", fallback: 460))
                        .offset(offset)
                        .scaleEffect(scale)
                        .gesture(dragGesture)
                        .simultaneousGesture(scaleGuesture)
                    
                        .clipShape(RoundedRectangle(cornerRadius: __designTimeInteger("#3654_23", fallback: 30), style: .continuous))
                    
                }else{
                    Image(__designTimeString("#3654_24", fallback: "m4"))
                        .resizable()
                        .scaledToFill()
                        .cornerRadius(__designTimeInteger("#3654_25", fallback: 20))
                        .onTapGesture {
                            withAnimation(.spring(response: __designTimeFloat("#3654_26", fallback: 0.4),dampingFraction: __designTimeFloat("#3654_27", fallback: 0.6))){
                                self.show.toggle()
                            }
                        }
                        .frame(maxWidth: show ? .infinity : UIScreen.main.bounds.width - __designTimeInteger("#3654_28", fallback: 40),maxHeight:show ?  __designTimeInteger("#3654_29", fallback: 450) : __designTimeInteger("#3654_30", fallback: 460))
                        .clipShape(RoundedRectangle(cornerRadius: __designTimeInteger("#3654_31", fallback: 30), style: .continuous))
                }
            }
                    .overlay(alignment: .topTrailing, content: {
                        Image(systemName: __designTimeString("#3654_32", fallback: "xmark.circle"))
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding(show ? __designTimeInteger("#3654_33", fallback: 30) : __designTimeInteger("#3654_34", fallback: 20))
                            .onTapGesture {
                                image_url = all_file_url(directory_url: change_name_to_url(image_name: __designTimeString("#3654_35", fallback: "")))
                                auto_remove_image(all_image_url: image_url)
                                image_url = all_file_url(directory_url: change_name_to_url(image_name: __designTimeString("#3654_36", fallback: "")))
                                image_url = sort_url(all_image_url :image_url)
                                Viewsheet.toggle()
                            }
                        
                    })
                    .overlay(alignment: .topLeading, content: {
                        let photo = Image(uiImage: select_image!)
                        //print(photo)
                        let filename = get_file_name(image_url: select_url!)
                        ShareLink(item: photo,
                                  preview: SharePreview(filename,image:photo),
                                  label: { Image(systemName: __designTimeString("#3654_37", fallback: "square.and.arrow.up"))
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding(show ? __designTimeInteger("#3654_38", fallback: 30) : __designTimeInteger("#3654_39", fallback: 17))
                        })
                    })
                    .edgesIgnoringSafeArea(.all)
             
                }
            }
            struct Photo: Identifiable {
                var id = UUID()
                var image: Image
                var caption: String
                var description: String
            }

            extension Photo: Transferable {
                static var transferRepresentation: some TransferRepresentation {
                    ProxyRepresentation(exporting: \.image)
                }
            }

            struct showImage_Previews: PreviewProvider {
                static var previews: some View {
                    showImage(Viewsheet: .constant(__designTimeBoolean("#3654_40", fallback: false)),select_url: .constant(change_name_to_url(image_name: __designTimeString("#3654_41", fallback: ""))), image_url: .constant([change_name_to_url(image_name: __designTimeString("#3654_42", fallback: ""))]), select_image: .constant(read_image2(image_url: change_name_to_url(image_name: __designTimeString("#3654_43", fallback: "")))))
                }
            }
