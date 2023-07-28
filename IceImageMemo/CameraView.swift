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
    @Environment(\.openURL) var openurl
    //@StateObject var camera : CameraModel
    @StateObject var camera = CameraModel()
    @State var show = false
    @State var selectedTab: Tap = .day
    @State var image_url:[URL]  = all_file_url(directory_url: change_name_to_url(image_name: ""))
    @State private var scale: CGFloat = 1.0
    @State private var focusPoint: CGPoint?
    
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    //View内ではこれで呼び出せる　配列格納は228行目いじって〜
    @Environment(\.scenePhase) var scenephase
    
    var body: some View{
        let _ = CameraView._printChanges()
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
                .disabled(camera.is_button_invalid)
                if camera.isShowingbutton {
                    Button {
                        //ここにurlを配列に格納するコード書く//
                        //camera.save_detectedQRCode
                        //String型で格納されている
                        change_directory_and_save_text(mode: camera.variable2, text: camera.save_detectedQRCode!)
                        
                        print(camera.save_detectedQRCode!)
                        if(can_openURL(url_string: camera.save_detectedQRCode!)){
                            openurl(URL(string: camera.save_detectedQRCode!)!)
                        }else{
                            let google_url = jump_google_Search(word: camera.save_detectedQRCode!)
                            print(google_url!)
                            openurl(google_url!)
                        }
                        //openURL(URL(string: camera.save_detectedQRCode!)!)

                    }label: {
                        if let qr_string = camera.save_detectedQRCode{
                            Text(qr_string)
                        }else{
                            Text("")
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .offset(y: -50) // ボタンの位置を調整
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
//        .alert(isPresented: $camera.isShowingAlert) {
//            Alert(title: Text("QRコードを読み取りました"), message: Text(camera.alertMessage), dismissButton: .default(Text("OK")))
//        }
        .onAppear(perform:{
            camera.Check()
        })
        .onChange(of: scenephase){phase in
            switch phase{
            case .active:
                print("act")
                camera.isShowingbutton = false
            case .inactive:
                print("inact")
            case .background:
                print("back")
            default:
                print("...")
            }
        }
    }
}

//CameraSetting
class CameraModel: NSObject,ObservableObject,AVCapturePhotoCaptureDelegate,AVCaptureMetadataOutputObjectsDelegate{
    @Published var isTaken = false
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var output = AVCapturePhotoOutput()
    @Published var preview : AVCaptureVideoPreviewLayer!
    @Published var capturedImage: UIImage?
    @Published var variable2: Int = 1
    @Published var is_button_invalid:Bool = false
    @Published var detectedQRCode: String?
    @Published var isShowingbutton = false
    @Published var save_detectedQRCode :String?
    var timer:Timer?

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
            

            //写真とる設定
            let input = try AVCaptureDeviceInput(device: device!)
            
            if self.session.canAddInput(input){
                self.session.addInput(input)
            }
            
            if self.session.canAddOutput(self.output){
                self.session.addOutput(self.output)
            }
            
            //qr読む設定
            let metadataOutput = AVCaptureMetadataOutput()
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)

                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            } else {
                print("Failed to add metadata output")
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
                /*
                Task{
                    let c_image = turnImage
                    await waitfunc(mode: variable2, uiimage: c_image)
                }
                */
                //change_directory_and_save(mode: variable2, uiimage_data: turnImage)
                is_button_invalid = false
            } else {
                print("Captured image is nil")
            }
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           metadataObj.type == .qr,
           let qrCodeString = metadataObj.stringValue {
            print("Detected QR Code: \(qrCodeString)")
            detectedQRCode = qrCodeString
            save_detectedQRCode = detectedQRCode
            isShowingbutton = true
            //四隅のざひょう
            //print(metadataObj.corners)
        } else {
            //print(save_detectedQRCode!)
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                self.isShowingbutton = false
                self.timer = nil
            }
            //isShowingbutton = false
            detectedQRCode = nil
            print("No QR Code detected.")
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

func waitfunc(mode: Int, uiimage: UIImage) async {
    change_directory_and_save(mode: mode, uiimage_data: uiimage)
}
