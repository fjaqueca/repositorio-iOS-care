//
//  CalendarView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 28/10/2022.
//

import Foundation
import SwiftUI

extension CalendarView {
    struct DateValue: Identifiable {
        var id: Date {
            date
        }
        var day: Int
        var date: Date
    }
}

struct CalendarView: View {
    @Binding var markedDates: [Date]
    @Binding var selectedDate: Date?
    @Binding var selectedMonthOffset: Int
    var autoselectDateWhenMonthChanges: Bool = true
    @State var isFirstCalendar = false
    @Binding var UIStateAppoint: AppointmentUIStateModel

    
    var dateFormat: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_419")
        formatter.dateFormat = "MMMM"
        return formatter
    }

    var body: some View {
        VStack(spacing: 0.0) {
            monthSelectorView
            daysHeader
            daysGrid
        }
        .background{
            Color(hex: UIStateAppoint.appointmentUIState.calendarAtr.backColor)
        }
        .onChange(of: selectedMonthOffset) { newValue in
            if autoselectDateWhenMonthChanges {
                selectedDate = selectedMonthDate
            }
        }
    }

    var monthSelectorView: some View {
        HStack {
            Button {
                withAnimation {
                    selectedMonthOffset -= 1
                }
            } label: {
                Image(systemName: "chevron.left")
                    .renderingMode(.template)
                    .font(.appBodyBold)
                    .foregroundColor(Color(hex: UIStateAppoint.appointmentUIState.date.color))
            }
            Spacer()
            Text(dateFormat.string(from: Date().adding(months: selectedMonthOffset)))
                .textCase(.uppercase)
                .font(Font.custom(UIStateAppoint.appointmentUIState.date.font, size: CGFloat(Int(UIStateAppoint.appointmentUIState.date.size) ?? 18)))
                .foregroundColor(Color(hex: UIStateAppoint.appointmentUIState.date.color))
            Spacer()
            Button {
                withAnimation {
                    selectedMonthOffset += 1
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.appBodyBold)
                    .foregroundColor(Color(hex: UIStateAppoint.appointmentUIState.date.color))
            }
        }
        .padding(.margin)
        .background(Color.grayBackground)
    }
    
    @ViewBuilder
    var daysHeader: some View {
        let days = ["L", "M", "M", "J", "V", "S", "D"]
        HStack {
            ForEach(days.indices, id: \.self) { index in
                Text(days[index])
                    .font(.callout)
                    .foregroundColor(Color(hex: UIStateAppoint.appointmentUIState.calendarAtr.nameDayColor))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, .margin / 2)
    }
    
    @ViewBuilder
    var daysGrid: some View {
        VStack {
            Divider()
            ForEach(0..<6, id: \.self) { index in
                let offset = index * 7
                if offset <= calendarItems.count {
                    HStack {
                        let items = calendarItems.suffix(from: offset).prefix(7)
                        ForEach(items) { value in
                            dayItemView(value: value)
                                .onTapGesture {
                                    if isMarked(date: value.date) || isFirstCalendar{
                                        selectedDate = value.date
                                    }
                                }
                        }
                    }
                }
                Divider()
            }
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    func dayItemView(value: DateValue) -> some View {
        let isSelectedDate = Calendar.current.isDate(value.date, inSameDayAs: selectedDate ?? .distantFuture)
        VStack(spacing: 2) {
            if value.day != -1 {
                Text("\(value.day)")
                    .font(isMarked(date: value.date) ? .title3.bold() : .none)
                    .foregroundColor(isSelectedDate ? Color(hex: UIStateAppoint.appointmentUIState.calendarAtr.numSelectColor) : Color(hex: UIStateAppoint.appointmentUIState.calendarAtr.numDayColor))
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(Color(hex: UIStateAppoint.appointmentUIState.calendarAtr.circleSelectColor))
                            .opacity(isSelectedDate ? 1 : 0)
                    )
                if isFirstCalendar {
                    Circle()
                        .fill(Color(hex: UIStateAppoint.appointmentUIState.calendarAtr.pointColor))
                        .frame(width: 8, height: 8)
                        .opacity(isMarked(date: value.date) ? 1 : 0)
                }
            }
        }
        .frame(height: 42)
        .frame(maxWidth: .infinity)
    }
}

// MARK: // Helpers

extension CalendarView {
    private var calendarItems: [DateValue] {
        let calendar = Calendar.current
        // Getting current month date
        var days = selectedMonthDate.allDaysInSameMonth.compactMap { date -> DateValue in
            let day = calendar.component(.day, from: date)
            let dateValue =  DateValue(day: day, date: date)
            return dateValue
        }
        // Adding offset days to get exact week day...
        // Sunday is 1, Monday is 2, etc
        let weekdayOfFirstOfMonth = calendar.component(.weekday, from: days.first?.date ?? Date())
        // Remove 2 places so Monday has 0 spaces, then adjust to 0..6 range to avoid negative numbers.
        let emptyDaysAtTheBegining = (weekdayOfFirstOfMonth - 2 + 7).quotientAndRemainder(dividingBy: 7).remainder
        
        for i in 0..<emptyDaysAtTheBegining  {
            days.insert(DateValue(day: -1, date: Date.distantPast.adding(days: i)), at: 0)
        }

        let emptyDaysAtTheEnd = (7 - days.count % 7) % 7
        for i in 0..<emptyDaysAtTheEnd {
            days.append(.init(day: -1, date: Date.distantPast.adding(days: -i)))
        }
        return days
    }

    private var selectedMonthDate: Date {
        let calendar = Calendar.current
        guard let currentMonth = calendar.date(byAdding: .month, value: self.selectedMonthOffset, to: Date()) else {
            return Date()
        }
        return currentMonth
    }
    
    private func isMarked(date: Date) -> Bool {
        return markedDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) })
    }
}
