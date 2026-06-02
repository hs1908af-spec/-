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
        // 공휴일은 번들 JSON만 사용한다. 로드 실패 시 빈 상태로 둔다.
        if let url = Bundle.main.url(forResource: "holidays_kr", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let holidays = try? JSONDecoder().decode([Holiday].self, from: data) {
            holidaysByDate = Dictionary(uniqueKeysWithValues: holidays.map { ($0.date, $0) })
            return
        }
        holidaysByDate = [:]
    }
}
