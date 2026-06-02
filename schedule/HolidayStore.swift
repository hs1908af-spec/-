import Foundation

final class HolidayStore {
    static let shared = HolidayStore()

    private(set) var holidaysByDate: [String: Holiday] = [:]

    private init() {
        load()
    }

    func holidayName(for dateKey: String) -> String? {
        holidaysByDate[dateKey]?.name
    }

    private func load() {
        if let url = Bundle.main.url(forResource: "holidays_kr", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let holidays = try? JSONDecoder().decode([Holiday].self, from: data) {
            holidaysByDate = Dictionary(uniqueKeysWithValues: holidays.map { ($0.date, $0) })
            return
        }

        let fallback: [Holiday] = [
            Holiday(date: "2026-01-01", name: "신정"),
            Holiday(date: "2026-03-01", name: "삼일절"),
            Holiday(date: "2026-05-05", name: "어린이날"),
            Holiday(date: "2026-06-06", name: "현충일"),
            Holiday(date: "2026-08-15", name: "광복절"),
            Holiday(date: "2026-10-03", name: "개천절"),
            Holiday(date: "2026-10-09", name: "한글날"),
            Holiday(date: "2026-12-25", name: "성탄절"),
        ]
        holidaysByDate = Dictionary(uniqueKeysWithValues: fallback.map { ($0.date, $0) })
    }
}
