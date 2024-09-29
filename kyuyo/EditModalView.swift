import SwiftUI
import Firebase

struct EditModalView: View {
    @ObservedObject var authManager = AuthManager()
    @Binding var isPresented: Bool
    @Binding var showAlert: Bool
    @Binding var selectedColor: Color
    @Binding var selectedUnit: TimeUnit  // TimeUnitのバインディングを追加
    @State private var salaryDay: Int = 25
    @State private var monthlySalary: Int = 0
    private let paydayOptions = [15, 20, 25, 31, -1]
    @State private var customDate: Date = Date()
    @State private var isCustomDateVisible: Bool = false
    @Binding var showDetails: Bool
    var ref: DatabaseReference = Database.database().reference()

    var body: some View {
//        ZStack {
//            Color.black.opacity(0.4)
//                .edgesIgnoringSafeArea(.all)
//                .onTapGesture {
//                    isPresented = false
//                }
            VStack(spacing: 20) {

Spacer()
                if showDetails {
                    salaryInputSection
                    salaryDayPickerSection
                    timeUnitPickerSection
                    colorPickerSection
                    Button(action: {
                        withAnimation {
                            showDetails.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                            Text(showDetails ? "戻る" : "より詳細な編集")
                                .fontWeight(.semibold)
                        }
                    }
                } else {
                    salaryInputSection
                    salaryDayPickerSection
                    Button(action: {
                        withAnimation {
                            showDetails.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                            Text(showDetails ? "戻る" : "より詳細な編集")
                                .fontWeight(.semibold)
                        }
                    }
                }
                saveButton
            }
            .frame(maxWidth: .infinity,maxHeight: .infinity)
            .padding()
//            .frame(width: isSmallDevice() ? 290 : 320)
            .foregroundColor(Color("fontGray"))
//            .padding()
            .background(Color("backgroundColor"))
//            .cornerRadius(20)
//            .shadow(radius: 10)
//            .overlay(
//                Button(action: {
//                    isPresented = false
//                }) {
//                    Image(systemName: "xmark.circle.fill")
//                        .resizable()
//                        .frame(width: 50, height: 50)
//                        .foregroundColor(.gray)
//                        .background(.white)
//                        .cornerRadius(30)
//                        .padding()
//                }
//                .offset(x: 35, y: -35),
//                alignment: .topTrailing
//            )
//            .padding(25)
            .onAppear {
                loadSalaryInfo()
            }
        }
//    }

    private var salaryInputSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(" ")
                    .frame(width: 5, height: 20)
                    .background(Color("buttonColor"))
                Text("月のお給料を入力")
                Spacer()
            }
            TextField("1000000", value: $monthlySalary, format: .number)
                .multilineTextAlignment(.trailing)
                .border(Color.clear, width: 0)
                .font(.system(size: 18))
                .cornerRadius(8)
            Divider()
        }
    }

    private var salaryDayPickerSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(" ")
                    .frame(width: 5, height: 20)
                    .background(Color("buttonColor"))
                Text("給料日を選択")
                Spacer()
                if isCustomDateVisible {
                    DatePicker("", selection: $customDate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                        .border(Color.clear, width: 0)
                        .cornerRadius(8)
                } else {
                    Picker("給料日を選択", selection: $salaryDay) {
                        ForEach(paydayOptions, id: \.self) { option in
                            if option == 31 {
                                Text("月末").tag(option)
                            } else if option == -1 {
                                Text("その他の日付").tag(option)
                            } else {
                                Text("\(option)日").tag(option)
                            }
                        }
                    }
                    .accentColor(Color("fontGray"))
                    .padding(5)
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: salaryDay) { value in
                        isCustomDateVisible = (value == -1)
                    }
                }
            }
            Divider()
        }
    }

    // TimeUnit Pickerセクションを追加
    private var timeUnitPickerSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(" ")
                    .frame(width: 5, height: 20)
                    .background(Color("buttonColor"))
                Text("時間単位を選択")
                Spacer()
            }
            Picker("時間単位を選択", selection: $selectedUnit) {
                ForEach(TimeUnit.allCases) { unit in
                    Text(unit.rawValue).tag(unit)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private var colorPickerSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(" ")
                    .frame(width: 5, height: 20)
                    .background(Color("buttonColor"))
                Text("色を選択")
                Spacer()
            }
            ColorPicker("選択した色", selection: $selectedColor)
                .padding()
        }
    }

    private var saveButton: some View {
        HStack {
            Spacer()
            Button(action: {
                var finalSalaryDay = salaryDay
                if salaryDay == -1 {
                    let calendar = Calendar.current
                    finalSalaryDay = calendar.component(.day, from: customDate)
                }
                authManager.updateSalaryInfo(userId: authManager.currentUserId!, salaryDay: finalSalaryDay, monthlySalary: Double(monthlySalary) ?? 0) { success in
                    if success {
                        showAlert = true
                        isPresented = false
                    } else {
                        print("Failed to update salary info.")
                    }
                }
                if let userId = authManager.user?.uid {
                    authManager.updateUserColor(userId: userId, color: selectedColor) { success in
                        if success {
                            print("Color saved successfully")
                        } else {
                            print("Failed to save color")
                        }
                    }
                }
            }, label: {
                Text("保存")
                .frame(maxWidth:.infinity)
            })
            .padding()
            .background(Color("buttonColor"))
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.top)
            .padding(.bottom)
            .shadow(radius: 1)
            Spacer()
        }
    }

    func loadSalaryInfo() {
        guard let userId = authManager.currentUserId else { return }
        ref.child("salarySettings").child(userId).observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                if let salaryDay = value["salaryDay"] as? Int,
                   let monthlySalary = value["monthlySalary"] as? Double {
                    self.salaryDay = salaryDay
                    self.monthlySalary = Int(monthlySalary)  // Double を整数形式で String に変換
                }
            }
        }
    }
}

struct EditModalView_Previews: PreviewProvider {
    static var previews: some View {
        EditModalView(
            isPresented: .constant(true),
            showAlert: .constant(false),
            selectedColor: .constant(.blue), selectedUnit: .constant(.second), showDetails: .constant(false)
        )
    }
}
