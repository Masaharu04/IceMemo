import Foundation
import UserNotifications

final class ScheduleDeleteNoticeForPhotoUseCase {

    func execute(expiration: Expiration, shotDate: Date) {
        switch expiration {
        case .day, .week:
            break
        case .month:
            scheduleMonthNotice(idBase: shotDate)

        case .year:
            scheduleYearNotices(idBase: shotDate)
        }
    }
}

private extension ScheduleDeleteNoticeForPhotoUseCase {
    func makeId(base: Date, suffix: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return "\(formatter.string(from: base))_\(suffix)"
    }
}

private extension ScheduleDeleteNoticeForPhotoUseCase {

    func scheduleMonthNotice(idBase: Date) {
        guard
            let expireDate = Calendar.current.date(byAdding: .month, value: 1, to: idBase),
            let notifyDate = Calendar.current
                .date(byAdding: .day, value: -1, to: expireDate)?
                .at8AM()
        else { return }

        scheduleNotification(
            id: makeId(base: idBase, suffix: "month_day_before"),
            title: "📸 写真がまもなく削除されます",
            body: "1ヶ月保存の写真は明日削除されます",
            date: notifyDate
        )
    }
}

private extension ScheduleDeleteNoticeForPhotoUseCase {

    func scheduleYearNotices(idBase: Date) {
        guard let expireDate = Calendar.current.date(byAdding: .year, value: 1, to: idBase) else {
            return
        }

        guard
            let weekBefore = Calendar.current
                .date(byAdding: .day, value: -7, to: expireDate)?
                .at8AM(),
            let dayBefore = Calendar.current
                .date(byAdding: .day, value: -1, to: expireDate)?
                .at8AM()
        else { return }

        scheduleNotification(
            id: makeId(base: idBase, suffix: "year_week_before"),
            title: "📸 写真がまもなく削除されます",
            body: "1年保存の写真は1週間後に削除されます",
            date: weekBefore
        )

        scheduleNotification(
            id: makeId(base: idBase, suffix: "year_day_before"),
            title: "📸 写真がまもなく削除されます",
            body: "1年保存の写真は明日削除されます",
            date: dayBefore
        )
    }
}

private extension ScheduleDeleteNoticeForPhotoUseCase {

    func scheduleNotification(
        id: String,
        title: String,
        body: String,
        date: Date
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}

extension Date {
    func at8AM() -> Date? {
        Calendar.current.date(
            bySettingHour: 8,
            minute: 0,
            second: 0,
            of: self
        )
    }
}
