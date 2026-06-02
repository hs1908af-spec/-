//
//  ViewController.swift
//  check
//
//  Created by 문현서 on 5/27/26.
//

import UIKit
import CoreData

final class ViewController: UIViewController {
    private struct DayItem {
        let date: Date
        let isInMonth: Bool
    }

    private let calendar = Calendar.current
    private let context = CoreDataStack.shared.viewContext

    private var currentMonth: Date = Date()
    private var selectedDate: Date = Date()
    private var days: [DayItem] = []
    private var schedules: [Schedule] = []

    private let monthLabel = UILabel()
    private let previousButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let weekdaysStack = UIStackView()
    private let collectionView: UICollectionView
    private let selectedDateLabel = UILabel()
    private let addButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var collectionViewHeightConstraint: NSLayoutConstraint?

    private lazy var monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy년 M월"
        return formatter
    }()

    private lazy var selectedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter
    }()

    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        layout.sectionInset = .init(top: 4, left: 0, bottom: 4, right: 0)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        layout.sectionInset = .init(top: 4, left: 0, bottom: 4, right: 0)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "일정"
        setupHeader()
        setupWeekdays()
        setupCollectionView()
        setupSelectedHeader()
        setupTableView()
        setupLayout()
        updateMonth(to: Date())
        updateSelectedDate(Date())
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewLayout()
    }

    private func setupHeader() {
        monthLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        monthLabel.textAlignment = .center

        previousButton.setTitle("이전", for: .normal)
        previousButton.addTarget(self, action: #selector(didTapPreviousMonth), for: .touchUpInside)

        nextButton.setTitle("다음", for: .normal)
        nextButton.addTarget(self, action: #selector(didTapNextMonth), for: .touchUpInside)
    }

    private func setupWeekdays() {
        weekdaysStack.axis = .horizontal
        weekdaysStack.distribution = .fillEqually
        weekdaysStack.alignment = .center

        let symbols = calendar.shortStandaloneWeekdaySymbols
        let startIndex = calendar.firstWeekday - 1
        let ordered = symbols[startIndex...] + symbols[..<startIndex]
        ordered.forEach { symbol in
            let label = UILabel()
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textColor = .secondaryLabel
            label.text = symbol
            weekdaysStack.addArrangedSubview(label)
        }
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
    }

    private func setupSelectedHeader() {
        selectedDateLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        selectedDateLabel.textColor = .label

        addButton.setTitle("추가", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        addButton.addTarget(self, action: #selector(didTapAddSchedule), for: .touchUpInside)
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }

    private func setupLayout() {
        let headerStack = UIStackView(arrangedSubviews: [previousButton, monthLabel, nextButton])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.distribution = .fill

        previousButton.setContentHuggingPriority(.required, for: .horizontal)
        nextButton.setContentHuggingPriority(.required, for: .horizontal)

        let selectedStack = UIStackView(arrangedSubviews: [selectedDateLabel, addButton])
        selectedStack.axis = .horizontal
        selectedStack.alignment = .center
        selectedStack.distribution = .equalSpacing

        let containerStack = UIStackView(arrangedSubviews: [headerStack, weekdaysStack, collectionView, selectedStack, tableView])
        containerStack.axis = .vertical
        containerStack.spacing = 12

        view.addSubview(containerStack)
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 280)
        collectionViewHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            containerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }

    private func updateCollectionViewLayout() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let width = collectionView.bounds.width
        let spacing: CGFloat = layout.minimumInteritemSpacing
        let totalSpacing = spacing * 6
        let itemWidth = floor((width - totalSpacing) / 7)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)

        let rows = max(1, Int(ceil(Double(days.count) / 7.0)))
        let totalHeight = CGFloat(rows) * itemWidth + CGFloat(rows - 1) * layout.minimumLineSpacing + layout.sectionInset.top + layout.sectionInset.bottom
        collectionViewHeightConstraint?.constant = totalHeight
    }

    private func updateMonth(to date: Date) {
        currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
        monthLabel.text = monthFormatter.string(from: currentMonth)
        days = generateDays(for: currentMonth)
        collectionView.reloadData()
        updateCollectionViewLayout()
    }

    private func updateSelectedDate(_ date: Date) {
        selectedDate = date
        selectedDateLabel.text = selectedDateFormatter.string(from: date)
        fetchSchedules(for: date)
        collectionView.reloadData()
    }

    private func generateDays(for month: Date) -> [DayItem] {
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else { return [] }
        guard let range = calendar.range(of: .day, in: .month, for: startOfMonth) else { return [] }

        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let leading = (firstWeekday - calendar.firstWeekday + 7) % 7
        let total = leading + range.count
        let rows = Int(ceil(Double(total) / 7.0))
        let trailing = rows * 7 - total

        guard let startDate = calendar.date(byAdding: .day, value: -leading, to: startOfMonth) else { return [] }

        return (0..<(leading + range.count + trailing)).compactMap { offset in
            guard let dayDate = calendar.date(byAdding: .day, value: offset, to: startDate) else { return nil }
            let isInMonth = calendar.isDate(dayDate, equalTo: startOfMonth, toGranularity: .month)
            return DayItem(date: dayDate, isInMonth: isInMonth)
        }
    }

    private func fetchSchedules(for date: Date) {
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        let request: NSFetchRequest<Schedule> = Schedule.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]

        do {
            schedules = try context.fetch(request)
        } catch {
            schedules = []
        }
        tableView.reloadData()
    }

    @objc private func didTapPreviousMonth() {
        guard let previous = calendar.date(byAdding: .month, value: -1, to: currentMonth) else { return }
        updateMonth(to: previous)
    }

    @objc private func didTapNextMonth() {
        guard let next = calendar.date(byAdding: .month, value: 1, to: currentMonth) else { return }
        updateMonth(to: next)
    }

    @objc private func didTapAddSchedule() {
        let addController = AddScheduleViewController(context: context, selectedDate: selectedDate)
        addController.onSave = { [weak self] in
            guard let self = self else { return }
            self.fetchSchedules(for: self.selectedDate)
        }
        let navigationController = UINavigationController(rootViewController: addController)
        present(navigationController, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        days.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDayCell.reuseIdentifier, for: indexPath) as? CalendarDayCell else {
            return UICollectionViewCell()
        }
        let item = days[indexPath.item]
        let dayNumber = calendar.component(.day, from: item.date)
        let isSelected = calendar.isDate(item.date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(item.date)
        cell.configure(day: dayNumber, isInMonth: item.isInMonth, isSelected: isSelected, isToday: isToday)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = days[indexPath.item]
        if !item.isInMonth {
            updateMonth(to: item.date)
        }
        updateSelectedDate(item.date)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if schedules.isEmpty {
            tableView.setEmptyMessage("일정이 없습니다")
        } else {
            tableView.restore()
        }
        return schedules.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let schedule = schedules[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ScheduleCell")
        cell.textLabel?.text = schedule.title
        cell.detailTextLabel?.text = timeFormatter.string(from: schedule.startTime)
        cell.accessoryType = .none
        return cell
    }
}

private extension UITableView {
    func setEmptyMessage(_ message: String) {
        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        backgroundView = label
        separatorStyle = .none
    }

    func restore() {
        backgroundView = nil
        separatorStyle = .singleLine
    }
}
