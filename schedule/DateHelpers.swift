import Foundation

/// 🧮 '스케줄' 앱의 모든 날짜 연산과 텍스트 변환을 총괄하는 유틸리티 열거형
enum DateHelpers {
    
    /// 🗓 대한민국 국가 표준 및 월요일 시작 기준으로 커스텀된 달력 객체
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR") // 한국 언어 및 환경 고정
        calendar.timeZone = TimeZone.current          // 사용자 기기의 현재 시차 반영
        calendar.firstWeekday = 2                     // 💡 1: 일요일, 2: 월요일 시작 달력으로 설정
        return calendar
    }()
    
    // MARK: - ⚙️ 데이터 변환기(DateFormatter) 세팅
    
    /// 🔑 데이터를 저장하고 불러올 때 쓸 고유 날짜 키 포맷터 ("2026-06-06")
    static let dateKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    /// 🏷 메인 달력 상단 제목용 포맷터 ("2026년 6월")
    static let monthTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy년 M월"
        return formatter
    }()
    
    /// 📍 하단 선택된 날짜 상세 안내용 포맷터 ("2026년 6월 6일 (토)")
    static let dateTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy년 M월 d일 (E)" // (E)는 요일을 한 글자로 표현합니다.
        return formatter
    }()
    
    // MARK: - 🔄 실전 활용 함수(Interface)
    
    /// Date 객체를 데이터베이스 조회용 고유 문자열 키로 변환합니다.
    static func dateKey(from date: Date) -> String {
        dateKeyFormatter.string(from: date)
    }
    
    /// 해당 날짜가 속한 월의 메인 타이틀 글자를 반환합니다.
    static func monthTitle(for date: Date) -> String {
        monthTitleFormatter.string(from: date)
    }
    
    /// 해당 날짜의 상세 일자 텍스트를 요일과 함께 반환합니다.
    static func dateTitle(for date: Date) -> String {
        dateTitleFormatter.string(from: date)
    }
    
    /// 🧮 입력된 날짜를 기준으로 해당 월의 '1일' 데이터를 정확히 계산해 줍니다.
    static func startOfMonth(for date: Date) -> Date {
        // 연도와 월 데이터만 추출하여 일자를 1일로 초기화하는 정밀 연산
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }
}
