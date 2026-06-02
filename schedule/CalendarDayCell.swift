import UIKit

final class CalendarDayCell: UICollectionViewCell {
    static let reuseIdentifier = "CalendarDayCell"

    private let dateLabel = UILabel()
    private let dotView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        dotView.backgroundColor = UIColor.systemRed
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.layer.cornerRadius = 3

        contentView.addSubview(dateLabel)
        contentView.addSubview(dotView)

        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            dotView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            dotView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dotView.widthAnchor.constraint(equalToConstant: 6),
            dotView.heightAnchor.constraint(equalToConstant: 6)
        ])

        contentView.layer.cornerRadius = 8
    }

    func configure(dayText: String, isInMonth: Bool, isToday: Bool, isSelected: Bool, hasHoliday: Bool) {
        dateLabel.text = dayText
        dotView.isHidden = !hasHoliday

        if isSelected {
            contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.systemBlue.cgColor
        } else if isToday {
            contentView.backgroundColor = UIColor.systemGray5
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = UIColor.clear.cgColor
        } else {
            contentView.backgroundColor = UIColor.clear
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = UIColor.clear.cgColor
        }

        dateLabel.textColor = isInMonth ? UIColor.label : UIColor.secondaryLabel
    }
}
