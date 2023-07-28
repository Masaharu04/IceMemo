//
//  zoom.swift
//  IceImageMemo
//
//  Created by 山本聖留 on 2023/07/28.
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins

func convertToMonochrome(image: UIImage) -> UIImage? {
    if let ciImage = CIImage(image: image) {
        let filter = CIFilter.colorMonochrome()
        filter.inputImage = ciImage
        filter.intensity = 1.0 

        if let outputImage = filter.outputImage {
            let context = CIContext()
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
    }
    return nil // 変換に失敗した場合はnilを返します
}
