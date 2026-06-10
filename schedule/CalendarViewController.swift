import UIKit

/// 📅 '스케줄' 앱의 메인 화면: 달력과 일정 테이블 뷰를 총괄 제어하는 컨트롤러
final class CalendarViewController: UIViewController {
    
    // MARK: - UI 컴포넌트 연결 (Storyboard 인터페이스)
    @IBOutlet private weak var monthLabel: UILabel!        // 🏷 "2026년 6월"을 보여주는 상단 레이블
    @IBOutlet private weak var collectionView: UICollectionView! // 🗓 달력의 격자판 (날짜 칸들)
    @IBOutlet private weak var selectedDateLabel: UILabel! // 📍 현재 아래 목록에 뜨는 날짜 표시 레이블
    @IBOutlet private weak var plansTableView: UITableView! // 📋 선택한 날짜의 할 일 목록창
    
    // MARK: - 데이터 상태 상태 변수
    private var currentMonth: Date = DateHelpers.startOfMonth(for: Date()) // 현재 화면에 띄운 '월'
    private var selectedDate: Date = Date() // 사용자가 터치해 선택한 '날짜'
    private var dayItems: [DayItem] = []     // 달력 42칸에 채워질 날짜 정보 배열
    private var plans: [Plan] = []           // 현재 선택된 날짜에 저장된 계획 목록 배열
    
    // MARK: - 데이터 싱글톤 매니저 연결
    private let holidayStore = HolidayStore.shared // 휴일/일정 점 표시 판별기
    private let planStore = PlanStore.shared       // 계획 생성, 읽기, 변경, 삭제 매니저
    private let emptyLabel = UILabel()             // "등록된 계획이 없습니다" 안내 레이블
    
    // MARK: - 라이프사이클 메서드
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "일정"
        selectedDate = Date()
        currentMonth = DateHelpers.startOfMonth(for: selectedDate)
        
        // 초기화 구동 설정
        setupCollectionView()
        setupPlansTableView()
        setupNavigationItems()
        updateSelectedDateLabel()
        reloadMonth()
        reloadPlans()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadPlans() // 다른 화면에서 편집 후 돌아왔을 때 목록 실시간 동기화
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout() // 기기 회전이나 크기 변경 시 달력 레이아웃 리프레시
    }
    
    // MARK: - ⚙️ 초기 설정(Setup) 구역
    
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
        
        // 계획 부재 시 띄워줄 안내창 세팅
        emptyLabel.text = "등록된 계획이 없습니다"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = UIColor.secondaryLabel
        emptyLabel.font = UIFont.systemFont(ofSize: 14)
        plansTableView.backgroundView = emptyLabel
    }
    
    private func setupNavigationItems() {
        // 우상단 할 일 추가 [+] 버튼 장착
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    // MARK: - 🔄 화면 갱신(Reload) 로직 구역
    
    /// 새로운 달의 데이터를 바탕으로 달력 UI 리로드
    private func reloadMonth() {
        monthLabel.text = DateHelpers.monthTitle(for: currentMonth)
        dayItems = buildDays(for: currentMonth)
        collectionView.reloadData()
    }
    
    /// 선택된 날짜 레이블 텍스트 갱신
    private func updateSelectedDateLabel() {
        selectedDateLabel.text = DateHelpers.dateTitle(for: selectedDate)
    }
    
    /// 선택한 날짜에 맞는 계획 데이터 배열을 새로 읽어와 테이블 뷰 리로드
    private func reloadPlans() {
        let dateKey = DateHelpers.dateKey(from: selectedDate)
        plans = planStore.plans(for: dateKey)
        emptyLabel.isHidden = !plans.isEmpty // 계획이 있으면 안내 문구를 숨김
        plansTableView.reloadData()
    }
    
    // MARK: - 🕹️ 사용자 인터랙션 액션 처리 (월 이동)
    
    @IBAction private func didTapPrevMonth(_ sender: UIButton) { changeMonth(by: -1) } // ⬅️ 이전 달 버튼
    @IBAction private func didTapNextMonth(_ sender: UIButton) { changeMonth(by: 1) }  // ➡️ 다음 달 버튼
    
    private func changeMonth(by value: Int) {
        guard let next = DateHelpers.calendar.date(byAdding: .month, value: value, to: currentMonth) else { return }
        currentMonth = DateHelpers.startOfMonth(for: next)
        selectedDate = currentMonth // 월이 바뀌면 해당 월의 1일로 선택 날짜 강제 고정
        updateSelectedDateLabel()
        reloadPlans()
        reloadMonth()
    }
    
    // MARK: - 🧮 달력 42칸 날짜 매칭 알고리즘 생성기
    private func buildDays(for month: Date) -> [DayItem] {
        let calendar = DateHelpers.calendar
        let startOfMonth = DateHelpers.startOfMonth(for: month)
        let weekday = calendar.component(.weekday, from: startOfMonth)
        
        // 이번 달 1일이 시작하는 요일 위치 계산용 오프셋 구하기
        let offset = (weekday - calendar.firstWeekday + 7) % 7
        var items: [DayItem] = []
        
        // 고정된 6주(42일)판 생성 루프
        for index in 0..<42 {
            let dayOffset = index - offset
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfMonth) else { continue }
            
            let isInMonth = calendar.isDate(date, equalTo: startOfMonth, toGranularity: .month)
            let isToday = calendar.isDateInToday(date)
            let dateKey = DateHelpers.dateKey(from: date)
            let isSelected = dateKey == DateHelpers.dateKey(from: selectedDate)
            let hasHoliday = holidayStore.holidayName(for: dateKey) != nil // 일정이 등록되어 빨간 점을 찍을지 여부 판별
            let day = calendar.component(.day, from: date)
            
            items.append(DayItem(date: date, dayText: "\(day)", isInMonth: isInMonth, isToday: isToday, isSelected: isSelected, hasHoliday: hasHoliday))
        }
        return items
    }
    
    @objc private func didTapAdd() { presentEditor(for: nil) } // 플러스 버튼 클릭 시 새 창 열기
    
    /// 계획 작성 및 수정 전용 모달 편집창 열기 루틴
    private func presentEditor(for plan: Plan?) {
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "PlanEditViewController") as? PlanEditViewController else { return }
        viewController.selectedDate = selectedDate
        viewController.planToEdit = plan
        viewController.delegate = self
        
        let nav = UINavigationController(rootViewController: viewController)
        nav.modalPresentationStyle = .formSheet // 아이폰 스크린에 이쁜 카드 팝업 형태로 노출
        present(nav, animated: true)
    }
}

// MARK: - 🗂 UICollectionView 데이터 및 배치 프로토콜 구현
extension CalendarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dayItems.count // 42칸 고정 반환
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDayCell.reuseIdentifier, for: indexPath) as? CalendarDayCell else { return UICollectionViewCell() }
        let item = dayItems[indexPath.item]
        cell.configure(dayText: item.dayText, isInMonth: item.isInMonth, isToday: item.isToday, isSelected: item.isSelected, hasHoliday: item.hasHoliday)
        return cell
    }
}

extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    /// 기기 폭에 정확히 맞춰 날짜 칸 넓이를 7등분 계산 (오토레이아웃 보완)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 7
        return CGSize(width: floor(width), height: 48) // 가로폭 소수점 절사로 화면 깨짐 방지
    }
    
    /// 사용자가 특정 날짜 칸을 선택했을 때 동작 인터랙션
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dayItems[indexPath.item]
        selectedDate = item.date
        updateSelectedDateLabel()
        reloadPlans()
        
        if !item.isInMonth {
            // 이번 달이 아닌 흐린 날짜를 누르면 자동으로 해당 월 화면으로 이동시켜주는 편의 기능
            currentMonth = DateHelpers.startOfMonth(for: item.date)
            reloadMonth()
        } else {
            dayItems = buildDays(for: currentMonth)
            collectionView.reloadData()
        }
    }
}

// MARK: - 📋 UITableView 데이터 및 인터랙션 프로토콜 구현 (하단 계획 리스트)
extension CalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        plans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlanCell.reuseIdentifier, for: indexPath) as? PlanCell else { return UITableViewCell() }
        let plan = plans[indexPath.row]
        cell.configure(with: plan)
        
        // 🎯 [완료 토글 처리 Closure]: 계획 완수 시 체크박스 연동 처리
        cell.onToggle = { [weak self] in
            self?.planStore.toggleDone(id: plan.id)
            self?.reloadPlans()
        }
        return cell
    }
}

extension CalendarViewController: UITableViewDelegate {
    /// 등록된 특정 계획 한 줄을 누르면 수정 모달창을 열어줌
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let plan = plans[indexPath.row]
        presentEditor(for: plan)
    }
    
    /// 🗑 [왼쪽으로 밀어서 삭제 구현]: 사용자가 계획이 취소되어 필요 없어졌을 때 지우는 동작
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
            guard let self else { return }
            let plan = plans[indexPath.row]
            planStore.delete(id: plan.id) // 저장소에서 영구 삭제
            reloadPlans() // 삭제 내용 목록 리로드 반영
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
