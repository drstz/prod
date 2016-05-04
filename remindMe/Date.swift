//
//  Date.swift
//  remindMe
//
//  Created by Duane Stoltz on 15/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation

// MARK: - Date Converter

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

func roundSecondsToZero(date: NSDate) -> NSDate {
    let calendar = NSCalendar.currentCalendar()
    let newDate = calendar.dateBySettingUnit(.Second, value: 0, ofDate: date, options: NSCalendarOptions.init(rawValue: 0))
    print(newDate)
    return newDate!
}

func convertDateToString(dateToConvert date: NSDate) -> String {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: preferredLanguage)
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    return formatter.stringFromDate(date)
}

func convertDateToString(dayFromDate date: NSDate) -> String {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: preferredLanguage)
    formatter.dateFormat = "EEEE"
    return formatter.stringFromDate(date)
    
}

func convertDateToString(dateFromDate date: NSDate) -> String {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: preferredLanguage)
    formatter.dateFormat = "dd, MMMM, yy"
    return formatter.stringFromDate(date)
    
}

func convertDateToString(timeFromDate date: NSDate) -> String {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: preferredLanguage)
    formatter.dateFormat = "HH:mm "
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
    print(calculateDate!)
    return calculateDate!
    
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


