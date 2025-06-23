//
//  HomeView.swift
//  ledger
//
//  Created by Jinwoo Hwangbo on 6/22/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Expense.date, order: .reverse) var expenses: [Expense]
    @State private var amountText: String = ""
    @State private var isIncome: Bool = false
    @State private var descText: String = ""
    @State private var tags: [String] = ["태그없음"]
    @State private var selectedTag: String? = "태그없음"
    @Environment(\.modelContext) private var modelContext

    @State private var selectedExpense: Expense?
    @State private var isEditing: Bool = false
    @State private var showSettings: Bool = false

    var body: some View {
        NavigationStack {
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
                            .tint(Color(hex: "#009B91"))
                            .imageScale(.large)
                            .padding(.trailing, 8)
                    }
                }
                .padding([.top, .horizontal], 8)

                // Header row
                ZStack {
                    Color(hex: "#009B91")
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
                List(expenses) { expense in
                    Button {
                        selectedExpense = expense
                        isEditing = true
                    } label: {
                        HStack {
                            Text("\(expense.cost)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(expense.name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(expense.tag ?? "-")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 4)
                        .foregroundColor(.primary)
                    }
                    .buttonStyle(PlainButtonStyle())
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
                    // Create and insert a new Expense item
                    guard let amount = Int(amountText), !descText.isEmpty else { return }
                    let newExpense = Expense(
                        cost: isIncome ? amount : -amount,
                        name: descText,
                        tag: selectedTag,
                        date: .now
                    )
                    modelContext.insert(newExpense)
                    amountText = ""
                    descText = ""
                    selectedTag = "태그없음"
                    isIncome = false
                }) {
                    Text("입력")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#009B91"))
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
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Expense.self, configurations: config)

    let context = container.mainContext
    context.insert(Expense(cost: 12000, name: "커피", tag: "내 카드", date: .now))
    context.insert(Expense(cost: 55000, name: "식사", tag: "법인 카드", date: .now))
    context.insert(Expense(cost: 8000, name: "버스", tag: "아빠 카드", date: .now))

    return HomeView()
        .modelContainer(container)
}
