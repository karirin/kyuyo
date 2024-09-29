//
//  TutorialModalView.swift
//  kyuyo
//
//  Created by Apple on 2024/08/31.
//

import SwiftUI

struct TutorialModalView: View {
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
                    Image("チュートリアル")
                        .resizable()
                        .frame(height: 130)
                        .padding(-15)
                    Text("インストールありがとうございます！\n\nこのアプリは給料日まで自分が\nどれくらい稼いでいるかを確認することができて\n仕事のモチベーションを上げることができるサービスです")
                        .font(.system(size: isSmallDevice() ? 16 : 17))
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
        .padding(25)
                }
            }
        }


#Preview {
    TutorialModalView(isPresented: .constant(true), showAlert: .constant(false))
}


