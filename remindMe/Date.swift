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

let languages = NSLocale.preferredLanguages()
let preferredLanguage = languages[0]

func addRecurringDate(delayAmount: Int, delayType : String, date: NSDate) -> NSDate {
    let newDateComponents = NSDateComponents()
    
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
    let calculateDate = NSCalendar.currentCalendar().dateByAddingComponents(newDateComponents, toDate: date, options: NSCalendarOptions.init(rawValue: 0))
    return calculateDate!
}

//func roundSecondsToZero(date: NSDate) -> NSDate {
//    let calendar = NSCalendar.currentCalendar()
//    let components = calendar.components([.Hour, .Minute], fromDate: date)
//    let newDate = calendar.dateBySettingHour(components.hour, minute: components.minute, second: 0, ofDate: date, options: NSCalendarOptions.init(rawValue: 0))
//    print(newDate)
//    return newDate!
//}


func setTime(hour: Int, minute: Int, second: Int, addedDay: Int ) -> NSDate {
    let now = NSDate()
    let calendar = NSCalendar.currentCalendar()
    var newDate = calendar.dateBySettingHour(
        hour, minute: minute, second: second,
        ofDate: now,
        options: NSCalendarOptions.init(rawValue: 0)
    )
    newDate = calendar.dateByAddingUnit(
        .Day,
        value: addedDay,
        toDate: newDate!,
        options: NSCalendarOptions.init(rawValue: 0)
    )
    return newDate!
}

func tomorrowMidnight() -> NSDate {
    let tomorrowMidnight = setTime(23, minute: 59, second: 59, addedDay: 1)
    return tomorrowMidnight
}

func nextSevenDays() -> NSDate {
    let today = NSDate()
    return today.endOfDay.addDays(6)
}


func convertDateToString(dateToConvert date: NSDate) -> String {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: preferredLanguage)
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    return formatter.stringFromDate(date)
}

func convertDateToString(format: DateFormats, date: NSDate) -> String {
    let today = NSDate()
    let startOfDay = today.startOfDay
    let endOfDay = today.endOfDay
    let earlierDate = date.earlierDate(endOfDay)
    let earlierBetweenMorningAndDate = startOfDay.earlierDate(date)
    let formatter = NSDateFormatter()
    var dateFormat = ""
    formatter.locale = NSLocale(localeIdentifier: preferredLanguage)
    
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
    
    if format == .Day {
        if earlierDate == date {
            if earlierBetweenMorningAndDate == startOfDay {
                return "Today"
            } else {
                return formatter.stringFromDate(date)
            }
        } else if earlierDate == endOfDay {
            let earlyDate = date.earlierDate(tomorrowMidnight())
            if earlyDate == date {
                return "Tomorrow"
            }
        }
        
    }
    
    return formatter.stringFromDate(date)
}

func createNewDate(oldDate : NSDate, typeOfInterval: String, everyAmount: Int) -> NSDate {
    let newDateComponents = NSDateComponents()
    
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
    
    let calculateDate = NSCalendar.currentCalendar().dateByAddingComponents(newDateComponents, toDate: oldDate, options: NSCalendarOptions.init(rawValue: 0))
    return calculateDate!
    
}

func calculateDateDifference(date: NSDate) -> NSDateComponents {
    let now = NSDate()
    
    let difference = NSCalendar.currentCalendar().components(
        [.Year, .Month, .Day, .Hour, .Minute, .Second],
        fromDate: date,
        toDate: now,
        options: NSCalendarOptions.init(rawValue: 0)
    )
    
    return difference

}

func recurringInterval(typeOfInterval: String) -> NSCalendarUnit {
    
    var calendarUnit = NSCalendarUnit()
    
    switch typeOfInterval {
    case "minute":
        calendarUnit = .Minute
    case "hour":
        calendarUnit = .Hour
    case "day":
        calendarUnit = .Day
    case "month":
        calendarUnit = .Month
    case "year":
        calendarUnit = .Year
    default:
        print("Error")
    }
    return calendarUnit
    
}

func getDeferAmount(deferAmount: String) -> NSTimeInterval {
    switch deferAmount {
    case "10 seconds":
        return 10
    case "5 minutes":
        return 60 * 5
    case "10 minutes":
        return 60 * 10
    case "30 minutes":
        return 60 * 30
    case "1 hour":
        return 60 * 60
    default:
        return 0
    }
    
    
}


