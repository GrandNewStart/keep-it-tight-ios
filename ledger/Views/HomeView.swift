//
//  HomeView.swift
//  ledger
//
//  Created by Jinwoo Hwangbo on 6/22/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
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
    @State private var selectedExpense: Expense?
    @State private var showSettings: Bool = false
    @State private var showInputModal: Bool = false
    @State private var selectedTagFilter: String = "전체"
    @State private var selectedMonth: Int?
    @State private var selectedYear: Int?

    var availableYears: [Int] {
        let years: [Int] = expenses.compactMap { expense in
            guard let timestamp = Double(expense.date) else { return nil }
            let year = Calendar.current.dateComponents([.year], from: Date(timeIntervalSince1970: timestamp / 1000)).year
            return year
        }
        return Array(Set(years)).sorted(by: >)
    }

    var availableMonths: [Int] {
        guard let selectedYear = selectedYear else { return [] }
        let months: [Int] = expenses.compactMap { expense in
            guard let timestamp = Double(expense.date) else { return nil }
            let date = Date(timeIntervalSince1970: timestamp / 1000)
            let comps = Calendar.current.dateComponents([.year, .month], from: date)
            guard comps.year == selectedYear else { return nil }
            return comps.month
        }
        return Array(Set(months)).sorted()
    }

    var filteredExpenses: [Expense] {
        expenses.filter { expense in
            guard let timestamp = Double(expense.date) else { return false }
            let date = Date(timeIntervalSince1970: timestamp / 1000)
            let comps = Calendar.current.dateComponents([.year, .month], from: date)

            let tagMatch = selectedTagFilter == "전체" || expense.tag == selectedTagFilter
            let monthMatch = selectedMonth == nil || comps.month == selectedMonth
            let yearMatch = selectedYear == nil || comps.year == selectedYear
            return tagMatch && monthMatch && yearMatch
        }
    }

    var totals: (day: Int, month: Int, year: Int) {
        let now = Date()
        let calendar = Calendar.current

        let grouped = expenses.reduce(into: (0, 0, 0)) { acc, expense in
            guard let timestamp = Double(expense.date) else { return }
            let date = Date(timeIntervalSince1970: timestamp / 1000)
            if calendar.isDate(date, inSameDayAs: now) {
                acc.0 += expense.cost
            }
            if calendar.isDate(date, equalTo: now, toGranularity: .month) {
                acc.1 += expense.cost
            }
            if calendar.isDate(date, equalTo: now, toGranularity: .year) {
                acc.2 += expense.cost
            }
        }
        return grouped
    }

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
            HStack {
                Text("정신차려")
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                Button(action: {
                    showInputModal = true
                }) {
                    Image(systemName: "plus")
                        .imageScale(.large)
                        .padding(.trailing, 4)
                }

                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .imageScale(.large)
                        .padding(.trailing, 8)
                }
            }
            .padding([.top, .horizontal], 8)

            // Header row
            ZStack {
                Color.blue.opacity(0.3)
                HStack {
                    Text("금액")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("설명")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("태그")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
            }
            .frame(height: 48)

            // Expense list
            List {
                ForEach(groupedExpenses, id: \.key) { date, items in
                    
                    Section(header: Text(date).fontWeight(.bold)) {
                        ForEach(items) { expense in
                            Button(action: {
                                selectedExpense = expense
                            }) {
                                HStack {
                                    Text("\(abs(expense.cost))")
                                        .foregroundStyle(expense.cost < 0 ? Color.blue : Color.red)
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

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    HStack {
                        Text("오늘의 지출  ")
                            .fontWeight(.bold)
                        Text("\(-sumBy(.day))")
                            .foregroundColor(sumBy(.day) > 0 ? .red : .blue)
                    }
                    Spacer()
                    Picker("", selection: $selectedTagFilter) {
                        Text("전체").tag("전체")
                        ForEach(TagManager.tags, id: \.self) { tag in
                            Text(tag).tag(tag)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(height: 48)
                }

                HStack {
                    HStack {
                        Text("이달의 지출  ")
                            .fontWeight(.bold)
                        Text("\(-sumBy(.month))")
                            .foregroundColor(sumBy(.month) > 0 ? .red : .blue)
                    }
                    Spacer()
                    Picker("", selection: $selectedMonth) {
                        ForEach(availableMonths, id: \.self) { month in
                            Text("\(month)월").tag(Optional(month))
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(height: 48)
                }

                HStack {
                    HStack {
                        Text("올해의 지출  ")
                            .fontWeight(.bold)
                        Text("\(-sumBy(.year))")
                            .foregroundColor(sumBy(.year) > 0 ? .red : .blue)
                    }
                    Spacer()
                    Picker("", selection: $selectedYear) {
                        ForEach(availableYears, id: \.self) { year in
                            Text("\(year)년").tag(Optional(year))
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(height: 48)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(item: $selectedExpense) { expense in
            EditExpenseView(expense: expense)
                .environment(\.modelContext, modelContext)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showInputModal) {
            InputView()
                .environment(\.modelContext, modelContext)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            let now = Date()
            let comps = Calendar.current.dateComponents([.year, .month], from: now)
            selectedYear = comps.year
            selectedMonth = comps.month
        }
    }

    func sumBy(_ granularity: Calendar.Component) -> Int {
        let targetDate: Date
        let calendar = Calendar.current
        switch granularity {
        case .day:
            targetDate = Date()
        case .month:
            guard let selectedYear, let selectedMonth else { return 0 }
            targetDate = calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth)) ?? Date()
        case .year:
            guard let selectedYear else { return 0 }
            targetDate = calendar.date(from: DateComponents(year: selectedYear)) ?? Date()
        default:
            return 0
        }
        return expenses.reduce(0) { partialResult, expense in
            guard let timestamp = Double(expense.date) else { return partialResult }
            let date = Date(timeIntervalSince1970: timestamp / 1000)
            let comps = Calendar.current.dateComponents([.year, .month], from: date)

            // Always apply tag filter
            let tagMatch = selectedTagFilter == "전체" || expense.tag == selectedTagFilter

            // Conditionally apply month/year filters depending on granularity
            let monthMatch = granularity == .month ? selectedMonth == nil || comps.month == selectedMonth : true
            let yearMatch = granularity == .year ? selectedYear == nil || comps.year == selectedYear : true

            let match = Calendar.current.isDate(date, equalTo: targetDate, toGranularity: granularity)
                && tagMatch && monthMatch && yearMatch

            return match ? partialResult + expense.cost : partialResult
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
    context.insert(Expense(cost: 11000, name: "커피", tag: "내 카드", date: String(Date.now.timeIntervalSince1970)))
    context.insert(Expense(cost: 10000, name: "식사", tag: "법인 카드", date: String(Date.now.timeIntervalSince1970)))
    context.insert(Expense(cost: 2000, name: "버스", tag: "아빠 카드", date: String(Date.now.timeIntervalSince1970)))
    
    TagManager.add("내 카드")
    TagManager.add("법인 카드")
    TagManager.add("아빠 카드")

    return HomeView()
        .modelContainer(container)
}
