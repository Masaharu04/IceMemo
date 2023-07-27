//
//  url_control.swift
//  IceImageMemo
//
//  Created by 山本聖留 on 2023/07/27.
//

import Foundation
import UIKit

func can_openURL(url_string:String)->Bool{
    if let nsurl = NSURL(string: url_string){
        return UIApplication.shared.canOpenURL(nsurl as URL)
    }
    return false
}

func jump_google_Search(word: String) -> URL? {
    let baseUrlString = "https://www.google.com/search"
    var urlComponents = URLComponents(string: baseUrlString)
    urlComponents?.queryItems = [
        URLQueryItem(name: "q", value: word)
    ]
    if let url = urlComponents?.url {
        return url
    } else {
        return nil
    }
}
