import Foundation
import SwiftUI

protocol PhotoUseCase {
    func fetch() -> [UIImage]
}

final class photoUseCaseImpl: PhotoUseCase {
    
    func fetch() -> [UIImage] {
        var images: [UIImage] = []
        guard let image = UIImage(contentsOfFile:) else{
            fatalError("読み込み失敗")
        }
        images.append(image)
        return images
    }
}
