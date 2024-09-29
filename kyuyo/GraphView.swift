//
//  GraphView.swift
//  kyuyo
//
//  Created by Apple on 2024/08/25.
//

import SwiftUI

struct GraphView: View {
    @ObservedObject var viewModel = SalaryGraphViewModel()
    @ObservedObject var authManager = AuthManager()
    
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
                VStack(spacing: 20) {
                    if let createTime = authManager.userData?.createTime {
                        VStack {
                            HStack{
                                Image(systemName: "calendar.circle")
                                    .resizable()
                                    .frame(width: 30,height: 30)
                                Text("\(createTime)から現在まで")
                                    .font(.system(size: isSmallDevice() ? 23 : 25))
                                    .bold()
                            }
                        }.frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                                    .shadow(radius: 1)
                            )
                    }
                    ZStack {
                        SalaryGraphDummyView()
                            .frame(maxWidth: .infinity)
                        Text("データがありません\n月のお給料が入るとグラフ化されます")
                            .bold()
                            .font(.system(size: isSmallDevice() ? 18 : 20))
                    }
                    VStack{
                        HStack {
                            Image(systemName: "dollarsign.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Text("累計給与金額")
                                .font(.system(size: 36))
                        }
                        Text("¥0")  // 合計金額を表示
                            .font(.system(size: 50))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(radius: 1)
                    )
                }
                .frame(maxWidth: .infinity,maxHeight: .infinity)
                .padding()
            } else {
                Spacer()
                VStack(spacing: 20) {
                    if let createTime = authManager.userData?.createTime {
                        VStack {
                            HStack{
                                Image(systemName: "calendar.circle")
                                    .resizable()
                                    .frame(width: 30,height: 30)
                                Text("\(createTime)から現在まで")
                                    .font(.system(size: isSmallDevice() ? 23 : 25))
                                    .bold()
                            }
                        }.frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                                    .shadow(radius: 1)
                            )
                    }
                    SalaryGraphView(viewModel: viewModel)
                        .frame(maxWidth: .infinity)
                    VStack{
                        HStack {
                            Image(systemName: "dollarsign.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Text("累計給与金額")
                                .font(.system(size: 36))
                        }
                        Text("¥\(Int(viewModel.totalSalary))")  // 合計金額を表示
                            .font(.system(size: 50))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(radius: 1)
                    )
                }
                .padding()
                Spacer()
            }
        }
        .background(Color("backgroundColor"))
        .onAppear {
            viewModel.fetchSalaryHistorys()
            authManager.fetchUserData { success, error in
                if success {
                    
                }
            }
        }
        .foregroundStyle(Color("fontGray"))
    }
}


#Preview {
    GraphView()
}
