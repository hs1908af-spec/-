import UIKit

final class DayPlansViewController: UIViewController {
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var holidayLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!

    var selectedDate: Date!

    private var plans: [Plan] = []
    private let planStore = PlanStore.shared
    private let holidayStore = HolidayStore.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "계획"
        setupTableView()
        setupNavigationItems()
        configureHeader()
        reloadPlans()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadPlans()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PlanCell.self, forCellReuseIdentifier: PlanCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
    }

    private func setupNavigationItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }

    private func configureHeader() {
        dateLabel.text = DateHelpers.dateTitle(for: selectedDate)
        let dateKey = DateHelpers.dateKey(from: selectedDate)

        if let holidayName = holidayStore.holidayName(for: dateKey) {
            holidayLabel.text = holidayName
            holidayLabel.isHidden = false
        } else {
            holidayLabel.text = nil
            holidayLabel.isHidden = true
        }
    }

    private func reloadPlans() {
        let dateKey = DateHelpers.dateKey(from: selectedDate)
        plans = planStore.plans(for: dateKey)
        tableView.reloadData()
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

extension DayPlansViewController: UITableViewDataSource {
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

extension DayPlansViewController: UITableViewDelegate {
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

extension DayPlansViewController: PlanEditViewControllerDelegate {
    func planEditViewController(_ viewController: PlanEditViewController, didSave plan: Plan) {
        planStore.upsert(plan)
        reloadPlans()
        viewController.dismiss(animated: true)
    }
}
