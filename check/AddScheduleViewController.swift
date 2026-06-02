import UIKit
import CoreData

final class AddScheduleViewController: UIViewController {
    var onSave: (() -> Void)?

    private let context: NSManagedObjectContext
    private let selectedDate: Date
    private let calendar = Calendar.current

    private let titleField = UITextField()
    private let timePicker = UIDatePicker()
    private let memoTextView = UITextView()
    private let saveButton = UIBarButtonItem(title: "저장", style: .done, target: nil, action: nil)

    init(context: NSManagedObjectContext, selectedDate: Date) {
        self.context = context
        self.selectedDate = selectedDate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "새 일정"

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(didTapCancel))
        saveButton.target = self
        saveButton.action = #selector(didTapSave)
        navigationItem.rightBarButtonItem = saveButton

        setupFields()
        setupLayout()
        updateSaveButtonState()
    }

    private func setupFields() {
        titleField.placeholder = "제목"
        titleField.borderStyle = .roundedRect
        titleField.keyboardType = .default
        titleField.autocorrectionType = .default
        titleField.spellCheckingType = .default
        titleField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels

        memoTextView.font = .systemFont(ofSize: 15)
        memoTextView.layer.borderColor = UIColor.systemGray4.cgColor
        memoTextView.layer.borderWidth = 1
        memoTextView.layer.cornerRadius = 8
        memoTextView.keyboardType = .default
        memoTextView.autocorrectionType = .default
        memoTextView.spellCheckingType = .default
        memoTextView.text = ""
    }

    private func setupLayout() {
        let titleLabel = UILabel()
        titleLabel.text = "제목"
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .secondaryLabel

        let timeLabel = UILabel()
        timeLabel.text = "시작 시간"
        timeLabel.font = .systemFont(ofSize: 13, weight: .medium)
        timeLabel.textColor = .secondaryLabel

        let memoLabel = UILabel()
        memoLabel.text = "메모"
        memoLabel.font = .systemFont(ofSize: 13, weight: .medium)
        memoLabel.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [titleLabel, titleField, timeLabel, timePicker, memoLabel, memoTextView])
        stack.axis = .vertical
        stack.spacing = 12

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        memoTextView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            memoTextView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }

    private func updateSaveButtonState() {
        let text = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        saveButton.isEnabled = !text.isEmpty
    }

    @objc private func textDidChange() {
        updateSaveButtonState()
    }

    @objc private func didTapCancel() {
        dismiss(animated: true)
    }

    @objc private func didTapSave() {
        let text = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }

        let schedule = Schedule(context: context)
        schedule.title = text
        schedule.createdAt = Date()
        schedule.date = calendar.startOfDay(for: selectedDate)

        let timeComponents = calendar.dateComponents([.hour, .minute], from: timePicker.date)
        let startTime = calendar.date(bySettingHour: timeComponents.hour ?? 0, minute: timeComponents.minute ?? 0, second: 0, of: selectedDate) ?? selectedDate
        schedule.startTime = startTime

        let memoText = memoTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        schedule.memo = memoText?.isEmpty == true ? nil : memoText

        do {
            try context.save()
            onSave?()
            dismiss(animated: true)
        } catch {
            let alert = UIAlertController(title: "저장 실패", message: "다시 시도해 주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
        }
    }
}
