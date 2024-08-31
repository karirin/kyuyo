//
//  TopView.swift
//  kyuyo
//
//  Created by Apple on 2024/08/24.
//

import SwiftUI

struct TopView: View {
    static let samplePaymentDates: [Date] = [Date()]
    @State private var isPresentingAvatarList: Bool = false
    @State private var isPresentingQuizList: Bool = false
    @State private var flag: Bool = false
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State var isAlert: Bool = false
    
    var body: some View {
        ZStack{
            VStack {
                TabView {
                    HStack{
                        SalaryView()
                        }
                        .tabItem {
                            Image(systemName: "house")
                                .padding()
                            Text("ホーム")
                                .padding()
                        }
                    
                    ZStack {
                        RewardView()
                    }
                    .tabItem {
                        Image(systemName: "gift")
                            .frame(width:1,height:1)
                        Text("ご褒美")
                    }
                    
                    ZStack {
                        GraphView()
                    }
                    .tabItem {
                        Image(systemName: "chart.xyaxis.line")
                            .frame(width:1,height:1)
                        Text("グラフ")
                    }
                    ContactTabView()
                            .tabItem {
                                Image(systemName: "headphones")
                                Text("問い合わせ")
                            }
                    ZStack {
                        SettingView()
                    }
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("設定")
                    }
                }
            }
        }
    }
}

#Preview {
    TopView()
}

