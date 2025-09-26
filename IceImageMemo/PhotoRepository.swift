import Foundation
import UIKit

protocol PhotoRepository {
    func fetch() -> [URL]
    func delete(imageUrl: URL)
    func save(image: UIImage, url: URL)
}


final class PhotoRepositoryImpl: PhotoRepository {
    func fetch() -> [URL] {
        let fm = FileManager.default
        guard let documentsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("ドキュメントディレクトリが取得できませんでした")
            return []
        }
        let allowedExts = Set(["jpg", "jpeg", "png", "heic", "heif"])
        var imageUrls: [URL] = []
        for bucket in Expiration.allCases {
            let dir = documentsURL.appendingPathComponent(bucket.rawValue, isDirectory: true)
            guard fm.fileExists(atPath: dir.path) else { continue }
            
            do {
                let items = try fm.contentsOfDirectory(
                    at: dir,
                    includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey],
                    options: [.skipsHiddenFiles]
                )
                for url in items {
                    let values = try url.resourceValues(forKeys: [.isDirectoryKey])
                    let isDir = values.isDirectory ?? false
                    if !isDir && allowedExts.contains(url.pathExtension.lowercased()) {
                        imageUrls.append(url)
                    }
                }
            } catch {
                print("一覧取得失敗: \(dir.lastPathComponent) \(error)")
            }
        }
        return imageUrls
    }
    
    func delete(imageUrl: URL) {
        let filemanager = FileManager.default
        do {
            try filemanager.removeItem(at: imageUrl)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func save(image: UIImage, url: URL) {
        guard let imageJpg = image.jpegData(compressionQuality: 0.0) else {
            return
        }
        do {
            try imageJpg.write(to: url)
        } catch {
            return
        }
    }
}

