import UIKit

final class PlanCell: UITableViewCell {
    static let reuseIdentifier = "PlanCell"

    private let checkboxButton = UIButton(type: .system)
    private let memoLabel = UILabel()
    private let stackView = UIStackView()

    var onToggle: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        selectionStyle = .none

        checkboxButton.setImage(UIImage(systemName: "circle"), for: .normal)
        checkboxButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        checkboxButton.tintColor = UIColor.systemBlue
        checkboxButton.addTarget(self, action: #selector(didTapCheckbox), for: .touchUpInside)

        memoLabel.font = UIFont.systemFont(ofSize: 16)
        memoLabel.numberOfLines = 0

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(checkboxButton)
        stackView.addArrangedSubview(memoLabel)

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            checkboxButton.widthAnchor.constraint(equalToConstant: 24),
            checkboxButton.heightAnchor.constraint(equalToConstant: 24),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    func configure(with plan: Plan) {
        memoLabel.text = plan.memo
        checkboxButton.isSelected = plan.isDone
        memoLabel.textColor = plan.isDone ? UIColor.secondaryLabel : UIColor.label
    }

    @objc private func didTapCheckbox() {
        onToggle?()
    }
}
