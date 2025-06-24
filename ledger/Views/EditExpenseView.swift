//
//  EditExpenseView.swift
//  ledger
//
//  Created by Jinwoo Hwangbo on 6/22/25.
//

import SwiftUI
import SwiftData

struct EditExpenseView: View {
    @AppStorage("appAppearance") private var appearanceSetting: String = AppAppearance.light.rawValue

    var appearance: AppAppearance {
        AppAppearance(rawValue: appearanceSetting) ?? .light
    }
    
    @Bindable var expense: Expense

    @State private var editingCost: Int
    @State private var editingName: String
    @State private var editingTag: String
    @State private var editingDate: Date
    @State private var editingSign: String = "-"
    @State private var tags = TagManager.tags
    @FocusState private var isNameFocused: Bool
    @Environment(\.dismiss) private var dismiss

    init(expense: Expense) {
        self._expense = Bindable(wrappedValue: expense)
        _editingSign = State(initialValue: expense.cost < 0 ? "+" : "-")
        _editingCost = State(initialValue: abs(expense.cost))
        _editingName = State(initialValue: expense.name)
        _editingDate = State(initialValue: try! Date(string: expense.date))
        _editingTag = State(initialValue: expense.tag)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                TextField("금액", value: $editingCost, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 8)
                    .frame(height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .cornerRadius(8)

                Button(action: {
                    editingSign = editingSign == "+" ? "-" : "+"
                }) {
                    Text(editingSign)
                        .font(.title)
                        .frame(width: 48, height: 48)
                        .background(editingSign == "+" ? Color.blue : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }

            HStack(spacing: 8) {
                TextField("설명", text: $editingName)
                    .focused($isNameFocused)
                    .submitLabel(.done)
                    .padding(.horizontal, 8)
                    .frame(height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .cornerRadius(8)

                Picker("태그", selection: $editingTag) {
                    ForEach(tags, id: \.self) { tag in
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
            
            DatePicker("날짜 선택", selection: $editingDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
                .frame(height: 48)

            .frame(height: 48)
            .padding(.horizontal, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)

            HStack {
                Button("삭제") {
                    modelContext.delete(expense)
                    dismiss()
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(8)
                
                Button("수정") {
                    isNameFocused = false
                    if editingSign == "+" {
                        expense.cost = -editingCost
                    } else {
                        expense.cost = editingCost
                    }
                    expense.name = editingName
                    expense.tag = editingTag
                    expense.date = String(format: "%.0f", editingDate.timeIntervalSince1970 * 1000)
                    dismiss()
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
    }
    @Environment(\.modelContext) private var modelContext
}
