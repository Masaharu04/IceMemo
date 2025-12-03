import Foundation

protocol PhotoUseCase {
    func fetch() -> [URL]
    func deletePhoto(imageUrl: URL)
    func savePhoto(data: Data, url: URL)
    func getRemainDate(imageUrl: URL) -> String
    func autoDelete()
}

final class photoUseCaseImpl: PhotoUseCase {
    private let repository: PhotoRepository
    
    init(repository: PhotoRepository) {
        self.repository = repository
    }
    
    func fetch() -> [URL] {
        var imageUrls = repository.fetch()
        
        imageUrls.sort {
            let a = (try? $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            let b = (try? $1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            return a > b
        }
        return imageUrls
    }
    
    func deletePhoto(imageUrl: URL) {
        repository.delete(url: imageUrl)
    }
    
    func savePhoto(data: Data, url: URL) {
        repository.save(data: data, url: url)
    }
    
    func getRemainDate(imageUrl: URL) -> String {
        // 1. ファイル名から撮影日時を取得
        let fileName = imageUrl.lastPathComponent
        let nameWithoutExt = fileName.replacingOccurrences(of: ".jpg", with: "")
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyyMMddHHmmss"
        
        guard let shootDate = formatter.date(from: nameWithoutExt) else {
            return "日付に変換できません: \(nameWithoutExt)"
        }
        
        // 2. ディレクトリ名から期限タイプを取得
        let directoryName = imageUrl.deletingLastPathComponent().lastPathComponent.lowercased()
        
        // 3. 期限タイプに応じて期限日時を計算
        var expireDate: Date
        switch directoryName {
        case "day":
            expireDate = Calendar.current.date(byAdding: .day, value: 1, to: shootDate)!
        case "week":
            expireDate = Calendar.current.date(byAdding: .day, value: 7, to: shootDate)!
        case "month":
            expireDate = Calendar.current.date(byAdding: .day, value: 30, to: shootDate)!
        case "year":
            expireDate = Calendar.current.date(byAdding: .day, value: 365, to: shootDate)!
        default:
            expireDate = shootDate // デフォルトは撮影日そのまま（期限切れ扱いになる）
        }
        
        // 4. 現在日時との残り時間計算
        let now = Date()
        let remainSeconds = expireDate.timeIntervalSince(now)
        
        if remainSeconds > 0 {
            let diff = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: expireDate)
            if let d = diff.day, let h = diff.hour, let m = diff.minute {
                return "残り \(d)日 \(h)時間 \(m)分"
            }
        } else {
            return "期限切れです"
        }
        return "日付の取得に失敗しました。"
    }

    
    func autoDelete() {
        let imageUrls = fetch()
        for url in imageUrls {
            let remainDate = getRemainDate(imageUrl: url)
            if remainDate.contains("期限切れ") {
                deletePhoto(imageUrl: url)
            }
        }
    }
}
