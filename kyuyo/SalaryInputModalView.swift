//
//  SalaryInputModalView.swift
//  kyuyo
//
//  Created by Apple on 2024/08/23.
//

import SwiftUI
import Firebase

struct SalaryInputModalView: View {
    @ObservedObject var authManager = AuthManager()
    @Binding var isPresented: Bool
    @State var toggle = false
    @State private var text: String = ""
    @Binding var showAlert: Bool
    @State private var totalCount: Int = 1
    @State private var selectedSample: String = "選択してください"
    private let habitSamples = ["サンプル入力","本を1冊読む", "ジョギングを3回する", "ジムに2回行く", "自炊を4回する"]
    @State private var title: String = ""
    @State private var isTitleValid: Bool = true
    @State private var selectedDate: Date = Date()
    @State private var selectedPayday: String = "25日"
    private let paydayOptions = ["15日", "20日", "25日", "月末", "その他の日付"]
    @State private var customDate: Date = Date()

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    if toggle {
                        authManager.updateUserFlag(userId: authManager.currentUserId!, userFlag: 1) { success in }
                    }
                    isPresented = false
                }
            VStack(spacing: -25) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(" ")
                            .frame(width: 5, height: 20)
                            .background(Color("buttonColor"))
                        Text("月のお給料を入力")
                        Spacer()
                    }
                    TextField("1000000", text: $title)
                        .multilineTextAlignment(.trailing)
                        .border(Color.clear, width: 0)
                        .font(.system(size: 18))
                        .cornerRadius(8)
                        .onChange(of: title) { newValue in
                            isTitleValid = !newValue.isEmpty
                        }
                    Divider()
                    
                    HStack {
                        Text(" ")
                            .frame(width: 5, height: 20)
                            .background(Color("buttonColor"))
                        Text("給料日を選択")
                        if selectedPayday == "その他の日付" {
                            DatePicker("", selection: $customDate, displayedComponents: .date)
                                .environment(\.locale, Locale(identifier: "ja_JP"))
                                .border(Color.clear, width: 0)
                                .cornerRadius(8)
                        } else {
                            Spacer()
                            Picker("給料日を選択", selection: $selectedPayday) {
                                ForEach(paydayOptions, id: \.self) { option in
                                    Text(option).tag(option)
                                }
                            }
                            .accentColor(Color("fontGray"))
                            .padding(5)
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                    .padding(.top)
                    Divider()

                    if isTitleValid {
                        Text("習慣が入力されていません")
                            .foregroundColor(.red)
                            .opacity(0)
                    } else {
                        Text("習慣が入力されていません")
                            .foregroundColor(.red)
                    }
                    HStack {
                        Spacer()
                        Button(action: saveSalarySettings) {
                            Text("送信")
                                .fontWeight(.semibold)
                                .frame(width: 130, height: 40)
                                .foregroundColor(Color.white)
                                .background(Color.gray)
                                .cornerRadius(24)
                        }
                        .shadow(radius: 3)
                        Spacer()
                    }
                }
            }
            .padding()
            .frame(width: isSmallDevice() ? 290 : 320)
            .foregroundColor(Color("fontGray"))
            .padding()
            .background(Color("backgroundColor"))
            .cornerRadius(20)
            .shadow(radius: 10)
            .overlay(
                Button(action: {
                    if toggle {
                        authManager.updateUserFlag(userId: authManager.currentUserId!, userFlag: 1) { success in }
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
                .offset(x: 35, y: -35),
                alignment: .topTrailing
            )
            .padding(25)
        }
    }

    func saveSalarySettings() {
        guard let userId = authManager.currentUserId else { return }
        let userRef = Database.database().reference().child("salarySettings").child(userId)
        
        // 給料日と月給を保存
        let salaryDay = selectedPayday == "その他の日付" ? Calendar.current.component(.day, from: customDate) : Int(selectedPayday.replacingOccurrences(of: "日", with: "")) ?? 1
        let monthlySalary = Double(title) ?? 0
        
        let salaryData: [String: Any] = [
            "salaryDay": salaryDay,
            "monthlySalary": monthlySalary,
            "lastSalarySavedDate": dateFormatter.string(from: Date())
        ]
        
        userRef.setValue(salaryData) { error, _ in
            if let error = error {
                print("Error updating salary settings: \(error.localizedDescription)")
            } else {
                print("Salary settings updated successfully.")
            }
        }
        
        isPresented = false
    }
}

#Preview {
    SalaryInputModalView(isPresented: .constant(true), showAlert: .constant(false))
}
