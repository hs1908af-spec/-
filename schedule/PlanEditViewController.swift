import UIKit

protocol PlanEditViewControllerDelegate: AnyObject {
    func planEditViewController(_ viewController: PlanEditViewController, didSave plan: Plan)
}

final class PlanEditViewController: UIViewController {
    @IBOutlet private weak var textView: UITextView!

    weak var delegate: PlanEditViewControllerDelegate?
    var selectedDate: Date!
    var planToEdit: Plan?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = planToEdit == nil ? "계획 추가" : "계획 수정"
        setupNavigationItems()
        setupTextView()
    }

    private func setupNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(didTapSave))
    }

    private func setupTextView() {
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = planToEdit?.memo ?? ""
        textView.becomeFirstResponder()
    }

    @objc private func didTapCancel() {
        dismiss(animated: true)
    }

    @objc private func didTapSave() {
        let trimmed = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            let alert = UIAlertController(title: "메모를 입력하세요", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }

        let dateKey = DateHelpers.dateKey(from: selectedDate)
        let plan = Plan(
            id: planToEdit?.id ?? UUID(),
            dateKey: dateKey,
            memo: trimmed,
            isDone: planToEdit?.isDone ?? false,
            createdAt: planToEdit?.createdAt ?? Date()
        )
        delegate?.planEditViewController(self, didSave: plan)
    }
}
