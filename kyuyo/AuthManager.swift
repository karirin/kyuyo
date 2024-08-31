//
//  AuthManager.swift
//  smallGaol
//
//  Created by Apple on 2024/03/22.
//

import SwiftUI
import Firebase

class AuthManager: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var rewardPoint: Int = 0
    @Published var dateRangeText: String = ""
    var onLoginCompleted: (() -> Void)?
    
    init() {
        user = Auth.auth().currentUser
//        if user == nil {
//            anonymousSignIn(){}
//        }
//        createUser()
    }
    
    var currentUserId: String? {
        print("user?.uid:\(user?.uid)")
        return user?.uid
    }
        
    func createUser(completion: @escaping () -> Void) {

        guard let userId = user?.uid else {
            print("ユーザーがログインしていません")
            completion() // 早期リターン時にもコールバックを呼ぶ
            return
        }
        let userRef = Database.database().reference().child("users").child(userId)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let currentDate = dateFormatter.string(from: Date())
        
        userRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
//                if let rewardPoint = snapshot.value as? Int {
//                    DispatchQueue.main.async {
//                        self.rewardPoint = rewardPoint
//                        completion() // 非同期処理完了後にコールバックを実行
//                    }
//                }
            } else {
                userRef.setValue(["createTime": currentDate, "tutorialNum": 1,"userFlag": 0, "selectedColor": 000080]) { error, _ in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("ユーザー作成時にエラーが発生しました: \(error.localizedDescription)")
                        } else {
                            self.rewardPoint = 0
                            print("新しいユーザーが作成されました。rewardPointは0からスタートします。")
                        }
                        completion() // エラーの有無にかかわらず、処理完了後にコールバックを実行
                    }
                }
            }
        }
    }

    
    func parseDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.date(from: dateString)
    }

    // 指定された日付から1週間の範囲の文字列を生成する
    func calculateDateRange(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d" // 表示形式

        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: date)!
        return "\(dateFormatter.string(from: date))〜\(dateFormatter.string(from: endDate))"
    }
    
    func fetchUserTimeAndCalculateRange(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            completion(false) // ユーザーIDが取得できなかった場合は、ここで処理を終了し、falseを返します。
            return
        }

        let userRef = Database.database().reference().child("users").child(userId)
        userRef.child("userTime").observeSingleEvent(of: .value) { snapshot in
            if let dateString = snapshot.value as? String, let date = self.parseDate(from: dateString) {
                let rangeText = self.calculateDateRange(from: date)
                DispatchQueue.main.async {
                    self.dateRangeText = rangeText
                    completion(true) // dateRangeTextに値がセットされたので、trueを返します。
                }
            } else {
                completion(false) // dateStringの取得または変換に失敗した場合は、falseを返します。
            }
        }
    }
    
    func updateSalaryInfo(userId: String, salaryDay: Int, monthlySalary: Double, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("salarySettings").child(userId)
        let updates = [
            "salaryDay": salaryDay,
            "monthlySalary": monthlySalary
        ] as [String : Any]
        
        userRef.updateChildValues(updates) { (error, _) in
            if let error = error {
                print("給料日と月給の更新に失敗しました: \(error)")
                completion(false)
            } else {
                print("給料日と月給が正常に更新されました")
                completion(true)
            }
        }
    }
    
    func fetchUserFlag(completion: @escaping (Int?, Error?) -> Void) {
        guard let userId = user?.uid else {
            // ユーザーIDがnilの場合、すなわちログインしていない場合
            let error = NSError(domain: "AuthManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "ログインしていません。"])
            completion(nil, error)
            return
        }

        let userRef = Database.database().reference().child("users").child(userId)
        // "userFlag"の値を取得する
        userRef.child("userFlag").observeSingleEvent(of: .value) { snapshot in
            if let userFlag = snapshot.value as? Int {
                // userFlagが存在し、Int型として取得できた場合
                DispatchQueue.main.async {
                    completion(userFlag, nil)
                }
            } else {
                // userFlagが存在しない、または想定外の形式である場合
                let error = NSError(domain: "AuthManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "userFlagを取得できませんでした。"])
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        } withCancel: { error in
            // データベースの読み取りに失敗した場合
            DispatchQueue.main.async {
                completion(nil, error)
            }
        }
    }


    func updateUserDataIfNeeded(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false) // ユーザーIDが取得できない場合は、false を返して終了します。
            return
        }
        let userRef = Database.database().reference().child("users").child(userId)

        userRef.child("userTime").observeSingleEvent(of: .value, with: { snapshot in
            if let userTimeString = snapshot.value as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd" // userTimeString のフォーマットに合わせてください。
                dateFormatter.locale = Locale(identifier: "ja_JP")

                if let userTime = dateFormatter.date(from: userTimeString),
                   let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()),
                   userTime < oneWeekAgo {
                    // userTime を現在時刻に更新します。
                    let newTime = dateFormatter.string(from: Date())
                    userRef.child("userTime").setValue(newTime)

                    // 関連する goals の goalFlag を 0 に更新します。
                    let goalsRef = Database.database().reference().child("goals").child(userId)
                    goalsRef.queryOrdered(byChild: "userId").queryEqual(toValue: userId).observeSingleEvent(of: .value, with: { snapshot in
                        guard let goals = snapshot.value as? [String: AnyObject] else {
                            completion(false) // ゴールが見つからない場合は、false を返します。
                            return
                        }

                        for (key, _) in goals {
                            goalsRef.child(key).child("goalFlag").setValue(0)
                            goalsRef.child(key).child("currentCount").setValue(0)
                        }
                        completion(true) // 成功した場合は true を返します。
                    })
                } else {
                    completion(false) // userTime が 1 週間よりも前ではない場合は、false を返します。
                }
            } else {
                completion(false) // userTime が取得できない場合は、false を返します。
            }
        })
    }

    
    func anonymousSignIn(completion: @escaping () -> Void) {
        print("anonymousSignIn")
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let result = result {
                print("Signed in anonymously with user ID: \(result.user.uid)")
                self.user = result.user
                self.onLoginCompleted?()
            }
            completion()
        }
    }
    
    func updateTutorialNum(userId: String, tutorialNum: Int, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        let updates = ["tutorialNum": tutorialNum]
        userRef.updateChildValues(updates) { (error, _) in
            if let error = error {
                print("Error updating tutorialNum: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func fetchUserRewardPoint(completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else { return }

        let userRef = Database.database().reference().child("users").child(userId)
        userRef.child("rewardPoint").observeSingleEvent(of: .value) { snapshot in
            if let rewardPoint = snapshot.value as? Int {
                DispatchQueue.main.async {
                    self.rewardPoint = rewardPoint
                    completion(true)
                }
            }
        }
    }
    
    func updateUserFlag(userId: String, userFlag: Int, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        let updates = ["userFlag": userFlag]
        userRef.updateChildValues(updates) { (error, _) in
            if let error = error {
                print("Error updating tutorialNum: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // tutorialNumを取得する関数
    func fetchTutorialNum(completion: @escaping (Int?, Error?) -> Void) {
        guard let userId = user?.uid else {
            print("fetchTutorialNum1")
            return
        }
        let userRef = Database.database().reference().child("users").child(userId)
        // "tutorialNum"の値を取得する
        userRef.child("tutorialNum").observeSingleEvent(of: .value) { snapshot in
            print("fetchTutorialNum1:\(snapshot)")
            // snapshotが存在し、Intとしてcastできる場合、その値をcompletionブロックに渡して返す
            if let tutorialNum = snapshot.value as? Int {
                DispatchQueue.main.async {
                    print("fetchTutorialNum2")
                    completion(tutorialNum, nil)
                }
            } else {
                // tutorialNumが存在しないか、適切な形式でない場合、エラーを返す
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "tutorialNumを取得できませんでした。"])
                DispatchQueue.main.async {
                    print("fetchTutorialNum3")
                    completion(nil, error)
                }
            }
        } withCancel: { error in
            // データベースの読み取りに失敗した場合、エラーを返す
            DispatchQueue.main.async {
                print("fetchTutorialNum4")
                completion(nil, error)
            }
        }
    }

    
    func decreaseRewardPoint(decrementPoints: Int, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            completion(false, nil)
            return
        }
        let userRef = Database.database().reference().child("users").child(userId)

        // rewardPointの現在値を取得
        userRef.child("rewardPoint").observeSingleEvent(of: .value, with: { snapshot in
            if let currentPoints = snapshot.value as? Int {
                // 新しいポイントが0以上になることを確認する
                let updatedPoints = currentPoints - decrementPoints
                if updatedPoints >= 0 {
                    // 新しいポイントで更新
                    userRef.child("rewardPoint").setValue(updatedPoints, withCompletionBlock: { error, _ in
                        if let error = error {
                            print("報酬ポイントの減算に失敗しました: \(error)")
                            completion(false, error)
                        } else {
                            print("報酬ポイントが正常に減算されました")
                            completion(true, nil)
                        }
                    })
                } else {
                    // ポイントが足りない場合はエラーを返す
                    print("ポイントが足りません。現在のポイント: \(currentPoints)")
                    completion(false, NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "ポイントが足りません。"]))
                }
            } else {
                print("現在のポイントを取得できませんでした。")
                completion(false, NSError(domain: "AppErrorDomain", code: -2, userInfo: [NSLocalizedDescriptionKey: "現在のポイントを取得できませんでした。"]))
            }
        }) { error in
            print(error.localizedDescription)
            completion(false, error)
        }
    }

    func updateRewardPoint(additionalPoints: Int, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            completion(false, nil) // ログインしていない場合、エラーを返す
            return
        }

        let userRef = Database.database().reference().child("users").child(userId)
        // rewardPointの現在値を取得して更新する
        userRef.child("rewardPoint").observeSingleEvent(of: .value, with: { snapshot in
            if let currentPoints = snapshot.value as? Int {
                let updatedPoints = currentPoints + additionalPoints
                // 新しいポイントで更新
                userRef.child("rewardPoint").setValue(updatedPoints, withCompletionBlock: { error, _ in
                    if let error = error {
                        print("報酬ポイントの更新に失敗しました: \(error)")
                        completion(false, error)
                    } else {
                        print("報酬ポイントが更新されました")
                        completion(true, nil)
                    }
                })
            } else {
                print("現在のポイントを取得できませんでした。")
                completion(false, nil) // ポイント取得失敗時のエラー処理
            }
        }) { error in
            print(error.localizedDescription)
            completion(false, error) // 監視処理失敗時のエラー処理
        }
    }

    
    func updateContact(userId: String, newContact: String, completion: @escaping (Bool) -> Void) {
        // contactテーブルの下の指定されたuserIdの参照を取得
        let contactRef = Database.database().reference().child("contacts").child(userId)
        // まず現在のcontactの値を読み取る
        contactRef.observeSingleEvent(of: .value, with: { snapshot in
            // 既存の問い合わせ内容を保持する変数を準備
            var contacts: [String] = []
            
            // 現在の問い合わせ内容がある場合、それを読み込む
            if let currentContacts = snapshot.value as? [String] {
                contacts = currentContacts
            }
            
            // 新しい問い合わせ内容をリストに追加
            contacts.append(newContact)
            
            // データベースを更新する
            contactRef.setValue(contacts, withCompletionBlock: { error, _ in
                if let error = error {
                    print("Error updating contact: \(error)")
                    completion(false)
                } else {
                    completion(true)
                }
            })
        }) { error in
            print(error.localizedDescription)
            completion(false)
        }
    }
    
    func deleteUserAccount(completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.removeValue { error, _ in
            if let error = error {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
    }
    
    func updateUserColor(userId: String, color: Color, completion: @escaping (Bool) -> Void) {
        guard let hexColor = color.toHex() else {
            print("Color conversion to HEX failed.")
            completion(false)
            return
        }

        let userRef = Database.database().reference().child("users").child(userId)
        userRef.updateChildValues(["selectedColor": hexColor]) { error, _ in
            if let error = error {
                print("Error updating user color: \(error)")
                completion(false)
            } else {
                print("User color updated successfully.")
                completion(true)
            }
        }
    }
}

struct AuthManager1: View {
    @ObservedObject var authManager = AuthManager()

    var body: some View {
        VStack {
            if authManager.user == nil {
                Text("Not logged in")
            } else {
                Text("Logged in with user ID: \(authManager.user!.uid)")
            }
            Button(action: {
                if self.authManager.user == nil {
                    self.authManager.anonymousSignIn(){}
                }
            }) {
                Text("Log in anonymously")
            }
        }
    }
}

struct AuthManager_Previews: PreviewProvider {
    static var previews: some View {
        AuthManager1()
    }
}


