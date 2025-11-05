

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

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

func make_greyscale(image:UIImage) -> CIImage{
    let ciimage = CIImage(image: image)
    let greyscale_filter = CIFilter.maximumComponent()
    greyscale_filter.inputImage = ciimage
    
    let greyscale_image = greyscale_filter.outputImage
        
    return greyscale_image!
}

func make_binary(image:CIImage) ->CIImage{
    let grayscaleImage = image
    let thresholdFilter = CIFilter.colorThreshold()
    thresholdFilter.inputImage = grayscaleImage
    thresholdFilter.threshold = 0.3
    let binaryImage = thresholdFilter.outputImage
    
    return binaryImage!
}

func convert_CtoU(image:CIImage) -> UIImage{
    let image:UIImage = UIImage.init(ciImage: image)
    return image
}
