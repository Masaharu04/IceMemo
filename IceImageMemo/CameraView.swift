//
//  CameraView.swift
//  IceImageMemo
//
//  Created by Masaharu on 2023/07/25.
//

import SwiftUI
import AVFoundation

//CameraView
struct CameraView: View {
    
    //@StateObject var camera : CameraModel
    @StateObject var camera = CameraModel()
    @State var show = false
    @State var selectedTab: Tap = .day
    @State var image_url:[URL]  = all_file_url(directory_url: change_name_to_url(image_name: ""))
    @State private var scale: CGFloat = 1.0
    @State private var focusPoint: CGPoint?
    //View内ではこれで呼び出せる　配列格納は228行目いじって〜
    //camera.capture_list
    
    var body: some View{
        ZStack{
            //let cameraModel = CameraModel(variable2: $variable2)
            CameraPreview(camera: camera)
                .ignoresSafeArea(.all, edges: .all)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            camera.setZoomFactor(zoomFactor: value)
                        }
                        .onEnded { value in
                            camera.setZoomFactor(zoomFactor: value)
                        }
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            focusPoint = value.location
                            camera.setFocusPoint(point: focusPoint!)
                        }
                )

            VStack{
                Button{
                    image_url = all_file_url(directory_url: change_name_to_url(image_name: ""))
                    auto_remove_image(all_image_url: image_url)
                    image_url = all_file_url(directory_url: change_name_to_url(image_name: ""))
                    image_url = sort_url(all_image_url :image_url)
                    show.toggle()
                }label: {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 300, height: 500)
                }
                Spacer()
                //{}この中にカメラの処理を実装する
                Button(action: { camera.takePic()
                    camera.is_button_invalid = true
                }, label: {
                    ZStack{
                        Circle()
                            .fill(Color.white)
                            .frame(width: 65, height: 65)
                        Circle()
                            .stroke(Color.white,lineWidth: 2)
                            .frame(width: 75, height: 75)
                    }
                    
                }).disabled(camera.is_button_invalid)
                
                
                .fullScreenCover(isPresented: $show){
                    GridView(image_url: $image_url, show: $show)
                }
                
                //timeBar
                HStack{
                    ForEach(tapItems){ item in
                        Button(action: {
                            selectedTab = item.tap
                            
                            if selectedTab == .day {
                                camera.variable2 = 1
                            } else {
                                
                            }
                            if selectedTab == .week {
                                camera.variable2 = 2
                                
                            } else {
                                
                                
                            }
                            if selectedTab == .month {
                                camera.variable2 = 3
                                
                            } else {
                                
                                
                            }
                            if selectedTab == .year {
                                camera.variable2 = 4
                                
                            } else {
                               
                                
                            }
                            
                        },  label: {
                            VStack(spacing: 0){
                                Image(systemName: item.icon)
                                    .symbolVariant(.fill)
                                    .font(.system(size: 26.5))
                                    .frame(width: 50, height: 50)
                                    
                            }
                            .frame(maxWidth: .infinity)
                            
                        })
                        .foregroundStyle(selectedTab == item.tap ? Color.red:.secondary)
                        
                    }
                }
              
                    
                
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            
            }
            
            Spacer()
            
            
        }
        .onAppear(perform:{
            camera.Check()
        })
    }
}

//CameraSetting
class CameraModel: NSObject,ObservableObject,AVCapturePhotoCaptureDelegate{
    @Published var isTaken = false
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var output = AVCapturePhotoOutput()
    @Published var preview : AVCaptureVideoPreviewLayer!
    @Published var capturedImage: UIImage?
    @Published var variable2: Int = 1
    @Published var is_button_invalid:Bool = false
    @Published var capture_list :[UIImage]?
    private var device: AVCaptureDevice?
    //カメラの権限があるかCheck!
    func Check() {
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
            setUp()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video){
                (status)in
                if status{
                    self.setUp()
                }
            }
        case .denied:
            self.alert.toggle()
            return
            
        default:
            return
            
        }
    }
    //Input,OutputのsetUp
    func setUp() {
        
        do{
            self.session.beginConfiguration()
        
             device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            

            
            let input = try AVCaptureDeviceInput(device: device!)
            
            if self.session.canAddInput(input){
                self.session.addInput(input)
            }
            
            if self.session.canAddOutput(self.output){
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
        }
        
        catch{
            print(error.localizedDescription)
        }
    }
    
    func takePic() {
        let photoOutput = output
        let photoSettings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Failed to capture photo: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation()else {
            print("Failed to convert image data to UIImage")
            return
        }
        let capturedImage = UIImage(data: imageData)
        //こいつでcameraViewに飛ばしてる？
        DispatchQueue.main.async { [self] in
            self.capturedImage = capturedImage
            if let capturedImage = capturedImage {
                let turnImage = turn_image(capturedImage)
                //capturedImage.write(to: capture_list)
                print(variable2)
                change_directory_and_save(mode: variable2, uiimage_data: turnImage)
                is_button_invalid = false
                    
                    } else {
                        print("Captured image is nil")
                    }
        }
    }
    
    func setZoomFactor(zoomFactor: CGFloat) {
            if let device = device {
                do {
                    try device.lockForConfiguration()
                    defer { device.unlockForConfiguration() }
                    let zoomFactor = max(1.0, min(zoomFactor, device.activeFormat.videoMaxZoomFactor))
                    device.videoZoomFactor = zoomFactor
                } catch {
                    print("Error setting zoom factor: \(error.localizedDescription)")
                }
            }
        }
    func setFocusPoint(point: CGPoint) {
            if let device = device {
                do {
                    try device.lockForConfiguration()
                    defer { device.unlockForConfiguration() }
                    
                    if device.isFocusPointOfInterestSupported {
                        device.focusPointOfInterest = point
                        device.focusMode = .autoFocus
                    }
                } catch {
                    print("Error setting focus point: \(error.localizedDescription)")
                }
            }
        }
    
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera : CameraModel
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        camera.session.startRunning()
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
