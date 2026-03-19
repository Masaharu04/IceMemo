//
//  exif_control.swift
//  IceImageMemo
//
//  Created by Masaharu on 2023/07/25.
//

import CoreImage
import Foundation

func read_exifdata(image_url: URL) -> [String: Any] {
    let photo_ci = CIImage(contentsOf: image_url)
    return photo_ci!.properties
}
