//
//  TestView.swift
//  kyuyo
//
//  Created by Apple on 2024/08/30.
//

import SwiftUI

    struct ProgressViewWithText: View {
        var progress: CGFloat
        var text: String
        var totalWidth: CGFloat = 300
        var barHeight: CGFloat = 40
        
        var body: some View {
            ZStack(alignment: .leading) {
                // 背景のグレーのバー
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: totalWidth, height: barHeight)
                
                // 進捗バー
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: totalWidth * progress, height: barHeight)
                
                // 中央のテキスト
                Text(text)
                    .foregroundColor(.white)
                    .bold()
                    .padding(.leading, 10) // 左側のマージン
            }
            .cornerRadius(barHeight / 2) // バーの角を丸くする
        }
    }

struct TestView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressViewWithText(progress: 0.33, text: "1000/3000 ml")
            ProgressViewWithText(progress: 0.95, text: "9500/10000 steps")
            ProgressViewWithText(progress: 0.92, text: "55m 22s/1h")
            // 他の項目も同様に追加可能
        }
        .padding()
    }
}


#Preview {
    TestView()
}
