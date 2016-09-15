//
//  NSDate+more.swift
//  remindMe
//
//  Created by Duane Stoltz on 05/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation

extension Date {
    
    var calendar: Calendar {
        return Calendar.current
    }
    
    var today: Date {
        return Date()
    }
    
    var tomorrow: Date {
        return today.nextDay()
    }
    
    var yesterday: Date {
        return today.previousDay()
    }
    
    var tonight: Date {
        return today.endOfDay
    }
    
    var thisMorning: Date {
        return today.startOfDay
    }
    
    var startOfDay: Date {
        return (calendar as NSCalendar).date(bySettingHour: 0, minute: 0, second: 0, of: self, options: NSCalendar.Options.init(rawValue: 0))!
        
    }
    var endOfDay: Date {
        return (calendar as NSCalendar).date(bySettingHour: 23, minute: 59, second: 59, of: self, options: NSCalendar.Options.init(rawValue: 0))!
    }
    
    func roundSecondsToZero() -> Date {
        let components = (calendar as NSCalendar).components([.hour, .minute], from: self)
        return (calendar as NSCalendar).date(bySettingHour: components.hour!, minute: components.minute!, second: 0, of: self, options: NSCalendar.Options.init(rawValue: 0))!
    }
    
    func addMinutes(_ nbOfMinutes: Int) -> Date {
        return (calendar as NSCalendar).date(byAdding: .minute, value: nbOfMinutes, to: self, options: NSCalendar.Options.init(rawValue: 0))!
    }
    
    func addHours(_ nbOfHours: Int) -> Date {
        return (calendar as NSCalendar).date(byAdding: .hour, value: nbOfHours, to: self, options: NSCalendar.Options.init(rawValue: 0))!
    }
    
    func addDays(_ nbOfDays: Int) -> Date {
        return (calendar as NSCalendar).date(byAdding: .day, value: nbOfDays, to: self, options: NSCalendar.Options.init(rawValue: 0))!
    }
    
    func addWeeks(_ nbOfWeeks: Int) -> Date {
        return (calendar as NSCalendar).date(byAdding: .weekOfYear, value: nbOfWeeks, to: self, options: NSCalendar.Options.init(rawValue: 0))!
    }
    
    func addMonths(_ nbOfMonths: Int) -> Date {
        return (calendar as NSCalendar).date(byAdding: .month, value: nbOfMonths, to: self, options: NSCalendar.Options.init(rawValue: 0))!
    }
    
    func nextDay() -> Date {
        return self.addDays(1)
    }
    
    
    func nextMorning() -> Date {
        return nextDay().startOfDay
    }
    
    func nextNight() -> Date {
        return nextDay().endOfDay
    }
    
    func previousDay() -> Date {
        return self.addDays(-1)
    }
    
    func previousMorning() -> Date {
        return previousDay().startOfDay
    }
    
    func previousNight() -> Date {
        return previousDay().endOfDay
    }
    
    func isToday() -> Bool {
        return (thisMorning as NSDate).laterDate(self) == self && (tonight as NSDate).earlierDate(self) == self
    }
    
    func isTomorrow() -> Bool {
        return (tomorrow.startOfDay as NSDate).laterDate(self) == self && (tomorrow.endOfDay as NSDate).earlierDate(self) == self
    }
    
    func isYesterday() -> Bool {
        return (yesterday.startOfDay as NSDate).laterDate(self) == self && (yesterday.endOfDay as NSDate).earlierDate(self) == self
    }
    
    func lessThanWeekFromNow() -> Bool {
        let now = Date()
        let sixDaysFromNow = now.addDays(6)
        let earlierDate = (sixDaysFromNow as NSDate).earlierDate(self)
        if earlierDate == self {
            return true
        } else {
            return false
        }
    }
    
    func underMonths(months amount: Int) -> Bool {
        let monthsFromNow = today.addMonths(amount)
        if (monthsFromNow as NSDate).earlierDate(self) == self {
            return true
        } else {
            return false
        }
    }
    
    func underWeek(weeks amount: Int) -> Bool {
        let weeksFromNow = today.addWeeks(amount)
        if (weeksFromNow as NSDate).earlierDate(self) == self {
            return true
        } else {
            return false
        }
    }
    
    func writtenDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
    
    func writtenDayPlusMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd MMMM"
        return formatter.string(from: self)
    }
    
    func isPresent() -> Bool {
        return (today as NSDate).laterDate(self) == self
    }
    
    
}
