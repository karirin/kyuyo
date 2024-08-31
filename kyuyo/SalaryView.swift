import SwiftUI
import Firebase

struct SalaryCalculator {
    let salaryDay: Int
    let monthlySalary: Double
    let currentDate: Date

    var dailySalary: Double {
        return monthlySalary / 30.0 // 1ヶ月を30日と仮定
    }

    var hourlySalary: Double {
        return dailySalary / 24.0
    }

    var minutelySalary: Double {
        return hourlySalary / 60.0
    }

    var secondlySalary: Double {
        return minutelySalary / 60.0
    }

    func accumulatedSalary(for unit: TimeUnit) -> Double {
        let calendar = Calendar.current
        let currentDay = calendar.component(.day, from: currentDate)
        let currentHour = calendar.component(.hour, from: currentDate)
        let currentMinute = calendar.component(.minute, from: currentDate)
        let currentSecond = calendar.component(.second, from: currentDate)
        
        let daysPassed: Int
        if currentDay >= salaryDay {
            daysPassed = currentDay - salaryDay
        } else {
            daysPassed = 30 - salaryDay + currentDay
        }

        switch unit {
        case .day:
            return dailySalary * Double(daysPassed)
        case .hour:
            return dailySalary * Double(daysPassed) + hourlySalary * Double(currentHour)
        case .minute:
            return dailySalary * Double(daysPassed) + hourlySalary * Double(currentHour) + minutelySalary * Double(currentMinute)
        case .second:
            return dailySalary * Double(daysPassed) + hourlySalary * Double(currentHour) + minutelySalary * Double(currentMinute) + secondlySalary * Double(currentSecond)
        }
    }
    
    var progress: Double {
        let calendar = Calendar.current
        let currentDay = calendar.component(.day, from: currentDate)
        let daysPassed: Int
        if currentDay >= salaryDay {
            daysPassed = currentDay - salaryDay
        } else {
            daysPassed = 30 - salaryDay + currentDay
        }
        return Double(daysPassed) / 30.0
    }
}

extension Color {
    static let navy = Color(red: 0.0, green: 0.0, blue: 0.5) // #000080
    static let darkGray = Color(red: 0.33, green: 0.33, blue: 0.33) // #545454
    static let darkBrown = Color(red: 0.4, green: 0.26, blue: 0.13) // #654321
    static let lightBrown = Color(red: 0.71, green: 0.53, blue: 0.38) // #B38B6D
    static let beige = Color(red: 0.96, green: 0.96, blue: 0.86) // #F5F5DC
    static let darkPink = Color(red: 0.8, green: 0.24, blue: 0.44) // #CC3C70
    static let darkOrange = Color(red: 1.0, green: 0.55, blue: 0.0) // #FF8C00
    static let lightPink = Color(red: 1.0, green: 0.71, blue: 0.76) // #FFB6C1
    static let lightBlue = Color(red: 0.68, green: 0.85, blue: 0.9) // #ADD8E6
    static let darkRed = Color(red: 0.55, green: 0.0, blue: 0.0) // #8B0000
    static let darkBlue = Color(red: 0.0, green: 0.0, blue: 0.55) // #00008B
    static let darkPurple = Color(red: 0.25, green: 0.0, blue: 0.5)
    
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)

        let r = Double((hexNumber & 0xff0000) >> 16) / 255
        let g = Double((hexNumber & 0x00ff00) >> 8) / 255
        let b = Double(hexNumber & 0x0000ff) / 255

        self.init(red: r, green: g, blue: b)
    }
    
    func toHex() -> String? {
        let components = UIColor(self).cgColor.components
        let r = Float(components?[0] ?? 0)
        let g = Float(components?[1] ?? 0)
        let b = Float(components?[2] ?? 0)
        return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}

enum TimeUnit: String, CaseIterable, Identifiable {
    case day = "日"
    case hour = "時間"
    case minute = "分"
    case second = "秒"

    var id: String { self.rawValue }
}

struct ProgressRing: View, Animatable {
    var value = 0.0
    var gradient: LinearGradient

    var animatableData: Double {
        get { max(min(value, 1), 0) }
        set { value = max(min(newValue, 1), 0) }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 25)
                .foregroundStyle(.gray.opacity(0.3))
                .padding(isSmallDevice() ? -90 : -100)
            Circle()
                .trim(from: 0, to: value)
                .stroke(style: StrokeStyle(lineWidth: 25, lineCap: .round, lineJoin: .round))
                .foregroundStyle(gradient)
                .rotationEffect(.degrees(-90))
                .padding(isSmallDevice() ? -90 : -100)
                .animation(.easeInOut(duration: 4.0), value: value) // アニメーションの速度を調整
        }
        .frame(width: 150, height: 150)
        .onAppear{
            print("gradient:\(gradient)")
        }
    }
}

struct SalaryView: View {
    @State private var moveCoin = false
    @State private var fadeOutCoin = false
    @ObservedObject var authManager = AuthManager()
    @State private var currentDate: Date = Date()
    @State private var animatedProgress: Double = 0.0
    @State private var scaleEffect: CGFloat = 0.0
    var ref: DatabaseReference = Database.database().reference()
    @State private var salaryDay: Int = 25
    @State private var monthlySalary: Double = 0
    @State private var userId: String = ""
    @State private var csFlag: Bool = false
    @State private var showAlert: Bool = false
    @State private var selectedUnit: TimeUnit = .second
    @State private var selectedColor: Color = .gray.opacity(0.1)
    @State private var showModal = false
    @State private var modalFlag = false
    @State private var editFlag = false
    @State private var startFlag = false
    @State private var showCreateButton = false  // 新規作成ボタンを表示するための状態
    @State private var isLoading: Bool = true  // ローディング状態を管理するための状態
    @State private var accumulatedSalary: Double = 0

    var body: some View {
        ZStack {
            if isLoading {
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        ProgressView()
                            .scaleEffect(2)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                let calculator = SalaryCalculator(salaryDay: salaryDay, monthlySalary: monthlySalary, currentDate: currentDate)
                VStack {
                    Spacer()
                    if showCreateButton {
                        ZStack {
                            VStack {
                                Text("料日までの累計収入額")
                                    .font(.system(size: 38))
                                    .opacity(0.4)
                            }
                            .padding(20)
                            
                            Circle()
                                .stroke(lineWidth: 25)
                                .foregroundStyle(.gray.opacity(0.3))
                                .padding(isSmallDevice() ? -90 : -100)
                                .frame(width: 150, height: 150)
                            VStack{
                                Spacer()
                                HStack{
                                    Spacer()
                                    Text("")
                                    Spacer()
                                }
                                Spacer()
                            }
                            .background(Color(.gray).opacity(0.3))
                            VStack{
                                Button(action: {
                                    // 新規作成のアクション
                                    modalFlag = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 50))
                                }
                                Text("月のお給料と給料日を入力してください")
                                    .font(.system(size: 20))
                            }
                        }
                    } else {
                        ZStack {
                            VStack{
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        editFlag = true
                                    }) {
                                        Image(systemName: "gearshape.fill")
                                            .font(.system(size: 30))
                                    }
                                    .padding(5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color("fontGray"), lineWidth: 1)
                                    )
                                }.padding(.trailing)
                                Spacer()
                                    .frame(height: 110)
                                ZStack {
                                    VStack {
                                        Text("給料日までの収入額")
                                            .font(.system(size: 34))
                                        Text("¥\(Int(calculator.accumulatedSalary(for: selectedUnit)))")
                                            .font(.system(size: 54))
                                            .scaleEffect(scaleEffect)
                                            .animation(.easeInOut(duration: 1.0), value: scaleEffect)
                                    }
                                    .padding(20)
                                    
                                    ProgressRing(value: animatedProgress, gradient: LinearGradient(colors: [selectedColor, selectedColor.opacity(0.5)], startPoint: .top, endPoint: .bottom))
                                    }
//                                HStack{
//                                    
//                                    Button(action: {
//                                        showModal = true
//                                    }) {
//                                        HStack {
//                                            Image(systemName: "paintpalette")
//                                            Text("色を変更")
//                                        }
//                                        .padding(5)
//                                        .foregroundColor(Color("fontGray"))
//                                        .font(.system(size: 25))
//                                        .overlay(
//                                            RoundedRectangle(cornerRadius: 10)
//                                                .stroke(Color("fontGray"), lineWidth: 1)
//                                        )
//                                        .padding(.leading,3)
//                                    }
//                                }
                                Spacer()
                                Spacer()
                                Spacer()
                            }
                        }
                        .onAppear {
                            authManager.fetchUserFlag { userFlag, error in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else if let userFlag = userFlag {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        if userFlag == 0 {
                                            executeProcessEveryFifthTimes()
                                        }
                                    }
                                }
                            }
                           
                            withAnimation(.easeInOut(duration: 2.5)) {
                                scaleEffect = 1.0
                            }
                            moveCoin = true
                            fadeOutCoin = true
                            
                            if let user = Auth.auth().currentUser {
                                userId = user.uid
                                loadUserColor()
                            }
                            
                            Timer.scheduledTimer(withTimeInterval: 1000000, repeats: true) { _ in
                                currentDate = Date()
                                checkAndSaveSalaryHistory(calculator: calculator)
                            }
                            
                            Timer.scheduledTimer(withTimeInterval: selectedUnit == .second ? 1.0 : selectedUnit == .minute ? 60.0 : 3600.0, repeats: true) { _ in
                               currentDate = Date()
                               let calculator = SalaryCalculator(salaryDay: salaryDay, monthlySalary: monthlySalary, currentDate: currentDate)
                               withAnimation {
                                   animatedProgress = calculator.progress
                               }
                           }
                        }
                        .onChange(of: editFlag) { newValue in
                            if !newValue {
                                print("onchange")
                                print("isLoading1:\(isLoading)")
                                loadUserDataModal(){
                                    let calculator = SalaryCalculator(salaryDay: salaryDay, monthlySalary: monthlySalary, currentDate: currentDate)
                                    withAnimation {
                                        animatedProgress = calculator.progress
                                    }
                                }
                                print("isLoading2:\(isLoading)")
                            }
                        }
                    }
                    
                    Spacer()
                }
                .onChange(of: modalFlag) { newValue in
                    if newValue {
                        loadUserDataModal(){
                            print("onchange")
                            let calculator = SalaryCalculator(salaryDay: salaryDay, monthlySalary: monthlySalary, currentDate: currentDate)
                            withAnimation {
                                animatedProgress = calculator.progress
                            }
                        }
                    }
                }
            }
            
            if csFlag {
                HelpModalView(isPresented: $csFlag, showAlert: $showAlert)
            }
            
            if modalFlag {
                SalaryInputModalView(isPresented: $modalFlag, showAlert: $modalFlag)
            }
            
            if editFlag {
                EditModalView(isPresented: $editFlag, showAlert: $editFlag, selectedColor: $selectedColor, selectedUnit: $selectedUnit)
            }
            
            if startFlag {
                TutorialModalView(isPresented: $startFlag, showAlert: $startFlag)
            }
        }
        .onAppear {
            loadUserData(){
                let calculator = SalaryCalculator(salaryDay: salaryDay, monthlySalary: monthlySalary, currentDate: currentDate)
                withAnimation {
                    animatedProgress = calculator.progress
                }
            }
        }
        .sheet(isPresented: $showModal) {
            ColorPickerView(selectedColor: $selectedColor)
                .presentationDetents([
                    .large,
                    .fraction(isSmallDevice() ? 0.50 : 0.40)
                ])
        }
        .background(Color("backgroundColor"))
        .foregroundColor(Color("fontGray"))
    }

    func loadUserData(completion: @escaping () -> Void) {
        isLoading = true  // ローディングを開始
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            isLoading = false  // ローディングを終了
            return
        }
        ref.child("salarySettings").child(userId).observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                if let salaryDay = value["salaryDay"] as? Int,
                   let monthlySalary = value["monthlySalary"] as? Double {
                    self.salaryDay = salaryDay
                    self.monthlySalary = monthlySalary
                    self.showCreateButton = false
                } else {
                    self.showCreateButton = true  // データが存在しない場合、新規作成ボタンを表示
                }
            } else {
                self.showCreateButton = true  // データが存在しない場合、新規作成ボタンを表示
            }
            isLoading = false  // ローディングを終了
            completion() // データ取得完了後にクロージャを呼び出す
        }
    }
    
    func loadUserDataModal(completion: @escaping () -> Void) {
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
                    self.showCreateButton = false
                } else {
                    self.showCreateButton = true  // データが存在しない場合、新規作成ボタンを表示
                }
            } else {
                self.showCreateButton = true  // データが存在しない場合、新規作成ボタンを表示
            }
            completion() // データ取得完了後にクロージャを呼び出す
        }
    }

    func loadUserColor() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let userRef = Database.database().reference().child("users").child(userId)
        userRef.child("selectedColor").observeSingleEvent(of: .value) { snapshot in
            if let hexString = snapshot.value as? String {
                selectedColor = Color(hex: hexString)
            }
        }
    }

    func checkAndSaveSalaryHistory(calculator: SalaryCalculator) {
        let calendar = Calendar.current
        let currentDay = calendar.component(.day, from: currentDate)
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let salaryHistoryRef = ref.child("salaryHistorys").child(userId)
        let userSettingsRef = ref.child("salarySettings").child(userId)
        
        userSettingsRef.child("lastSalarySavedDate").observeSingleEvent(of: .value) { snapshot in
            let lastSalarySavedDateString = snapshot.value as? String ?? ""
            let lastSalarySavedDate = dateFormatter.date(from: lastSalarySavedDateString) ?? Date.distantPast
            
            var currentCheckDate = lastSalarySavedDate
            var daysToCheck = 0
            
            while currentCheckDate < currentDate {
                currentCheckDate = calendar.date(byAdding: .day, value: 1, to: currentCheckDate) ?? currentCheckDate
                daysToCheck += 1
                
                let dayComponent = calendar.component(.day, from: currentCheckDate)
                if dayComponent == self.salaryDay {
                    let salaryData = [
                        "monthlySalary": self.monthlySalary,
                        "salaryDay": dateFormatter.string(from: currentCheckDate)
                    ] as [String : Any]
                    salaryHistoryRef.childByAutoId().setValue(salaryData)
                }
            }
            
            userSettingsRef.child("lastSalarySavedDate").setValue(dateFormatter.string(from: currentDate))
        }
    }

    func executeProcessEveryFifthTimes() {
        let countForTenTimes = UserDefaults.standard.integer(forKey: "launchCountForThreeTimes") + 1
        UserDefaults.standard.set(countForTenTimes, forKey: "launchCountForThreeTimes")
        
        if countForTenTimes % 10 == 0 {
            csFlag = true
        }
    }

}

func isSmallDevice() -> Bool {
    return UIScreen.main.bounds.width < 390
}

// 日付をフォーマットするためのヘルパー
var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

#Preview {
    SalaryView()
}
