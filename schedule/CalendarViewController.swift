import UIKit

final class CalendarViewController: UIViewController {
    @IBOutlet private weak var monthLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var selectedDateLabel: UILabel!
    @IBOutlet private weak var plansTableView: UITableView!

    private var currentMonth: Date = DateHelpers.startOfMonth(for: Date())
    private var selectedDate: Date = Date()
    private var dayItems: [DayItem] = []
    private var plans: [Plan] = []

    private let holidayStore = HolidayStore.shared
    private let planStore = PlanStore.shared
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "일정"
        selectedDate = Date()
        currentMonth = DateHelpers.startOfMonth(for: selectedDate)
        setupCollectionView()
        setupPlansTableView()
        setupNavigationItems()
        updateSelectedDateLabel()
        reloadMonth()
        reloadPlans()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadPlans()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
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

    private func setupPlansTableView() {
        plansTableView.dataSource = self
        plansTableView.delegate = self
        plansTableView.register(PlanCell.self, forCellReuseIdentifier: PlanCell.reuseIdentifier)
        plansTableView.tableFooterView = UIView()

        emptyLabel.text = "등록된 계획이 없습니다"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = UIColor.secondaryLabel
        emptyLabel.font = UIFont.systemFont(ofSize: 14)
        plansTableView.backgroundView = emptyLabel
    }

    private func setupNavigationItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }

    private func reloadMonth() {
        monthLabel.text = DateHelpers.monthTitle(for: currentMonth)
        dayItems = buildDays(for: currentMonth)
        collectionView.reloadData()
    }

    private func updateSelectedDateLabel() {
        selectedDateLabel.text = DateHelpers.dateTitle(for: selectedDate)
    }

    private func reloadPlans() {
        let dateKey = DateHelpers.dateKey(from: selectedDate)
        plans = planStore.plans(for: dateKey)
        emptyLabel.isHidden = !plans.isEmpty
        plansTableView.reloadData()
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
        selectedDate = currentMonth
        updateSelectedDateLabel()
        reloadPlans()
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

    @objc private func didTapAdd() {
        presentEditor(for: nil)
    }

    private func presentEditor(for plan: Plan?) {
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "PlanEditViewController") as? PlanEditViewController else { return }
        viewController.selectedDate = selectedDate
        viewController.planToEdit = plan
        viewController.delegate = self
        let nav = UINavigationController(rootViewController: viewController)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
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

        updateSelectedDateLabel()
        reloadPlans()

        if !item.isInMonth {
            currentMonth = DateHelpers.startOfMonth(for: item.date)
            reloadMonth()
        } else {
            dayItems = buildDays(for: currentMonth)
            collectionView.reloadData()
        }
    }
}

extension CalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        plans.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlanCell.reuseIdentifier, for: indexPath) as? PlanCell else {
            return UITableViewCell()
        }

        let plan = plans[indexPath.row]
        cell.configure(with: plan)
        cell.onToggle = { [weak self] in
            self?.planStore.toggleDone(id: plan.id)
            self?.reloadPlans()
        }
        return cell
    }
}

extension CalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let plan = plans[indexPath.row]
        presentEditor(for: plan)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
            guard let self else { return }
            let plan = plans[indexPath.row]
            planStore.delete(id: plan.id)
            reloadPlans()
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension CalendarViewController: PlanEditViewControllerDelegate {
    func planEditViewController(_ viewController: PlanEditViewController, didSave plan: Plan) {
        planStore.upsert(plan)
        reloadPlans()
        viewController.dismiss(animated: true)
    }

    func planEditViewController(_ viewController: PlanEditViewController, didDelete plan: Plan) {
        planStore.delete(id: plan.id)
        reloadPlans()
        viewController.dismiss(animated: true)
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
