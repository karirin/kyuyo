//
//  ColorPickerView.swift
//  kyuyo
//
//  Created by Apple on 2024/08/25.
//

import SwiftUI

struct ColorPickerSeetView: View {
    @Binding var selectedColor: Color

    var body: some View {
        ColorPickerView(selectedColor: $selectedColor)
    }
}

struct ColorPickerView: View {
    let colors: [[Color]] = [
        [.black, .darkGray, .navy, .darkPurple, .gray],
        [.brown, .lightBrown, .beige, .lightBlue, .pink],
        [.red, .orange, .lightPink, .darkPink, .darkOrange],
        [.blue, .cyan, .darkRed, .darkBlue, .black]
    ]
    
    @Binding var selectedColor: Color
    @ObservedObject var authManager = AuthManager()

    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            Spacer()
            HStack {
                Text(" ")
                    .frame(width:5,height: 20)
                    .background(Color("buttonColor"))
                Text("色を変更する")
                Spacer()
            }
            .padding(.leading)
            .padding(.leading,10)
            ForEach(0..<colors.count, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(0..<colors[row].count, id: \.self) { column in
                        Circle()
                            .fill(colors[row][column])
                            .frame(width: 50, height: 50)
                            .padding(3)
                            .onTapGesture {
                                selectedColor = colors[row][column]
                                print("Selected Color: \(selectedColor)")
                                
                                if let userId = authManager.user?.uid {
                                    authManager.updateUserColor(userId: userId, color: selectedColor) { success in
                                        if success {
                                            print("Color saved successfully")
                                        } else {
                                            print("Failed to save color")
                                        }
                                    }
                                }
                            }
                            .overlay(
                                Circle()
                                    .stroke(selectedColor == colors[row][column] ? Color.white : Color.clear, lineWidth: 4)
                            )
                    }
                }
            }
        }
        .background(Color("backgroundColor"))
        .padding()
    }
}



struct ColorPickerSeetView_Previews: PreviewProvider {
    @State static var selectedColor: Color = .black

    static var previews: some View {
//        ColorPickerSeetView(selectedColor: $selectedColor)
        SalaryView()
    }
}
