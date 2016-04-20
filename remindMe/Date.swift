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
    case "hours":
        newDateComponents.hour = delayAmount
        case "days":
        newDateComponents.day = delayAmount
        case "weeks":
        newDateComponents.day = 7 * delayAmount
        case "months":
        newDateComponents.month = delayAmount
        case "years":
        newDateComponents.year = delayAmount
    default:
        print("Cant add date")
    }
    let calculateDate = NSCalendar.currentCalendar().dateByAddingComponents(newDateComponents, toDate: date, options: NSCalendarOptions.init(rawValue: 0))
    return calculateDate!
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


