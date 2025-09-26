//
//  date_control.swift
//  IceImageMemo
//
//  Created by Masaharu on 2023/07/25.
//

import Foundation

func compare_date(day1:Date, day2:Date) -> Double{
    let difference = day1.distance(to: day2)
    return difference
}

func when_make_image(image_url:URL) -> Date{
    let file_path = image_url.path
    let manager = FileManager()
    let attributes = try? manager.attributesOfItem(atPath: file_path)
    let file_date = attributes![.creationDate] as? Date
    return file_date!
}

func change_jp_date(day1:Date) -> String{
    let df = DateFormatter()
    df.calendar = Calendar(identifier: .gregorian)
    df.timeZone = TimeZone.current
    df.locale = Locale.current
    df.dateFormat = "yyyyMMddHHmmss"
    let jp_date = df.string(from: day1)
    return jp_date
}

//2.1
func change_seconds_to_days(image_seconds: Double) -> Int{
    let image_days :Int = Int(image_seconds/60/60/24)
    return image_days
}

//2.1
func remaining_days(image_url: URL) -> String{
    if !check_image_exist(image_url: image_url){
        return ""
    }
    let create_date = when_make_image(image_url: image_url)
    let image_seconds = compare_date(day1:create_date, day2:Date())
    let image_spend_days = change_seconds_to_days(image_seconds: image_seconds)
    var int_image_date: Int
    
    let day_directory = change_name_to_url(image_name: "day")
    let week_directory = change_name_to_url(image_name: "week")
    let month_directory = change_name_to_url(image_name: "month")
    let year_directory = change_name_to_url(image_name: "year")
    
    let parent_url = delete_url_last_component(image_url: image_url)
    switch parent_url{
    case day_directory:
        int_image_date = 1-image_spend_days-1
    case week_directory:
        int_image_date = 7-image_spend_days-1
    case month_directory:
        int_image_date = 30-image_spend_days-1
    case year_directory:
        int_image_date = 365-image_spend_days-1
    default:
        return ""
    }
    if(int_image_date < 0){
        return "-"
    }
    let string_image_date = String(int_image_date)
    return string_image_date
}
