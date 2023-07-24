//
//  file_control.swift
//  IceImageMemo
//
//  Created by Masaharu on 2023/07/25.
//

import SwiftUI
import Foundation


func write_image(image_url: URL, uiimage_data: UIImage) {
    let image_data = change_jpg(uiimage_data: uiimage_data)
    do {
        try image_data.write(to: image_url)
    } catch{
        print("書き込み失敗")
    }
}

func change_png(uiimage_data: UIImage) -> Data{
    guard let pngimage_data = uiimage_data.pngData()else {
        fatalError("変換失敗")
    }
    return pngimage_data
}

func change_jpg(uiimage_data: UIImage) -> Data{
    guard let jpgimage_data = uiimage_data.jpegData(compressionQuality: 0.5)else {
        fatalError("変換失敗")
    }
    return jpgimage_data
}

func read_image(image_url: URL) -> UIImage{
    guard let uiimage_data = UIImage(contentsOfFile: image_url.path) else{
        print(image_url)
        fatalError("読み込み失敗")
    }
    return uiimage_data
}
func read_image2(image_url: URL) -> UIImage{
    if let uiimage_data = UIImage(contentsOfFile: image_url.path){
        return uiimage_data
    }else{
        return UIImage(imageLiteralResourceName: "m4")
    }
}


func remove_image(image_url: URL){
    let filemanager = FileManager.default
    do {
        try filemanager.removeItem(at: image_url)
    } catch {
        print(error.localizedDescription)
    }
}
func remove_image2(image_url: URL){
    let filemanager = FileManager.default
    do {
        try filemanager.removeItem(at: image_url)
        
    } catch {
        print(error.localizedDescription)
    }
}

func remove_image_judge_by_time(image_url: URL, remove_time: Double){
    let create_image_date = when_make_image(image_url: image_url)
    let spend_time = compare_date(day1: create_image_date, day2: Date())
    if(spend_time > remove_time){
        remove_image(image_url: image_url)
    }
}
func change_name_to_url(image_name: String) -> URL{
    guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
        fatalError("URL取得失敗")
    }
    let fullURL = docURL.appendingPathComponent(image_name)
    return fullURL
}

//func all_file_url(directory_url: URL) -> [URL]{
//    print("yobareta!")
//    let filemanager = FileManager.default
//    var file_paths: [String] = []
//    var file_urls: [URL] = []
//    do {
//        file_paths = try filemanager.subpathsOfDirectory(atPath: directory_url.path)
//    } catch{
//        print(error)
//    }
//    for file_path in file_paths {
//        file_urls.append(directory_url.appendingPathComponent(file_path))
//    }
//    print("call_end")
//    return file_urls
//}

func check_image_exist(image_url: URL) -> Bool{
    let filemanager = FileManager.default
    let image_exist = filemanager.fileExists(atPath: image_url.path)
    print(image_exist)
    return image_exist
}

func make_new_image_url() -> URL{
    let jp_date = change_jp_date(day1:Date())
    let image_url = change_name_to_url(image_name: "\(jp_date).jpg")
    return image_url
}

func turn_image(_ image: UIImage) -> UIImage {
    if image.imageOrientation == .up {
        return image
    }
    
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
    let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return normalizedImage ?? image
}

func print_view(url_image:[URL]) -> Bool {
    print(url_image)
    return true
}

