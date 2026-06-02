import UIKit

final class CalendarDayCell: UICollectionViewCell {
    static let reuseIdentifier = "CalendarDayCell"

    private let dayLabel = UILabel()
    private let selectionView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        selectionView.layer.cornerRadius = 18
        selectionView.backgroundColor = .systemBlue
        selectionView.isHidden = true

        dayLabel.textAlignment = .center
        dayLabel.font = .systemFont(ofSize: 14, weight: .medium)

        contentView.addSubview(selectionView)
        contentView.addSubview(dayLabel)
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            selectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionView.widthAnchor.constraint(equalToConstant: 36),
            selectionView.heightAnchor.constraint(equalToConstant: 36),

            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(day: Int, isInMonth: Bool, isSelected: Bool, isToday: Bool) {
        dayLabel.text = "\(day)"
        dayLabel.textColor = isInMonth ? .label : .tertiaryLabel
        selectionView.isHidden = !isSelected
        if isSelected {
            dayLabel.textColor = .white
        } else if isToday {
            dayLabel.textColor = .systemBlue
        }
    }
}
