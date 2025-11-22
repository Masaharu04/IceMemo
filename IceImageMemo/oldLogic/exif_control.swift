//
//  exif_control.swift
//  IceImageMemo
//
//  Created by Masaharu on 2023/07/25.
//

import Foundation
import CoreImage

func read_exifdata(image_url: URL) -> Dictionary<String, Any>{
    let photo_ci = CIImage(contentsOf: image_url)
    let imageProperties = photo_ci!.properties
    return imageProperties
}

