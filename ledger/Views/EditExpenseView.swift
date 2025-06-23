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
    @State private var editingDate: String
    @State private var showDatePicker = false
    @FocusState private var isNameFocused: Bool
    @Environment(\.dismiss) private var dismiss

    init(expense: Expense) {
        self._expense = Bindable(wrappedValue: expense)
        _editingCost = State(initialValue: expense.cost)
        _editingName = State(initialValue: expense.name)
        _editingDate = State(initialValue: expense.date)
        _editingTag = State(initialValue: expense.tag)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(Date(timeIntervalSince1970: (Double(editingDate) ?? 0) / 1000).formatted(.dateTime.year().month().day().hour().minute()))
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Spacer()

                Button("날짜 수정") {
                    showDatePicker.toggle()
                }
                .font(.subheadline)
            }

            HStack(spacing: 8) {
                TextField("금액", value: $editingCost, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .frame(height: 48)
                    .padding(.horizontal, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                Button(action: {
                    editingCost = -editingCost
                }) {
                    Text(editingCost >= 0 ? "+" : "-")
                        .font(.title)
                        .frame(width: 48, height: 48)
                        .background(editingCost >= 0 ? Color(red: 0.0, green: 0.6, blue: 0.5) : Color(red: 0.85, green: 0.3, blue: 0.3))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }

            HStack(spacing: 8) {
                TextField("설명", text: $editingName)
                    .focused($isNameFocused)
                    .submitLabel(.done)
                    .frame(height: 48)
                    .padding(.horizontal, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                Picker("태그", selection: $editingTag) {
                    Text("태그없음").tag("태그없음" as String?)
                    Text("내 카드").tag("내 카드" as String?)
                    Text("법인 카드").tag("법인 카드" as String?)
                    Text("아빠 카드").tag("아빠 카드" as String?)
                }
                .pickerStyle(MenuPickerStyle())
                .frame(height: 48)
                .padding(.horizontal, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }

            Button("입력") {
                isNameFocused = false
                expense.cost = editingCost
                expense.name = editingName
                expense.tag = editingTag
                expense.date = editingDate
                dismiss()
            }
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.appPrimary(for: appearance))
            .cornerRadius(8)

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showDatePicker) {
            VStack {
                DatePicker(
                    "날짜 선택",
                    selection: Binding<Date>(
                        get: {
                            if let timestamp = Double(editingDate) {
                                return Date(timeIntervalSince1970: timestamp / 1000)
                            } else {
                                return Date()
                            }
                        },
                        set: { newDate in
                            editingDate = String(Int(newDate.timeIntervalSince1970 * 1000))
                        }
                    ),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .padding()

                Button("확인") {
                    showDatePicker = false
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.appPrimary(for: appearance))
                .cornerRadius(8)
                .padding()
            }
            .presentationDetents([.large])
        }
    }
}
