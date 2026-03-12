//
//  Date+Extensions.swift
//  CareAssistance
//
//  Created by Lara Dubs on 26/08/2022.
//

import Foundation

extension Date {
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }

    func adding(months: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: months, to: self)!
    }

    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    func endOfDay() -> Date {
        return Calendar.current.date(byAdding: DateComponents(hour: 23), to: self)!
    }

    /// Returns an array of dates representing each day of the same month.
    var allDaysInSameMonth: [Date] {
        let calendar = Calendar.current
        // geting start date
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        let range = calendar.range(of: .day, in: .month, for: startDate)
        // getting date...
        return range!.compactMap{ day -> Date in
            return calendar.date(byAdding: .day, value: day - 1 , to: startDate)!
        }
    }

    static let formatter = DateFormatter()
    
    /// String representing the time in the current user timezone
    var timeString: String {
        string(format: "HH:mm")
    }

    init(isoString: String) {
        self.init(string: isoString, format: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ")
    }

    init(string: String, format: String, timezone: TimeZone? = nil) {
        Self.formatter.locale = Locale(identifier: "en_US_POSIX")
        Self.formatter.dateFormat = format
        Self.formatter.timeZone =  timezone ?? .current
        if let date = Self.formatter.date(from: string) {
            self = date
        } else {
            print("There was an error with this date:\(string) format: \(format)",Date())
            self = Date()
        }
    }

    func string(format: String, timezone: TimeZone? = nil) -> String {
        Self.formatter.locale = Locale(identifier: "en_US_POSIX")
        Self.formatter.dateFormat = format
        Self.formatter.timeZone =  timezone ?? .current
        return Self.formatter.string(from: self)
    }

    /// String representing the date in gmt and with an iso format.
    var isoString: String {
        string(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ", timezone: .init(secondsFromGMT: 0))
    }
}
