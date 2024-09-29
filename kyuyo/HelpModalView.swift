//
//  HelpModalView.swift
//  kyuyo
//
//  Created by Apple on 2024/08/23.
//

import SwiftUI
import StoreKit

struct HelpModalView: View {
    @ObservedObject var authManager = AuthManager()
    @Binding var isPresented: Bool
    @State var toggle = false
    @State private var text: String = ""
//    @State private var showAlert = false
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
                    Text("改善してほしい点や\n追加を希望する機能などありましたら\nお気軽にご連絡ください\n可能な限りご要望にお応えいたします")
                        .font(.system(size: isSmallDevice() ? 17 : 18))
                        .multilineTextAlignment(.center)
                        .padding(.vertical)
                        TextField(
                            "例）メッセージが送信されない",
                            text: $text,
                            axis: .vertical
                        )
                        .padding()
                        .background(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    Button(action: {
                        if toggle == true {
                            authManager.updateUserFlag(userId: authManager.currentUserId!, userFlag: 1) { success in
                            }
                        }
                        authManager.updateContact(userId: authManager.currentUserId!, newContact: text){ success in
                            if success {
                                self.showAlert = true
                                print("Heart added successfully.")
                            } else {
                                print("Failed to add heart.")
                            }
                        }
                    }, label: {
                        Text("送信")
                            .fontWeight(.semibold)
                            .frame(width: 130, height:40)
                            .foregroundColor(Color.white)
                            .background(Color.gray)
                            .cornerRadius(24)
                    })
                    .opacity(text.isEmpty ? 0.5 : 1)
                    .disabled(text.isEmpty)
                    .shadow(radius: 3)
                    .padding(.top,10)

                    HStack{
                        Spacer()
                        Toggle("今後は表示しない", isOn: $toggle)
                            .frame(width:200)
                            .toggleStyle(SwitchToggleStyle())
                            .padding(.horizontal)
                            .padding(.top)
                    }
                }
            }
            .alert(isPresented: $showAlert) { // アラートを表示する
                Alert(
                    title: Text("送信されました"),
                    message: Text("お問い合わせありがとうございました。"),
                    dismissButton: .default(Text("OK")) {
                        isPresented = false
                    }
                )
            }
            .frame(width: isSmallDevice() ? 290: 320)
            .foregroundColor(Color("fontGray"))
            .padding(10)
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
//        .alert(isPresented: $showAlert) { // アラートを表示する
//            Alert(
//                title: Text("送信されました"),
//                message: Text("お問い合わせありがとうございました。"),
//                dismissButton: .default(Text("OK")) {
//                    isPresented = false
//                }
//            )
//        }
//            }
                }
            //            .padding(50)
          
        }
//    }
    
//    func isSmallDevice() -> Bool {
//        return UIScreen.main.bounds.width < 390
//    }


#Preview {
    HelpModalView(isPresented: .constant(true), showAlert: .constant(false))
}

