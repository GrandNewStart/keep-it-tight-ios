//
//  InputView.swift
//  ledger
//
//  Created by emblock on 6/24/25.
//

import SwiftUI
import SwiftData

struct InputView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var amountText: String = ""
    @State private var isIncome: Bool = false
    @State private var descText: String = ""
    @State private var selectedTag: String = "태그없음"
    @State private var selectedDate: Date = Date()
    @State private var tags = TagManager.tags

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                TextField("금액", text: $amountText)
                    .keyboardType(.numberPad)
                    .onChange(of: amountText) {
                        amountText = String(amountText.prefix(12))
                    }
                    .padding(.horizontal, 8)
                    .frame(height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .cornerRadius(8)

                Button(action: {
                    isIncome.toggle()
                }) {
                    Text(isIncome ? "+" : "-")
                        .frame(width: 48, height: 48)
                        .background(isIncome ? Color.blue : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }

            HStack(spacing: 8) {
                TextField("설명", text: $descText)
                    .onChange(of: descText) {
                        descText = String(descText.prefix(20))
                    }
                    .padding(.horizontal, 8)
                    .frame(height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .cornerRadius(8)

                Picker("", selection: $selectedTag) {
                    ForEach(TagManager.tags, id: \.self) { tag in
                        Text(tag).tag(tag)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal, 8)
                .frame(height: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .cornerRadius(8)
            }

            DatePicker("날짜 선택", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
                .frame(height: 48)

            Button(action: {
                guard let amount = Int(amountText), !descText.isEmpty else { return }

                let newExpense = Expense(
                    cost: isIncome ? amount : -amount,
                    name: descText,
                    tag: selectedTag,
                    date: String(format: "%.0f", selectedDate.timeIntervalSince1970 * 1000)
                )

                modelContext.insert(newExpense)

                amountText = ""
                descText = ""
                selectedTag = "태그없음"
                selectedDate = Date()
                isIncome = false

                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                dismiss()
            }) {
                Text("입력")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color.blue)
                    .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("지출 입력")
    }
}
