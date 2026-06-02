import Foundation

enum DateHelpers {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.timeZone = TimeZone.current
        calendar.firstWeekday = 2
        return calendar
    }()

    static let dateKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let monthTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy년 M월"
        return formatter
    }()

    static let dateTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy년 M월 d일 (E)"
        return formatter
    }()

    static func dateKey(from date: Date) -> String {
        dateKeyFormatter.string(from: date)
    }

    static func monthTitle(for date: Date) -> String {
        monthTitleFormatter.string(from: date)
    }

    static func dateTitle(for date: Date) -> String {
        dateTitleFormatter.string(from: date)
    }

    static func startOfMonth(for date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }
}
