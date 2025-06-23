//
//  HomeView.swift
//  ledger
//
//  Created by Jinwoo Hwangbo on 6/22/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @AppStorage("appAppearance") private var appearanceSetting: String = AppAppearance.light.rawValue
    @FocusState private var isDescFocused: Bool

    var appearance: AppAppearance {
        AppAppearance(rawValue: appearanceSetting) ?? .light
    }
    
    @Query(sort: \Expense.date, order: .reverse) var expenses: [Expense]
    @State private var amountText: String = ""
    @State private var isIncome: Bool = false
    @State private var descText: String = ""
    @State private var tags = TagManager.tags
    @State private var selectedTag: String = "태그없음"
    @Environment(\.modelContext) private var modelContext

    @State private var selectedExpense: Expense?
    @State private var isEditing: Bool = false
    @State private var showSettings: Bool = false

    var groupedExpenses: [(key: String, value: [Expense])] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"

        let groups = Dictionary(grouping: expenses) { expense -> String in
            if let timeInterval = Double(expense.date) {
                let date = Date(timeIntervalSince1970: timeInterval / 1000)
                return dateFormatter.string(from: date)
            } else {
                return "Unknown Date"
            }
        }

        return groups.sorted { $0.key > $1.key } // Sort by date descending
    }

    var body: some View {
        VStack(alignment: .leading) {
            // Top bar
            HStack {
                Text("정신차려")
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()

                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .tint(Color.appPrimary(for: appearance))
                        .imageScale(.large)
                        .padding(.trailing, 8)
                }
            }
            .padding([.top, .horizontal], 8)

            // Header row
            ZStack {
                Color.appPrimary(for: appearance)
                HStack {
                    Text("금액")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("설명")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("태그")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
            }
            .frame(height: 48)

            // Expense list
            List {
                ForEach(groupedExpenses, id: \.key) { date, items in
                    Section(header: Text(date).font(.headline)) {
                        ForEach(items) { expense in
                            Button {
                                selectedExpense = expense
                                isEditing = true
                            } label: {
                                HStack {
                                    Text("\(expense.cost)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(expense.name)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(expense.tag)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.vertical, 4)
                                .foregroundColor(.primary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .listStyle(.plain)

            Spacer()

            // Input Section
            HStack(spacing: 8) {
                TextField("금액", text: $amountText)
                    .frame(height: 48) // Apply height first
                    .padding(.horizontal, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .keyboardType(.numberPad)
                    .onChange(of: amountText) {
                        // Allow only digits and max 12 characters
                        amountText = String(amountText.prefix(12).filter { $0.isNumber })
                    }

                Button(action: {
                    isIncome.toggle()
                }) {
                    Text(isIncome ? "+" : "-")
                        .font(.title)
                        .frame(width: 48, height: 48)
                        .background(isIncome ? Color(red: 0.0, green: 0.6, blue: 0.5) : Color(red: 0.85, green: 0.3, blue: 0.3))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 8)
            HStack(spacing: 8) {
                TextField("설명", text: $descText)
                    .focused($isDescFocused)
                    .submitLabel(.done)
                    .frame(height: 48)
                    .padding(.horizontal, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .onChange(of: descText) {
                        descText = String(descText.prefix(20))
                    }

                Picker("태그", selection: $selectedTag) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag).tag(tag as String?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .foregroundColor(.black)
                .frame(height: 48)
                .padding(.horizontal, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
            }
            .padding(.horizontal, 8)
            Button(action: {
                guard let amount = Int(amountText), !descText.isEmpty else { return }
                let newExpense = Expense(
                    cost: isIncome ? -amount : amount,
                    name: descText,
                    tag: selectedTag,
                    date: String(format: "%.0f", Date.now.timeIntervalSince1970 * 1000)
                )
                modelContext.insert(newExpense)
                amountText = ""
                descText = ""
                selectedTag = "태그없음"
                isIncome = false
                isDescFocused = false
            }) {
                Text("입력")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appPrimary(for: appearance))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 8)
            .padding(.bottom)
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $isEditing) {
            if let expense = selectedExpense {
                EditExpenseView(expense: expense)
                    .environment(\.modelContext, modelContext)
                    .presentationDetents([.height(260), .medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Expense.self, configurations: config)

    let context = container.mainContext
    context.insert(Expense(cost: 12000, name: "커피", tag: "내 카드", date: String(Date.now.timeIntervalSince1970)))
    context.insert(Expense(cost: 55000, name: "식사", tag: "법인 카드", date: String(Date.now.timeIntervalSince1970)))
    context.insert(Expense(cost: 8000, name: "버스", tag: "아빠 카드", date: String(Date.now.timeIntervalSince1970)))

    return HomeView()
        .modelContainer(container)
}
