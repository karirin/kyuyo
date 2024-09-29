//
//  rewardView.swift
//  kyuyo
//
//  Created by Apple on 2024/08/29.
//

import SwiftUI
import Firebase

struct Reward: Identifiable, Equatable {
    var id: String
    var title: String
    var amount: Double
    var icon: String
    var flag: Bool
    
    static func ==(lhs: Reward, rhs: Reward) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.amount == rhs.amount &&
               lhs.icon == rhs.icon &&
               lhs.flag == rhs.flag
    }
}

struct RewardView: View {
    @State private var currentDate: Date = Date()
    @State private var salaryDay: Int = 25
    @State private var monthlySalary: Double = 0
    var ref: DatabaseReference = Database.database().reference()
    @State private var showModal = false
    @State private var showRewardModal = false
    @State private var userId: String = ""
    @State private var rewards: [Reward] = [] // 取得したデータを保持する配列
    @State private var isLoading: Bool = true // データ取得中を示すプロパティ
    @State private var alertQueue: [Reward] = [] // アラート表示のためのキュー
    @State private var isShowingAlert = false // アラートが表示されているかを管理するフラグ
    @State private var showDeleteConfirmation = false // 削除確認アラートを表示するかどうか
    @State private var rewardToDelete: Reward? // 削除対象のリワード
    @State private var rewardStartFlag: Bool = false
    @State private var selectedUnit: TimeUnit = .second
    @ObservedObject var salaryGraphViewModel = SalaryGraphViewModel()

    let colorPalette: [Color] = [
        .blue.opacity(0.4),
        .green.opacity(0.4),
        .orange.opacity(0.4),
        .purple.opacity(0.4),
        .pink.opacity(0.4),
        .red.opacity(0.4),
        .yellow.opacity(0.4),
        .gray.opacity(0.4),
        .teal.opacity(0.4),
        .indigo.opacity(0.4)
    ]

    var body: some View {
        ZStack{
            VStack {
                if isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(2)
                    Spacer()
                } else if rewards.isEmpty {
                    VStack(spacing: -40) {
                        HStack{
                            Image("questionmark.circle")
                        }
                        Spacer()
                        Text("ご褒美が登録されていません\n右下のボタンから追加できます")
                            .font(.system(size: 18))
                        Image("ご褒美が無い")
                            .resizable()
                            .scaledToFit()
                            .padding(40)
                        Spacer()
                    }
                } else {
                    HStack{
                        Spacer()
                        Button(action: {
                            rewardStartFlag = true
                        }, label: {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 30))
                        })
                    }.padding(.trailing)
                    ScrollView {
                        ForEach(rewards.indices, id: \.self) { index in
                            let reward = rewards[index]
                            ZStack(alignment: .leading) {
                                let calculator = SalaryCalculator(salaryDay: salaryDay, monthlySalary: monthlySalary, currentDate: currentDate)
                                let accumulatedSalary = calculator.accumulatedSalary(for: .second) + salaryGraphViewModel.totalSalary
                                let percentage = accumulatedSalary / reward.amount * 100
                                
                                Rectangle()
                                    .fill(colorPalette[index % colorPalette.count])
                                    .frame(width: CGFloat(min(percentage / 100.0, 1.0)) * UIScreen.main.bounds.width, height: 80)
                                    .padding(.horizontal, -10)
                                
                                HStack {
                                    Image(reward.icon)
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading) {
                                        Text(reward.title)
                                            .font(.system(size: isSmallDevice() ? fontSizeSE(for: reward.title, isIPad: isIPad()) : fontSize(for: reward.title, isIPad: isIPad())))
                                        HStack{
                                            Text("¥\(Int(calculator.accumulatedSalary(for: .second) + salaryGraphViewModel.totalSalary))  /")
                                                .font(.system(size: 18))
                                            Text(String(format: "¥%.0f ", reward.amount))
                                                .font(.system(size: 25))
                                            Spacer()
                                            // 削除ボタンを追加
                                            Button(action: {
                                                rewardToDelete = reward // 削除対象を設定
                                                showDeleteConfirmation = true // アラートを表示
                                            }) {
                                                Image(systemName: "trash.fill")
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.leading, 10)
                                .onAppear {
                                    salaryGraphViewModel.fetchSalaryHistorys()
                                    print("accumulatedSalary:\(accumulatedSalary)")
                                    if percentage >= 100 && !reward.flag {
                                        DispatchQueue.main.async {
                                            showAlert(for: reward) // ここでshowAlertを呼び出す
                                            updateRewardFlag(reward)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 1)
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                        .padding(.top,5)
                        .padding(.bottom, 70)
                    }
                    Spacer()
                }
            }
            
            if rewardStartFlag {
                RewardTutorialModalView(isPresented: $rewardStartFlag, showAlert: $rewardStartFlag)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
            ZStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                showModal = true
                            }, label: {
                                Image(systemName: "plus")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 24))
                            })
                            .frame(width: 60, height: 60)
                            .background(Color("buttonColor"))
                            .cornerRadius(30.0)
                            .shadow(radius: 5)
                            .padding()
                        }
                    }
                }
            }
        )
        .sheet(isPresented: $showModal) {
            RewardInputModalView(isPresented: $showModal) { title, amount, icon in
                saveReward(title: title, amount: amount, icon: icon)
            }
            .presentationDetents([
                .large,
                .fraction(isSmallDevice() ? 0.60 : 0.50)
            ])
        }
        .background(Color("backgroundColor"))
        .foregroundColor(Color("fontGray"))
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("ご褒美の削除"),
                message: Text("このご褒美を削除してもよろしいですか？"),
                primaryButton: .destructive(Text("削除")) {
                    if let reward = rewardToDelete {
                        deleteReward(reward)
                    }
                },
                secondaryButton: .cancel(Text("キャンセル"))
            )
        }
        .onAppear {
            loadUserData() {
                fetchRewards() // rewardsデータの取得を呼び出す
            }
            if let user = Auth.auth().currentUser {
                userId = user.uid
            }
            
            let userDefaults = UserDefaults.standard
            if !userDefaults.bool(forKey: "hasLaunchedTutorialRewardFlag") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    rewardStartFlag = true
                }
            }
            userDefaults.set(true, forKey: "hasLaunchedTutorialRewardFlag")
            userDefaults.synchronize()
        }
        .onChange(of: alertQueue) { _ in
            processNextAlert()
        }
    }

    // Firebaseからrewardsデータを取得する関数
    func fetchRewards() {
        guard !userId.isEmpty else {
            print("ユーザーIDが取得できませんでした")
            return
        }

        ref.child("rewards").child(userId).observe(.value) { snapshot in
            var fetchedRewards: [Reward] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let value = childSnapshot.value as? [String: Any],
                   let title = value["title"] as? String,
                   let amount = value["amount"] as? Double,
                   let icon = value["icon"] as? String,
                   let flag = value["flag"] as? Bool { // ここでflagを取得
                    let reward = Reward(id: childSnapshot.key, title: title, amount: amount, icon: icon, flag: flag)
                    fetchedRewards.append(reward)
                }
            }
            self.rewards = fetchedRewards
            self.isLoading = false // データ取得完了後にローディング終了
        }
    }

    // Firebaseからリワードを削除する関数
    func deleteReward(_ reward: Reward) {
        guard !userId.isEmpty else {
            print("ユーザーIDが取得できませんでした")
            return
        }

        ref.child("rewards").child(userId).child(reward.id).removeValue { error, _ in
            if let error = error {
                print("削除に失敗しました: \(error.localizedDescription)")
            } else {
                print("リワードが削除されました")
                // ローカルのリワードリストからも削除
                if let index = rewards.firstIndex(where: { $0.id == reward.id }) {
                    rewards.remove(at: index)
                }
            }
        }
    }

    func saveReward(title: String, amount: Double, icon: String) {
        guard !userId.isEmpty else {
            print("ユーザーIDが取得できませんでした")
            return
        }

        let rewardData: [String: Any] = [
            "title": title,
            "amount": amount,
            "icon": icon,
            "flag": false
        ]

        ref.child("rewards").child(userId).childByAutoId().setValue(rewardData) { error, _ in
            if let error = error {
                print("データの保存に失敗しました: \(error.localizedDescription)")
            } else {
                print("データが保存されました")
            }
        }
    }
    
    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func fontSize(for text: String, isIPad: Bool) -> CGFloat {
        let baseFontSize: CGFloat = isIPad ? 34 : 30 // iPad用のベースフォントサイズを大きくする

        let englishAlphabet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let textCharacterSet = CharacterSet(charactersIn: text)

        if englishAlphabet.isSuperset(of: textCharacterSet) {
            return baseFontSize
        } else {
            if text.count >= 14 {
                return baseFontSize - 12
            } else if text.count >= 12 {
                return baseFontSize - 10
            } else if text.count >= 10 {
                return baseFontSize - 8
            } else if text.count >= 8 {
                return baseFontSize - 6
            } else {
                return baseFontSize
            }
        }
    }
    
    func fontSizeSE(for text: String, isIPad: Bool) -> CGFloat {
        let baseFontSize: CGFloat = isIPad ? 34 : 30 // iPad用のベースフォントサイズを大きくする

        let englishAlphabet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let textCharacterSet = CharacterSet(charactersIn: text)

        if englishAlphabet.isSuperset(of: textCharacterSet) {
            return baseFontSize
        } else {
            if text.count >= 14 {
                return baseFontSize - 12
            } else if text.count >= 12 {
                return baseFontSize - 10
            } else if text.count >= 10 {
                return baseFontSize - 8
            } else if text.count >= 8 {
                return baseFontSize - 6
            } else {
                return baseFontSize
            }
        }
    }
    

    func loadUserData(completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }
        ref.child("salarySettings").child(userId).observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                if let salaryDay = value["salaryDay"] as? Int,
                   let monthlySalary = value["monthlySalary"] as? Double {
                    self.salaryDay = salaryDay
                    self.monthlySalary = monthlySalary
                }
            }
            completion()
        }
    }
    
    func showAlert(for reward: Reward) {
        alertQueue.append(reward) // アラートをキューに追加
    }

    func updateRewardFlag(_ reward: Reward) {
        guard !userId.isEmpty else {
            print("ユーザーIDが取得できませんでした")
            return
        }
        ref.child("rewards").child(userId).child(reward.id).updateChildValues(["flag": true]) { error, _ in
            if let error = error {
                print("フラグの更新に失敗しました: \(error.localizedDescription)")
            } else {
                print("フラグが更新されました")
            }
        }
    }

    func processNextAlert() {
        guard !isShowingAlert, let nextReward = alertQueue.first else { return }

        isShowingAlert = true

        let alert = UIAlertController(title: "おめでとうございます！", message: "\(nextReward.title)を達成しました！", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.isShowingAlert = false
            self.alertQueue.removeFirst()
            self.processNextAlert() // 次のアラートを表示
        }))

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(alert, animated: true, completion: nil)
        }
    }
}

#Preview {
    RewardView()
}
