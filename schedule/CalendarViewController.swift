import UIKit

final class CalendarViewController: UIViewController {
    @IBOutlet private weak var monthLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!

    private var currentMonth: Date = DateHelpers.startOfMonth(for: Date())
    private var selectedDate: Date = Date()
    private var dayItems: [DayItem] = []

    private let holidayStore = HolidayStore.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "일정"
        setupCollectionView()
        reloadMonth()
    }

    private func setupCollectionView() {
        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
    }

    private func reloadMonth() {
        monthLabel.text = DateHelpers.monthTitle(for: currentMonth)
        dayItems = buildDays(for: currentMonth)
        collectionView.reloadData()
    }

    @IBAction private func didTapPrevMonth(_ sender: UIButton) {
        changeMonth(by: -1)
    }

    @IBAction private func didTapNextMonth(_ sender: UIButton) {
        changeMonth(by: 1)
    }

    private func changeMonth(by value: Int) {
        guard let next = DateHelpers.calendar.date(byAdding: .month, value: value, to: currentMonth) else { return }
        currentMonth = DateHelpers.startOfMonth(for: next)
        reloadMonth()
    }

    private func buildDays(for month: Date) -> [DayItem] {
        let calendar = DateHelpers.calendar
        let startOfMonth = DateHelpers.startOfMonth(for: month)
        let weekday = calendar.component(.weekday, from: startOfMonth)
        let offset = (weekday - calendar.firstWeekday + 7) % 7

        var items: [DayItem] = []
        for index in 0..<42 {
            let dayOffset = index - offset
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfMonth) else { continue }

            let isInMonth = calendar.isDate(date, equalTo: startOfMonth, toGranularity: .month)
            let isToday = calendar.isDateInToday(date)
            let dateKey = DateHelpers.dateKey(from: date)
            let isSelected = dateKey == DateHelpers.dateKey(from: selectedDate)
            let hasHoliday = holidayStore.holidayName(for: dateKey) != nil

            let day = calendar.component(.day, from: date)
            items.append(DayItem(date: date, dayText: "\(day)", isInMonth: isInMonth, isToday: isToday, isSelected: isSelected, hasHoliday: hasHoliday))
        }
        return items
    }

    private func pushDayPlans(for date: Date) {
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "DayPlansViewController") as? DayPlansViewController else { return }
        viewController.selectedDate = date
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension CalendarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dayItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDayCell.reuseIdentifier, for: indexPath) as? CalendarDayCell else {
            return UICollectionViewCell()
        }

        let item = dayItems[indexPath.item]
        cell.configure(dayText: item.dayText, isInMonth: item.isInMonth, isToday: item.isToday, isSelected: item.isSelected, hasHoliday: item.hasHoliday)
        return cell
    }
}

extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 7
        return CGSize(width: floor(width), height: 48)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dayItems[indexPath.item]
        selectedDate = item.date

        if !item.isInMonth {
            currentMonth = DateHelpers.startOfMonth(for: item.date)
            reloadMonth()
        } else {
            dayItems = buildDays(for: currentMonth)
            collectionView.reloadData()
        }

        pushDayPlans(for: item.date)
    }
}

private struct DayItem {
    let date: Date
    let dayText: String
    let isInMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    let hasHoliday: Bool
}
