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
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var totalOffset: CGSize = .zero


    var body: some View {
        let zoomed = scale > 1.0
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
                    let magnification = MagnificationGesture()
                        .onChanged { value in
                            self.scale = value.magnitude
                        }
                        .onEnded { scale in
                            withAnimation(.spring()) {
                                self.scale = max(self.scale, 1.0)
                            }
                        }

                    let drag = DragGesture()
                        .onChanged { value in
                            if self.scale > 1.0 {
                                self.offset = value.translation
                            }
                        }
                        .onEnded { value in
                            if self.scale > 1.0 {
                                let translation = value.translation
                                let scaledWidth = UIScreen.main.bounds.width * self.scale
                                let scaledHeight = UIScreen.main.bounds.height * self.scale

                                let frameWidth: CGFloat = show ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width - 40
                                let frameHeight: CGFloat = show ? 450 : 360

                                let minX = (scaledWidth - frameWidth) / 2
                                let maxX = frameWidth / 2 - (scaledWidth - frameWidth) / 2
                                let minY = (scaledHeight - frameHeight) / 2
                                let maxY = frameHeight / 2 - (scaledHeight - frameHeight) / 2

                                let newX = min(max(self.totalOffset.width + translation.width, -minX), maxX)
                                let newY = min(max(self.totalOffset.height + translation.height, -minY), maxY)

                                withAnimation(.spring()) {
                                    self.totalOffset = CGSize(width: newX, height: newY)
                                    self.offset = .zero
                                }
                            }
                        }
                    Image(uiImage:view_image) // 画像を表示する部分に実際の画像を指定してください
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(20)
                        .frame(maxWidth: show ? .infinity : UIScreen.main.bounds.width - 40,maxHeight:show ?  450 : 360)
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .scaleEffect(scale)
                        .offset(x: offset.width + totalOffset.width, y: offset.height + totalOffset.height)
                        .gesture(
                            SimultaneousGesture(magnification, drag)
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4,dampingFraction: 0.6)){
                                self.show.toggle()
                            }
                        }
                        //.animation(.spring())
                

//                        Image(uiImage:view_image)
//                            .resizable()
//                            .aspectRatio(3024.0/4032.0, contentMode: .fit)
//                            .scaledToFill()
//                            .cornerRadius(20)
//                            .onTapGesture {
//                                withAnimation(.spring(response: 0.4,dampingFraction: 0.6)){
//                                    self.show.toggle()
//                                }
//                            }
//                            .scaleEffect(scale)
//                            .offset(x: offset.width + totalOffset.width, y: offset.height + totalOffset.height)
//                            .gesture(
//                                MagnificationGesture()
//                                    .onChanged { value in
//                                        self.scale = value.magnitude
//                                    }
//                                    .onEnded { scale in
//                                        withAnimation(.spring()) {
//                                            self.scale = 1.0
//                                            self.totalOffset = .zero
//                                        }
//                                    }
//                            )
//                            .gesture(
//                                DragGesture()
//                                    .onChanged { value in
//                                        if self.scale > 1.0 {
//                                            self.offset = value.translation
//                                        }
//                                    }
//                                    .onEnded { value in
//                                        if self.scale > 1.0 {
//                                            let translation = value.translation
//                                            let scaledWidth = UIScreen.main.bounds.width * self.scale
//                                            let scaledHeight = UIScreen.main.bounds.height * self.scale
//
//                                            let minX = (scaledWidth - UIScreen.main.bounds.width) / 2
//                                            let maxX = UIScreen.main.bounds.width / 2 - (scaledWidth - UIScreen.main.bounds.width) / 2
//                                            let minY = (scaledHeight - UIScreen.main.bounds.height) / 2
//                                            let maxY = UIScreen.main.bounds.height / 2 - (scaledHeight - UIScreen.main.bounds.height) / 2
//
//                                            let newX = min(max(self.totalOffset.width + translation.width, -minX), maxX)
//                                            let newY = min(max(self.totalOffset.height + translation.height, -minY), maxY)
//
//                                            withAnimation(.spring()) {
//                                                self.totalOffset = CGSize(width: newX, height: newY)
//                                                self.offset = .zero
//                                            }
//                                        }
//                                    }
//                            )
//                            .simultaneousGesture(
//                                TapGesture(count: 2)
//                                    .onEnded {
//                                        withAnimation(.spring()) {
//                                            if self.scale > 1.0 {
//                                                self.scale = 1.0
//                                                self.totalOffset = .zero
//                                            } else {
//                                                self.scale = 2.0
//                                            }
//                                        }
//                                    }
//                            )
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



