/*
 PhotoUseCase.swift
 --------------------------------------------
 「写真」機能のユースケース層。Repository を介して入出力を行い、
 UI から使いやすい形（並び順・残り時間の判定など）に整えます。

 ■ 何をする？
 - fetch(): Repository から画像 URL を取得し、更新日時の新しい順に並べ替えて返す
 - deletePhoto(_:), savePhoto(_:url:): 画像の削除／保存を委譲
 - getRemainDate(imageUrl:): ファイル名に埋め込んだ日時(yyyyMMddHHmmss)を基に
   期限までの残り時間を「残り X日 Y時間 Z分」の文字列で返す（過ぎていれば「期限切れです」）
 - autoDelete(): 上記判定で期限切れの画像を一括削除

 ■ 前提・制約
 - ファイル名が <yyyyMMddHHmmss>.jpg 形式であること（現状 .jpg 固定）
 - タイムゾーンは端末設定（TimeZone.current）を使用
 - 期限判定は getRemainDate の戻り文字列に「期限切れ」を含むかで判定（簡易実装）

 ■ 設計メモ
 - 日付計算（ビジネスロジック）と文字列化（表示）は分離するとテストしやすい
   例: enum ExpiryStatus { case remaining(DateComponents), expired }
 - 複数拡張子に対応する場合は拡張子の扱いを一般化する
 - 型名は Swift 慣習に合わせて `PhotoUseCaseImpl`（先頭大文字）を推奨
*/

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
