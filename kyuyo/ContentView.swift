//
//  ContentView.swift
//  kyuyo
//
//  Created by Apple on 2024/08/20.
//

import SwiftUI

struct CoinAnimationView: View {
    @State private var moveCoin = false
    @State private var fadeOutCoin = false

    var body: some View {
        ZStack {
            // 給料表示部分
            VStack {
                Text("本日までのお給料")
                    .font(.system(size: 40))
                Text("¥270,000")
                    .font(.system(size: 54))
            }
            .padding()
            
            // 円形の進捗バー
            Circle()
                .stroke(lineWidth: 25)
                .opacity(0.3)
                .padding(10)
                .padding(.leading,5)
            
            Circle()
                .trim(from: 0.0, to: 0.75) // 例として75%の進捗
                .stroke(style: StrokeStyle(lineWidth: 25, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .padding(10)
                .padding(.leading,5)
                .foregroundColor(Color(red: 1, green: 0.4, blue: 0.4, opacity: 1))
            
            // コインのアニメーション
            Image("coin")
                .resizable()
                .frame(width: 100, height: 100)
                .offset(x: moveCoin ? 160 : 100, y: moveCoin ? 100 : 100)
                .opacity(fadeOutCoin ? 0 : 1) // 透明度を制御
                .animation(.easeInOut(duration: 2), value: moveCoin) // 移動アニメーション
                .animation(.easeInOut(duration: 2), value: fadeOutCoin)
            
        }
        .onAppear {
            moveCoin = true
            fadeOutCoin = true // アニメーションが完了する頃に透明になる
        }
    }
}

struct ContentView: View {
    var body: some View {
        CoinAnimationView()
    }
}

#Preview {
    ContentView()
}

