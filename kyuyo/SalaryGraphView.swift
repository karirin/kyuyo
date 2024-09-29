import SwiftUI
import Firebase
import Charts

struct SalaryHistory: Identifiable, Equatable {
    let id: String
    let salaryDay: String
    let cumulativeSalary: Double
}

struct SalaryGraphView: View {
    @ObservedObject var viewModel = SalaryGraphViewModel()
    
    var body: some View {
        VStack {
            Chart(viewModel.salaryHistorys) { salary in
                LineMark(
                    x: .value("給料日", salary.salaryDay),
                    y: .value("累積給料", salary.cumulativeSalary)
                )
                .foregroundStyle(Color.green)
                .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("給料日", salary.salaryDay),
                    y: .value("累積給料", salary.cumulativeSalary)
                )
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.2), Color.green.opacity(0)]),
                    startPoint: .top,
                    endPoint: .bottom)
                )
                
                PointMark(
                    x: .value("給料日", salary.salaryDay),
                    y: .value("累積給料", salary.cumulativeSalary)
                )
                .symbolSize(10)
                .foregroundStyle(Color.green)
                
            }
            .chartXAxis(.hidden)
            .frame(height: 280)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                        .shadow(radius: 1)
            )
//            .padding()
            .animation(.easeInOut(duration: 1.0), value: viewModel.salaryHistorys)
        }
        .onAppear {
            viewModel.fetchSalaryHistorys()
        }
    }
}

class SalaryGraphViewModel: ObservableObject {
    @Published var salaryHistorys: [SalaryHistory] = []
    @Published var totalSalary: Double = 0.0
    @Published var isLoading: Bool = false  // データ取得中を示すプロパティ
    private let ref: DatabaseReference = Database.database().reference()
    private var hasFetchedData: Bool = false  // データ取得済みかを示すフラグ
    
    func fetchSalaryHistorys() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // データが既に取得されている場合は何もしない
        guard !hasFetchedData else { return }
        
        isLoading = true  // データ取得開始
        hasFetchedData = true  // フラグをtrueに設定
        
        let userRef = ref.child("salaryHistorys").child(userId)
        userRef.observeSingleEvent(of: .value) { snapshot in
            var historys: [SalaryHistory] = []
            var cumulativeSalary: Double = 0
            var totalSalary: Double = 0
            var lastYear: String?

            var tempHistorys: [(String, Double)] = []
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let value = childSnapshot.value as? [String: Any],
                   let salaryDay = value["salaryDay"] as? String,
                   let monthlySalary = value["monthlySalary"] as? Double {
                    
                    tempHistorys.append((salaryDay, monthlySalary))
                    totalSalary += monthlySalary  // 合計金額を計算
                }
            }
            
            tempHistorys.sort { $0.0 < $1.0 }
            
            for (salaryDay, monthlySalary) in tempHistorys {
                let year = String(salaryDay.prefix(4))  // 年を取得
                
                if lastYear != year {
                    lastYear = year
                } else {
                    let dateComponents = salaryDay.split(separator: "-")
                    if dateComponents.count == 3 {
                        let monthDay = dateComponents[1] + "-" + dateComponents[2]
                        cumulativeSalary += monthlySalary
                        let history = SalaryHistory(id: UUID().uuidString, salaryDay: String(monthDay), cumulativeSalary: cumulativeSalary)
                        historys.append(history)
                    }
                    continue
                }
                
                cumulativeSalary += monthlySalary
                let history = SalaryHistory(id: UUID().uuidString, salaryDay: salaryDay, cumulativeSalary: cumulativeSalary)
                historys.append(history)
            }
            
            DispatchQueue.main.async {
                self.salaryHistorys = historys
                self.totalSalary = totalSalary  // 合計金額をセット
                self.isLoading = false  // データ取得終了
            }
        }
    }
}



#Preview {
    SalaryGraphView()
}
