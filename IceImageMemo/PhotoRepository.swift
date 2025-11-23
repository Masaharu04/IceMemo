import Foundation
import UIKit

protocol PhotoRepository {
    func fetch() -> [URL]
    func delete(url: URL)
    func save(data: Data, url: URL)
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
    
    func delete(url: URL) {
        let filemanager = FileManager.default
        do {
            try filemanager.removeItem(at: url)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func save(data: Data, url: URL) {
        do {
            try data.write(to: url)
        } catch {
            return
        }
    }
}

