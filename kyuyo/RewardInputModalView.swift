//
//  RewardInputModalView.swift
//  kyuyo
//
//  Created by Apple on 2024/08/30.
//

import SwiftUI

struct RewardInputModalView: View {
    @Binding var isPresented: Bool
    @State private var rewardTitle: String = ""
    @State private var rewardAmount: String = ""
    @State private var selectedIcon: String = "ご褒美１" // 初期値を「ご褒美１」に設定
    var onSave: (String, Double, String) -> Void // アイコンも含める

    let icons = ["ご褒美１", "ご褒美２", "ご褒美３", "ご褒美４", "ご褒美５", "ご褒美６"]

    var body: some View {
        VStack {
            HStack {
                Text(" ")
                    .frame(width: 5, height: 20)
                    .background(Color("buttonColor"))
                Text("タイトル")
                Spacer()
            }
            TextField("タイトル", text: $rewardTitle)

            HStack {
                Text(" ")
                    .frame(width: 5, height: 20)
                    .background(Color("buttonColor"))
                Text("金額")
                Spacer()
            }
            TextField("金額", text: $rewardAmount)
                .keyboardType(.numberPad)
            
            HStack {
                Text(" ")
                    .frame(width: 5, height: 20)
                    .background(Color("buttonColor"))
                Text("アイコンを選択")
                Spacer()
            }
            VStack(spacing: 5) {
                ForEach(0..<icons.count/6, id: \.self) { row in
                    HStack(spacing: 5) {
                        ForEach(0..<6, id: \.self) { column in
                            let iconIndex = row * 3 + column
                            if iconIndex < icons.count {
                                let icon = icons[iconIndex]
                                Image(icon)
                                    .resizable()
                                    .frame(width: 50, height: 50) // 選択されているアイコンは大きくする
                                    .opacity(selectedIcon == icon ? 1.0 : 0.5) // 選択されていないアイコンは透明度を下げる
                                    .padding(2)
                                    .onTapGesture {
                                        selectedIcon = icon
                                    }
                                    .overlay(
                                        Circle()
                                            .stroke(selectedIcon == icon ? Color.white : Color.clear, lineWidth: 4)
                                    )
                            }
                        }
                    }
                }
            }
            .padding(.vertical)

            Button("保存") {
                if let amount = Double(rewardAmount) {
                    onSave(rewardTitle, amount, selectedIcon)
                    isPresented = false
                }
            }
        }
        .padding()
        .frame(maxHeight: .infinity)
        .foregroundColor(Color("fontGray"))
        .background(Color("backgroundColor"))
    }
}

#Preview {
    RewardInputModalView(
        isPresented: .constant(true),
        onSave: { title, amount, icon in
            // 保存処理のプレビュー用
        }
    )
}
