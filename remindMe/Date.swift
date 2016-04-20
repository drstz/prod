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

func convertDateToString(dateToConvert date: NSDate) -> String {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: languages[0])
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    return formatter.stringFromDate(date)
}

func convertDateToString(dayFromDate date: NSDate) -> String {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: languages[0])
    formatter.dateFormat = "EEEE"
    return formatter.stringFromDate(date)
    
}

func convertDateToString(dateFromDate date: NSDate) -> String {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: languages[0])
    formatter.dateFormat = "dd, MMMM, yy"
    return formatter.stringFromDate(date)
    
}

func convertDateToString(timeFromDate date: NSDate) -> String {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: languages[0])
    formatter.dateFormat = "HH:mm "
    return formatter.stringFromDate(date)
    
}


