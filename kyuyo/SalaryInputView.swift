//
//  ContentView.swift
//  kyuyo
//
//  Created by Apple on 2024/08/19.
//

import SwiftUI
import Firebase

struct SalaryInputView: View {
    @State private var salaryDay: Int = 22
    @State private var monthlySalary: Double = 300000

    var ref: DatabaseReference = Database.database().reference()

    var body: some View {
        Form {
            Section(header: Text("給料日")) {
                Stepper(value: $salaryDay, in: 1...31) {
                    Text("\(salaryDay)日")
                }
            }
            Section(header: Text("月額給料")) {
                TextField("月額給料", value: $monthlySalary, format: .number)
                    .keyboardType(.decimalPad)
            }
            Button(action: saveData) {
                Text("保存")
            }
        }
        .navigationTitle("給料設定")
    }

    func saveData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }
        let data: [String: Any] = [
            "salaryDay": salaryDay,
            "monthlySalary": monthlySalary
        ]
        ref.child("salarySettings").child(userId).setValue(data) { (error, ref) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("Data saved successfully!")
            }
        }
    }
}

#Preview {
    SalaryInputView()
}
