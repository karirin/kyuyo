//
//  SalaryGraphDummyView.swift
//  kyuyo
//
//  Created by Apple on 2024/09/01.
//

import SwiftUI
import Firebase
import Charts

struct SalaryGraphDummyView: View {
    @ObservedObject var viewModel = SalaryGraphViewModel()
    
    var body: some View {
        ZStack{
            VStack {
                let salaryData = placeholderData()
                
                Chart(salaryData) { salary in
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
                .animation(.easeInOut(duration: 1.0), value: salaryData)
            }
            Color.black.opacity(0.3)
                .cornerRadius(30)
                .frame(height: 320)
        }
        .onAppear {
            viewModel.fetchSalaryHistorys()
        }
    }
    
    private func placeholderData() -> [SalaryHistory] {
        return [
            SalaryHistory(id: UUID().uuidString, salaryDay: "2024-01", cumulativeSalary: 100000),
            SalaryHistory(id: UUID().uuidString, salaryDay: "2024-02", cumulativeSalary: 200000),
            SalaryHistory(id: UUID().uuidString, salaryDay: "2024-03", cumulativeSalary: 300000),
            SalaryHistory(id: UUID().uuidString, salaryDay: "2024-04", cumulativeSalary: 400000),
            SalaryHistory(id: UUID().uuidString, salaryDay: "2024-05", cumulativeSalary: 500000)
        ]
    }
}


#Preview {
    SalaryGraphDummyView()
}
