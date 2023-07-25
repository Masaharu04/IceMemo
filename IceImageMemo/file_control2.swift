//
//  file_control2.swift
//  IceImageMemo
//
//  Created by Masaharu on 2023/07/25.
//

import SwiftUI
import Foundation

//2.0
func delete_url_last_component(image_url: URL) -> URL{
    let parent_url = image_url.deletingLastPathComponent()
    return parent_url
}

//2.0
//自動削除
func auto_remove_image(all_image_url: [URL]){
    let day_directory = change_name_to_url(image_name: "day")
    let week_directory = change_name_to_url(image_name: "week")
    let month_directory = change_name_to_url(image_name: "month")
    let year_directory = change_name_to_url(image_name: "year")
    
    for image_url in all_image_url{
        let parent_url = delete_url_last_component(image_url: image_url)
        switch parent_url{
        case day_directory:
            remove_image_judge_by_time(image_url: image_url, remove_time: 10)
        case week_directory:
            remove_image_judge_by_time(image_url: image_url, remove_time: 20)
        case month_directory:
            remove_image_judge_by_time(image_url: image_url, remove_time: 40)
        case year_directory:
            remove_image_judge_by_time(image_url: image_url, remove_time: 60)
        default:
            continue
        }
    }
}

//2.0
func all_file_url_in_a_directory(directory_url: URL) -> [URL]{
    let filemanager = FileManager.default
    var file_paths: [String] = []
    var file_urls: [URL] = []
    do {
        file_paths = try filemanager.subpathsOfDirectory(atPath: directory_url.path)
    } catch{
        print(error)
    }
    for file_path in file_paths {
        file_urls.append(directory_url.appendingPathComponent(file_path))
    }
    return file_urls
}

//2.0
func all_file_url(directory_url: URL) -> [URL]{
    var all_day_url: [URL] = [],all_week_url: [URL] = [],all_month_url: [URL] = [],all_year_url: [URL] = []
    
    let filemanager = FileManager.default
    let day_url = change_name_to_url(image_name: "day")
    let week_url = change_name_to_url(image_name: "week")
    let month_url = change_name_to_url(image_name: "month")
    let year_url = change_name_to_url(image_name: "year")
    if filemanager.fileExists(atPath: day_url.path){
        all_day_url = all_file_url_in_a_directory(directory_url: day_url)
    }
    if filemanager.fileExists(atPath: day_url.path){
        all_week_url = all_file_url_in_a_directory(directory_url: week_url)
    }
    if filemanager.fileExists(atPath: day_url.path){
        all_month_url = all_file_url_in_a_directory(directory_url: month_url)
    }
    if filemanager.fileExists(atPath: day_url.path){
        all_year_url = all_file_url_in_a_directory(directory_url: year_url)
    }
    let all_url = all_day_url + all_week_url + all_month_url + all_year_url
    print(all_url)
    return all_url
}

//2.0
func make_new_image_name() -> String{
    let jp_date = change_jp_date(day1:Date())
    let image_name = "\(jp_date).jpg"
    return image_name
}

//2.0
func make_directory(directory_url: URL){
    let filemanager = FileManager.default
    if filemanager.fileExists(atPath: directory_url.path){
        return
    }
    do{
        try filemanager.createDirectory(atPath: directory_url.path, withIntermediateDirectories: false)
    } catch {
        print("can't make directory")
    }
}

func make_directory_2(){
    let day_directory = change_name_to_url(image_name: "day")
    make_directory(directory_url: day_directory)
    let week_directory = change_name_to_url(image_name: "week")
    make_directory(directory_url: week_directory)
    let month_directory = change_name_to_url(image_name: "month")
    make_directory(directory_url: month_directory)
    let year_directory = change_name_to_url(image_name: "year")
    make_directory(directory_url: year_directory)
}

//2.0
func change_directory_and_save(mode: Int, uiimage_data: UIImage){
    switch mode{
    case 1:
        let directory_name = "day"
        let image_name = make_new_image_name()
        let image_url =  change_name_to_url(image_name: "\(directory_name)/\(image_name)")
        write_image(image_url: image_url, uiimage_data: uiimage_data)
    case 2:
        let directory_name = "week"
        let image_name = make_new_image_name()
        let image_url =  change_name_to_url(image_name: "\(directory_name)/\(image_name)")
        write_image(image_url: image_url, uiimage_data: uiimage_data)
    case 3:
        let directory_name = "month"
        let image_name = make_new_image_name()
        let image_url =  change_name_to_url(image_name: "\(directory_name)/\(image_name)")
        write_image(image_url: image_url, uiimage_data: uiimage_data)
    case 4:
        let directory_name = "year"
        let image_name = make_new_image_name()
        let image_url =  change_name_to_url(image_name: "\(directory_name)/\(image_name)")
        write_image(image_url: image_url, uiimage_data: uiimage_data)
    default:
        return
    }
}

//2.1
func sort_url(all_image_url :[URL]) -> [URL]{
    struct url_and_path {
        let image_url: URL
        let image_path: String
    }
    var url_and_path_array: [url_and_path] = []
    for image_url in all_image_url{
        let delete_extension = image_url.deletingPathExtension()
        let image_name = delete_extension.lastPathComponent
        url_and_path_array.append(url_and_path(image_url: image_url, image_path: image_name))
    }
    url_and_path_array.sort(by: {$0.image_path < $1.image_path})
    let result_urls = url_and_path_array.map({(url_and_path) -> URL in return url_and_path.image_url})
    print("----------------------------\n\(result_urls)\n-----------------------------")
    return result_urls
}

func judge_format(file_url: URL) -> String{
    let image_url = change_name_to_url(image_name: "abc.jpeg")
    let ans = image_url.pathExtension
    print(ans)
    return ans
}


func write_text(text_url: URL,text: String){
    do {
        try text.write(to: text_url, atomically: true, encoding: .utf8)
    } catch {
        print("書き込み失敗")
    }
}

func read_text(text_url: URL) -> String{
    var text: String = ""
    do{
        text = try String(contentsOf: text_url, encoding: .utf8)
    } catch {
        print("読み込み失敗")
    }
    return text
}

