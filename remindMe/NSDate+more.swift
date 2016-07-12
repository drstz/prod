//
//  NSDate+more.swift
//  remindMe
//
//  Created by Duane Stoltz on 05/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation

extension NSDate {
    
    var calendar: NSCalendar {
        return NSCalendar.currentCalendar()
    }
    
    var today: NSDate {
        return NSDate()
    }
    
    var tomorrow: NSDate {
        return today.nextDay()
    }
    
    var yesterday: NSDate {
        return today.previousDay()
    }
    
    var tonight: NSDate {
        return today.endOfDay
    }
    
    var thisMorning: NSDate {
        return today.startOfDay
    }
    
    var startOfDay: NSDate {
        return calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: self, options: NSCalendarOptions.init(rawValue: 0))!
        
    }
    var endOfDay: NSDate {
        return calendar.dateBySettingHour(23, minute: 59, second: 59, ofDate: self, options: NSCalendarOptions.init(rawValue: 0))!
    }
    
    func roundSecondsToZero() -> NSDate {
        let components = calendar.components([.Hour, .Minute], fromDate: self)
        return calendar.dateBySettingHour(components.hour, minute: components.minute, second: 0, ofDate: self, options: NSCalendarOptions.init(rawValue: 0))!
    }
    
    func addMinutes(nbOfMinutes: Int) -> NSDate {
        return calendar.dateByAddingUnit(.Minute, value: nbOfMinutes, toDate: self, options: NSCalendarOptions.init(rawValue: 0))!
    }
    
    func addHours(nbOfHours: Int) -> NSDate {
        return calendar.dateByAddingUnit(.Hour, value: nbOfHours, toDate: self, options: NSCalendarOptions.init(rawValue: 0))!
    }
    
    func addDays(nbOfDays: Int) -> NSDate {
        return calendar.dateByAddingUnit(.Day, value: nbOfDays, toDate: self, options: NSCalendarOptions.init(rawValue: 0))!
    }
    
    func addWeeks(nbOfWeeks: Int) -> NSDate {
        return calendar.dateByAddingUnit(.WeekOfYear, value: nbOfWeeks, toDate: self, options: NSCalendarOptions.init(rawValue: 0))!
    }
    
    func addMonths(nbOfMonths: Int) -> NSDate {
        return calendar.dateByAddingUnit(.Month, value: nbOfMonths, toDate: self, options: NSCalendarOptions.init(rawValue: 0))!
    }
    
    func nextDay() -> NSDate {
        return self.addDays(1)
    }
    
    
    func nextMorning() -> NSDate {
        return nextDay().startOfDay
    }
    
    func nextNight() -> NSDate {
        return nextDay().endOfDay
    }
    
    func previousDay() -> NSDate {
        return self.addDays(-1)
    }
    
    func previousMorning() -> NSDate {
        return previousDay().startOfDay
    }
    
    func previousNight() -> NSDate {
        return previousDay().endOfDay
    }
    
    func isToday() -> Bool {
        return thisMorning.laterDate(self) == self && tonight.earlierDate(self) == self
    }
    
    func isTomorrow() -> Bool {
        return tomorrow.startOfDay.laterDate(self) == self && tomorrow.endOfDay.earlierDate(self) == self
    }
    
    func isYesterday() -> Bool {
        return yesterday.startOfDay.laterDate(self) == self && yesterday.endOfDay.earlierDate(self) == self
    }
    
    func lessThanWeekFromNow() -> Bool {
        let now = NSDate()
        let sixDaysFromNow = now.addDays(6)
        let earlierDate = sixDaysFromNow.earlierDate(self)
        if earlierDate == self {
            return true
        } else {
            return false
        }
    }
    
    func writtenDay() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.stringFromDate(self)
    }
    
    func writtenDayPlusMonth() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE, dd MMMM"
        return formatter.stringFromDate(self)
    }
    
    
}
