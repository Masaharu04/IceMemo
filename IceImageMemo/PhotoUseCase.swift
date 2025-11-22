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
