//
//  kyuyoApp.swift
//  kyuyo
//
//  Created by Apple on 2024/08/19.
//

import SwiftUI
import Firebase
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知の許可が得られました。")
            } else if let error = error {
                print("通知の許可エラー: \(error.localizedDescription)")
            }
        }
    }
}

extension NotificationManager {
    func scheduleSalaryNotification(salaryDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "給料日が近づいています！"
        content.body = "給料日がもうすぐです。家計簿をチェックしましょう。"
        content.sound = .default
        
        // 給料日の3日前に通知を設定
        if let triggerDate = Calendar.current.date(byAdding: .day, value: -3, to: salaryDate), triggerDate > Date() {
            let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: "salaryNotification", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("給料日通知のスケジュールエラー: \(error.localizedDescription)")
                } else {
                    print("給料日通知が正常にスケジュールされました。")
                }
            }
        } else {
            print("通知をスケジュールする日付が過去です。")
        }
    }
    
    func removeSalaryNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["salaryNotification"])
    }
}


@main
struct kyuyoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        FirebaseApp.configure()
        NotificationManager.shared.requestNotificationAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            TopView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let userDefaults = UserDefaults.standard
        if !userDefaults.bool(forKey: "hasLaunchedBefore") {
            let authManager = AuthManager()
            authManager.anonymousSignIn(){
                DispatchQueue.main.async {
                    // createUserの完了を待ってからisLoadingを更新
                    authManager.createUser() {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        DispatchQueue.main.async {
//                            self.goalViewModel.createSampleGoal()
//                            self.goalViewModel.createSampleReward()
//                            self.goalViewModel.isLoading = false // ここでisLoadingを更新
                            print("USERID:\(authManager.currentUserId!)")
                        }
                    }
                }
            }
            userDefaults.set(true, forKey: "hasLaunchedBefore")
            userDefaults.synchronize()
        }
        return true
    }
}
