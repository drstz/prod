//: Playground - noun: a place where people can play

import Cocoa

extension NSDate {
    var calendar: NSCalendar {
        return NSCalendar.currentCalendar()
    }
    
    var startOfDay: NSDate {
        print("I was called")
        let calendar = NSCalendar.currentCalendar()
        let newDate = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: self, options: NSCalendarOptions.init(rawValue: 0))
        return newDate!
    }
    var endOfDay: NSDate {
        print("I was called")
        let calendar = NSCalendar.currentCalendar()
        let newDate = calendar.dateBySettingHour(23, minute: 59, second: 59, ofDate: self, options: NSCalendarOptions.init(rawValue: 0))
        return newDate!
    }
    
    func roundSecondsToZero() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute], fromDate: self)
        let newDate = calendar.dateBySettingHour(components.hour, minute: components.minute, second: 0, ofDate: self, options: NSCalendarOptions.init(rawValue: 0))
        print(newDate)
        return newDate!
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
    
    func previousDay() -> NSDate {
        return self.addDays(-1)
    }
    
    func previousNight() -> NSDate {
        return previousDay().endOfDay
    }
}

let now = NSDate()
let next7Days = now.addDays(6)
let weekFromNow = now.addWeeks(4)
let monthFromNow = now.addMonths(1)
let yesterday = now.previousDay()
let yesterdayMidnight = now.previousNight()



