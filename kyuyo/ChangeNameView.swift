//
//  RankingView.swift
//  sukimaKanji
//
//  Created by Apple on 2024/06/23.
//

import SwiftUI
import Firebase

struct ChangeNameView: View {
    @Binding var isPresented: Bool
    @State private var showAlert = false
    @State private var userName = ""
    @ObservedObject var authManager = AuthManager()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack{
            HStack{
                Spacer()
                Text("プロフィールを編集する")
                    .font(.system(size:22))
                Spacer()
            }
            .padding(.top)
            
            VStack(alignment: .center){
                HStack {
                    Text("")
                        .frame(width:10,height:20)
                        .background(Color("fontGray"))
                    Text("名前を変更する")
                        .font(.system(size: 20))
                    Spacer()
                }
                TextField("名前", text: $userName)
                    .onChange(of: userName) { newValue in
                        if newValue.count > 10 {
                            userName = String(newValue.prefix(10))
                        }
                    }
                    .padding(5)
                    .padding(.leading)
                    .background(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                Text("\(userName.count) / 10")
                    .font(.system(size: 20))
                    .font(.caption)
                Button(action: {
                    authManager.saveUserToDatabase(userName: userName) { success in
                    }
                    showAlert = true
                }, label: {
                    Text("変更する")
                        .fontWeight(.semibold)
                        .frame(width: 130, height:40)
                        .foregroundColor(Color.white)
                        .background(Color.gray)
                        .cornerRadius(24)
                })
                .shadow(radius: 3)
                .padding(.top,5)
                .padding(.bottom,10)
                .opacity(userName.isEmpty ? 0.5 : 1.0)
                .disabled(userName.isEmpty)
            }
        }
        .foregroundColor(Color("fontGray"))
        .padding()
        .background(Color("backgroundColor"))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 5)
        )
        .padding(20)
        .cornerRadius(20)
        .shadow(radius: 10)
        .overlay(
            Button(action: {
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
                .offset(x: 10, y: -15),
            alignment: .topTrailing
        )
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(""),
                message: Text("プロフィールが編集されました"),
                dismissButton: .default(Text("OK")) {
                }
            )
        }
    }

    func saveName() {
        let ref = Database.database().reference()
        ref.child("users").child(authManager.currentUserId!).child("userName").setValue(userName) { error, _ in
            if let error = error {
                print("Failed to save name: \(error.localizedDescription)")
            } else {
                print("Successfully saved name")
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
