/*
 CameraService.swift
 --------------------------------------------
 デバイスカメラで写真を撮るための「サービス層」と、
 そのプレビューを SwiftUI に橋渡しする UI 部分をひとまとめにしたファイルです。

 ■ 何をする？
 - CameraService（プロトコル）
   セッション取得 / 初期設定 / 起動停止 / 撮影 / 撮影データ配信を定義。
 - CameraServiceImpl（実装）
   1) 権限確認 → 2) AVCaptureSession 構成 → 3) 起動/停止 →
   4) シャッター実行 → 5) Combine（photoPublisher）でJPEGデータを配信。
   セッションの開始/停止は専用キュー（sessionQueue）でスレッドセーフに実行。
 - AVCapturePhotoCaptureDelegate 拡張
   写真撮影完了時に Data を取り出して PassthroughSubject から配信。
 - CameraPreviewContainerView（UIView）
   AVCaptureVideoPreviewLayer を貼ったシンプルなプレビュー用ビュー。
   レイアウト時に portrait へ固定 & resizeAspectFill。
 - CameraServiceView（UIViewRepresentable）
   上記 UIView を SwiftUI から扱うためのブリッジ。

 ■ 使い方（最小例）
   let camera = CameraServiceImpl()
   .onAppear {
     Task { await camera.configure(); camera.startRunning() }
   }
   .onDisappear {
     camera.stopRunning()
   }
   CameraServiceView(session: camera.session)
   Button("Shutter") { camera.capturePhoto() }
   .onReceive(camera.photoPublisher) { data in
     // data は JPEG/HEIC 等の写真バイト列。保存や表示に利用。
   }

 ■ 設計メモ / 注意点
 - 権限文言（NSCameraUsageDescription）は Info.plist に必須。
 - シミュレータではカメラが使えないため、実機で動作確認を行う。
 - configure() は非同期。撮影や起動は configure 完了後に行う。
 - start/stop は sessionQueue で実行（UI スレッドをブロックしない）。
 - photoPublisher の受信は呼び出しスレッド起点なので、
   UI 更新時は DispatchQueue.main.async などでメインに戻す。
 - 画質や機能拡張：
   session.sessionPreset = .photo のほか、必要に応じて
   photoOutput.isHighResolutionCaptureEnabled = true などを設定すると良い。
 - エラーハンドリングは print のみ（必要に応じて Result 型や独自 Error を導入）。
 - 向き固定：layoutSubviews で portrait を強制。回転対応する場合は要調整。
 - 前/背面切替・フラッシュ・露出/フォーカス等は AVCaptureDevice の設定を追加実装。

 ■ 拡張アイデア
 - 撮影フォーマット（HEIF/RAW）やメタデータ抽出
 - ライブフォト / 連写 / タイマー撮影
 - セッション中断（バックグラウンド）対応の通知ハンドリング
*/

import UIKit
import SwiftUI
import Combine
import AVFoundation

protocol CameraService {
    var session: AVCaptureSession { get }
    var photoPublisher: AnyPublisher<Data, Never> { get }
    func configure() async
    func startRunning()
    func stopRunning()
    func capturePhoto()
}

final class CameraServiceImpl: NSObject, CameraService {
    var session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var deviceInput: AVCaptureDeviceInput?
    private let photoOutput = AVCapturePhotoOutput()
    private let photoSubject = PassthroughSubject<Data, Never>()
    var photoPublisher: AnyPublisher<Data, Never> {
        photoSubject.eraseToAnyPublisher()
    }
    
    func checkAuthorization() -> AVAuthorizationStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        return status
    }
    
    func configure() async {
        let status = checkAuthorization()
        if status == .notDetermined {
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            guard granted else { return }
        }
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else { return }
        
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        if let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                    self.deviceInput = input
                }
            } catch {
                print("Input error:", error)
            }
        }
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        session.commitConfiguration()
    }
    
    func startRunning() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func stopRunning() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraServiceImpl: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error {
            print("Photo capture error: \(error)")
            return
        }
        if let data = photo.fileDataRepresentation() {
            photoSubject.send(data)
        }
    }
}

final class CameraPreviewContainerView: UIView {
    private let previewLayer: AVCaptureVideoPreviewLayer
    init(session: AVCaptureSession) {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        super.init(frame: .zero)
        backgroundColor = .black
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
        if let conn = previewLayer.connection, conn.isVideoOrientationSupported {
            conn.videoOrientation = .portrait
        }
    }
}

struct CameraServiceView: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> CameraPreviewContainerView {
        CameraPreviewContainerView(session: session)
    }
    func updateUIView(_ uiView: CameraPreviewContainerView, context: Context) {}
}
