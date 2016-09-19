//
//  Date.swift
//  remindMe
//
//  Created by Duane Stoltz on 15/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation

// MARK: - Date Converter

enum DateFormats: String {
    case Day = "EEEE"
    case WholeDate = "dd, MMMM, yy"
    case Time = "HH:mm "
    case ShortDate = "dd MMMM"
}

let languages = Locale.preferredLanguages
let preferredLanguage = languages[0]

func addRecurringDate(_ delayAmount: Int, delayType : String, date: Date) -> Date {
    var newDateComponents = DateComponents()
    
    switch delayType {
    case "minute":
        newDateComponents.minute = delayAmount
    case "hour":
        newDateComponents.hour = delayAmount
    case "day":
        newDateComponents.day = delayAmount
    case "week":
        newDateComponents.day = 7 * delayAmount
    case "month":
        newDateComponents.month = delayAmount
    case "year":
        newDateComponents.year = delayAmount
    default:
        print("Cant add date")
    }
    let calculateDate = (Calendar.current as NSCalendar).date(byAdding: newDateComponents, to: date, options: NSCalendar.Options.init(rawValue: 0))
    return calculateDate!
}

func setTime(_ hour: Int, minute: Int, second: Int, addedDay: Int ) -> Date {
    let now = Date()
    let calendar = Calendar.current
    var newDate = (calendar as NSCalendar).date(
        bySettingHour: hour, minute: minute, second: second,
        of: now,
        options: NSCalendar.Options.init(rawValue: 0)
    )
    newDate = (calendar as NSCalendar).date(
        byAdding: .day,
        value: addedDay,
        to: newDate!,
        options: NSCalendar.Options.init(rawValue: 0)
    )
    return newDate!
}

func tomorrowMidnight() -> Date {
    let today = Date()
    return today.endOfDay.addDays(1)
}

func nextSevenDays() -> Date {
    let today = Date()
    return today.endOfDay.addDays(6)
}


func convertDateToString(dateToConvert date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: preferredLanguage)
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

func convertDateToString(_ format: DateFormats, date: Date) -> String {
    
    
    let formatter = DateFormatter()
    var dateFormat = ""
    formatter.locale = Locale(identifier: preferredLanguage)
    
    switch format {
    case .WholeDate:
        dateFormat = format.rawValue
    case .Day:
        dateFormat = format.rawValue
    case .Time:
        dateFormat = format.rawValue
    case .ShortDate:
        dateFormat = format.rawValue
    }
    
    formatter.dateFormat = dateFormat
    
//    if format == .Day {
//        if earlierDate == date {
//            if earlierBetweenMorningAndDate == startOfDay {
//                return "Today"
//            } else {
//                return formatter.stringFromDate(date)
//            }
//        } else if earlierDate == endOfDay {
//            let earlyDate = date.earlierDate(tomorrowMidnight())
//            if earlyDate == date {
//                return "Tomorrow"
//            }
//        }
//    }
    
    if format == .Day {
        if date.isToday() {
            return "Today"
        } else if date.isTomorrow() {
            return "Tomorrow"
        } else if date.isYesterday() {
            return "Yesterday"
        } else {
            return formatter.string(from: date)
        }
    }
    
    return formatter.string(from: date)
}

func createNewDate(_ oldDate : Date, typeOfInterval: String, everyAmount: Int) -> Date {
    var newDateComponents = DateComponents()
    
    switch typeOfInterval {
    case "minute":
        newDateComponents.minute = everyAmount
    case "hour":
        newDateComponents.hour = everyAmount
    case "day":
        newDateComponents.day = everyAmount
    case "week":
        newDateComponents.day = everyAmount * 7
    case "month":
        newDateComponents.month = everyAmount
    case "year":
        newDateComponents.year = everyAmount
    default:
        print("Cant add date")
    }
    
    let calculateDate = (Calendar.current as NSCalendar).date(byAdding: newDateComponents, to: oldDate, options: NSCalendar.Options.init(rawValue: 0))
    return calculateDate!
    
}

func calculateDateDifference(_ date: Date) -> DateComponents {
    let now = Date()
    
    let difference = (Calendar.current as NSCalendar).components(
        [.year, .month, .day, .hour, .minute, .second],
        from: date,
        to: now,
        options: NSCalendar.Options.init(rawValue: 0)
    )
    
    return difference

}

func recurringInterval(_ typeOfInterval: String) -> NSCalendar.Unit {
    
    var calendarUnit = NSCalendar.Unit()
    
    switch typeOfInterval {
    case "minute":
        calendarUnit = .minute
    case "hour":
        calendarUnit = .hour
    case "day":
        calendarUnit = .day
    case "month":
        calendarUnit = .month
    case "year":
        calendarUnit = .year
    default:
        print("Error")
    }
    return calendarUnit
    
}

func snoozeDuration(_ duration: Double, unit: SnoozeUnit) -> TimeInterval {
    let minute = 60.0
    let hour = 3600.0
    let day = 86400.0
    
    switch unit {
    case .Seconds:
        return duration
    case .Minutes:
        return duration * minute
    case .Hours:
        return duration * hour
    case .Days:
        return duration * day
    }
}


