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
    
    @GestureState private var gestureScale: CGFloat = 1.0
    // 画像移動の位置を保持する変数
    @GestureState private var gesturePosition: CGSize = .zero
    @State var scale :CGFloat = 1.0
    @State var position :CGSize = .zero
    

    var body: some View {
        ZStack(alignment: .top){
                VStack{
                    Button(action: {
                        print("remove")
                        //削除ボタンの処理
                        if let view_imageURL = select_url{
                            remove_image(image_url:view_imageURL)
                            //  image_url.removeAll(where:{$0 == view_imageURL})
                            image_url = all_file_url(directory_url: change_name_to_url(image_name: ""))
                            auto_remove_image(all_image_url: image_url)
                            image_url = all_file_url(directory_url: change_name_to_url(image_name: ""))
                            image_url = sort_url(all_image_url :image_url)
                            print(image_url)
                        }else{
                            
                        }
                        Viewsheet.toggle()
                    }, label: {
                        
                        ZStack{
                            
                            Image(systemName: "trash.circle")
                                .font(.system(size: 80))
                                .foregroundColor(.red)
                                .padding(.bottom, 20)
                                .padding(.top, 50)
                        }
                        
                    })
                    
                    Label("あと\(remaining_days(image_url: select_url!))秒", systemImage: "")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                        .padding(.bottom, 60)
                    
                }
                
                .padding(30)
                .frame(maxWidth: show ? .infinity : UIScreen.main.bounds.width - 60,maxHeight:show ? .infinity : 260, alignment: .top)
                .offset(y: show ? 450 : 0)
                //Image(uiImage: select_image)
                if let view_image = select_image{
                    Image(uiImage:view_image)
                        .resizable()
                        .aspectRatio(3024.0/4032.0, contentMode: .fit)
                        .scaledToFill()
                        .cornerRadius(20)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4,dampingFraction: 0.6)){
                                self.show.toggle()
                            }
                        }
                        .gesture(
                            MagnificationGesture()
                                .updating($gestureScale) { value, scale, _ in
                                    // ピンチイン・アウトによるスケール値を更新
                                    scale = value
                                }
                                .onEnded { scaleValue in
                                    // スケール値の上限と下限を制限
                                    self.scale *= scaleValue
                                    self.scale = max(min(self.scale, 3.0), 1.0)
                                }
                        )
                        .gesture(
                            DragGesture()
                                .updating($gesturePosition) { value, position, _ in
                                    // 画像移動の位置を更新
                                    position = value.translation
                                }
                                .onEnded { dragValue in
                                    // 画像移動の位置を確定
                                    self.position.width += dragValue.translation.width
                                    self.position.height += dragValue.translation.height
                                }
                        )
                        .offset(x: position.width, y: position.height)
                        .scaleEffect(scale)

                        .frame(maxWidth: show ? .infinity : UIScreen.main.bounds.width - 40,maxHeight:show ?  500 : 470)
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    
                }else{
                    Image("m4")
                        .resizable()
                        .scaledToFill()
                        .cornerRadius(20)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4,dampingFraction: 0.6)){
                                self.show.toggle()
                            }
                        }
                        .frame(maxWidth: show ? .infinity : UIScreen.main.bounds.width - 40,maxHeight:show ?  450 : 360)
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                }
            }
            .overlay(alignment: .topTrailing, content: {
                Image(systemName: "xmark.circle")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(show ? 30 : 20)
                    .onTapGesture {
                        image_url = all_file_url(directory_url: change_name_to_url(image_name: ""))
                        auto_remove_image(all_image_url: image_url)
                        image_url = all_file_url(directory_url: change_name_to_url(image_name: ""))
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
                          label: { Image(systemName: "square.and.arrow.up")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(show ? 30 : 17)
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
        showImage(Viewsheet: .constant(false),select_url: .constant(change_name_to_url(image_name: "")), image_url: .constant([change_name_to_url(image_name: "")]), select_image: .constant(read_image2(image_url: change_name_to_url(image_name: ""))))
    }
}
