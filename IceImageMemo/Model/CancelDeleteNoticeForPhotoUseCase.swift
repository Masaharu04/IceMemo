import Foundation
import UserNotifications

final class CancelDeleteNoticeForPhotoUseCase {
    func execute(shotDate: Date) {
        // 全ての可能性のあるsuffix（1ヶ月、1年など）
        let suffixes = ["test_10sec", "month_day_before", "year_week_before", "year_day_before"]
        
        let identifiers = suffixes.map { suffix in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            return "\(formatter.string(from: shotDate))_\(suffix)"
        }

        // 該当する通知予約をまとめて削除
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
