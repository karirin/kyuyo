//
//  RewardTurialModalView.swift
//  kyuyo
//
//  Created by Apple on 2024/09/01.
//

import SwiftUI

struct RewardTutorialModalView: View {
    @ObservedObject var authManager = AuthManager()
    @Binding var isPresented: Bool
    @State var toggle = false
    @State private var text: String = ""
    @Binding var showAlert: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    if toggle == true {
                        authManager.updateUserFlag(userId: authManager.currentUserId!, userFlag: 1) { success in
                        }
                    }
                    isPresented = false
                }
            VStack(spacing: -25) {
                VStack(alignment: .center){
                    Image("チュートリアル３")
                        .resizable()
                        .frame(height: 130)
                        .padding(-15)
                    Text("ご褒美画面になります\n\nこの画面では「欲しいもの」「したいこと」の金額を設定して\n累計の収入額からどれくらいで\n達成できるかを確認することができます")
                        .font(.system(size: isSmallDevice() ? 15 : 15))
                        .multilineTextAlignment(.center)
                        .padding(.vertical)
                }
            }
            .frame(width: isSmallDevice() ? 290: 300)
            .foregroundColor(Color("fontGray"))
            .padding()
        .background(Color("backgroundColor"))
        .cornerRadius(20)
        .shadow(radius: 10)
        .overlay(
            // 「×」ボタンを右上に配置
            Button(action: {
                if toggle == true {
                    authManager.updateUserFlag(userId: authManager.currentUserId!, userFlag: 1) { success in
                    }
                }
                isPresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
                    .background(.white)
                    .cornerRadius(30)
                    .padding()
            }
                .offset(x: 35, y: -35), // この値を調整してボタンを正しい位置に移動させます
            alignment: .topTrailing // 枠の右上を基準に位置を調整します
        )
        }
    }
}


#Preview {
    RewardTutorialModalView(isPresented: .constant(true), showAlert: .constant(false))
}
