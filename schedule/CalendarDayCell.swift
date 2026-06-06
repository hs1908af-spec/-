import UIKit

/// 📅 스케줄 달력의 '하루'를 표현하는 커스텀 셀 컴포넌트
final class CalendarDayCell: UICollectionViewCell {
    static let reuseIdentifier = "CalendarDayCell" // ♻️ 셀 재사용을 위한 식별자
    
    private let dateLabel = UILabel() // 🔢 날짜 숫자 레이블 (1, 2, 3...)
    private let dotView = UIView()    // 🔴 계획이나 일정이 있을 때 표시되는 빨간 점
    
    // MARK: - 초기화 세팅
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    /// 셀 내부의 UI 요소들을 배치하고 제약조건(Auto Layout)을 설정합니다.
    private func setupView() {
        // 날짜 텍스트 스타일 정의
        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 일정을 표시할 빨간 점 스타일 정의 (반지름 3의 원형)
        dotView.backgroundColor = UIColor.systemRed
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.layer.cornerRadius = 3
        
        // 셀의 기본 뷰(contentView)에 서브뷰 추가
        contentView.addSubview(dateLabel)
        contentView.addSubview(dotView)
        
        // 날짜와 빨간 점의 상대적 위치 고정 (오토레이아웃)
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            dotView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            dotView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dotView.widthAnchor.constraint(equalToConstant: 6),
            dotView.heightAnchor.constraint(equalToConstant: 6)
        ])
        
        contentView.layer.cornerRadius = 8 // 날짜 선택 배경의 모서리를 둥글게 처리
    }
    
    // MARK: - 상태 반영 데이터 바인딩
    
    /// 날짜의 상태 데이터들을 받아와 화면의 스타일을 실시간으로 변경합니다.
    func configure(dayText: String, isInMonth: Bool, isToday: Bool, isSelected: Bool, hasHoliday: Bool) {
        dateLabel.text = dayText
        dotView.isHidden = !hasHoliday // 🔴 일정이 있으면 빨간 점을 보여주고, 없으면 숨김
        
        // 🎨 상태(선택됨 / 오늘 / 일반)에 따른 셀의 배경색 및 테두리 처리 분기 로직
        if isSelected {
            // 사용자가 터치하여 선택한 날짜 스타일 (파란 테두리)
            contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.systemBlue.cgColor
        } else if isToday {
            // 오늘 날짜 스타일 (회색 배경)
            contentView.backgroundColor = UIColor.systemGray5
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = UIColor.clear.cgColor
        } else {
            // 아무 상태도 아닌 일반 날짜 스타일 (투명 배경)
            contentView.backgroundColor = UIColor.clear
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = UIColor.clear.cgColor
        }
        
        // 🌗 이번 달 날짜는 진하게, 이전/다음 달 날짜는 흐리게 색상 구분
        dateLabel.textColor = isInMonth ? UIColor.label : UIColor.secondaryLabel
    }
}
