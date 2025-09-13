import Foundation
import SwiftUI

protocol PhotoUseCase {
    func fetch() -> [URL]
}

final class photoUseCaseImpl: PhotoUseCase {
    
    func fetch() -> [URL] {
        let fm = FileManager.default
        guard let documentsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("ドキュメントディレクトリが取得できませんでした")
            return []
        }
        let allowedExts = Set(["jpg", "jpeg", "png", "heic", "heif"])
        var imageURLs: [URL] = []
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
                        imageURLs.append(url)
                    }
                }
            } catch {
                print("一覧取得失敗: \(dir.lastPathComponent) \(error)")
            }
        }
        
        imageURLs.sort {
            let a = (try? $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            let b = (try? $1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            return a > b
        }
        
        return imageURLs
    }
}
