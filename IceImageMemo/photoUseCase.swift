import Foundation
import SwiftUI

protocol PhotoUseCase {
    func fetch() -> [URL]
    func deltePhoto(imageUrl: URL)
    func getRemainDate(imageUrl: URL) -> String
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
    
    func deltePhoto(imageUrl: URL) {
        let filemanager = FileManager.default
        do {
            try filemanager.removeItem(at: imageUrl)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getRemainDate(imageUrl: URL) -> String {
        let fileName = imageUrl.lastPathComponent
        let nameWithoutExt = fileName.replacingOccurrences(of: ".jpg", with: "")
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyyMMddHHmmss"
        
        guard let imageDate = formatter.date(from: nameWithoutExt) else {
            return "日付に変換できません: \(nameWithoutExt)"
        }
        let directoryName = imageUrl.deletingLastPathComponent().lastPathComponent
        
        
        let now = Date()

        let remainSeconds = imageDate.timeIntervalSince(now)

        if remainSeconds > 0 {
            let diff = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: imageDate)
            if let d = diff.day, let h = diff.hour, let m = diff.minute {
                return "残り \(d)日 \(h)時間 \(m)分"
            }
        } else {
            return "期限切れです"
        }
        return "日付の取得に失敗しました。"
    }
}
