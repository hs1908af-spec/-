//
//  AppDelegate.swift
//  schedule
//
//  Created by 문현서 on 6/2/26.
//

import UIKit

@main//시스템이 앱을 실행할 때 가장 먼저 찾아오는 시작점.
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // '스케줄' 앱이 켜질 때 사용자가 저장해 둔 과거의 계획 데이터를 안전하게 불러올 준비를 합니다.
        return true
    }

    // 화면(Scene) 연결 상태 관리 단계

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
       // 메인 화면인 'Default Configuration'(SceneDelegate)을 연결하여 사용자가 달력을 볼 수 있게 합니다.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
 /// 사용자가 멀티태스킹 창에서 '스케줄' 앱의 화면을 위로 쓸어올려 완전히 닫았을 때(종료) 호출됩니다.
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // 사용자가 앱 화면을 완전히 종료했을 때 메모리를 해제하는 역할을 합니다. '스케줄' 앱이 불필요한 기기 메모리를 차지하지 않도록 최적화하는 역할
    }


}

