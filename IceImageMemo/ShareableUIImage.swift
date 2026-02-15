import SwiftUI

struct ShareableUIImage: Transferable {
    struct EncodingError: Error {}
    let uiImage: UIImage

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .jpeg) { value in
            guard let data = value.uiImage.jpegData(compressionQuality: 0.9) else {
                throw EncodingError()
            }
            return data
        }
    }
}


