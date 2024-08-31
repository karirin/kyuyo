//
//  GraphView.swift
//  kyuyo
//
//  Created by Apple on 2024/08/25.
//

import SwiftUI

struct GraphView: View {
    @ObservedObject var viewModel = SalaryGraphViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                Spacer()
                HStack{
                    Spacer()
                    ProgressView()
                        .scaleEffect(2)
                    Spacer()
                }
                Spacer()
            } else if viewModel.salaryHistorys.isEmpty {
                VStack(spacing: -40) {
                    Spacer()
                    Text("データありません\n月のお給料が入るとグラフ化されます")
                        .font(.system(size: 18))
                    Image("グラフ")
                        .resizable()
                        .scaledToFit()
                        .padding(40)
                    Spacer()
                }
            } else {
                Spacer()
                SalaryGraphView(viewModel: viewModel)
                VStack{
                    HStack {
                        Image(systemName: "dollarsign.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("現在までの累計給与金額")
                            .font(.system(size: 26))
                    }
                    Text("¥\(Int(viewModel.totalSalary))")  // 合計金額を表示
                        .font(.system(size: 50))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(radius: 1)
                )
                .padding()
                Spacer()
            }
        }
        .background(Color("backgroundColor"))
        .onAppear {
            viewModel.fetchSalaryHistorys()
        }
        .foregroundStyle(Color("fontGray"))
    }
}


#Preview {
    GraphView()
}
