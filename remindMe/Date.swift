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

enum CustomTimeInterval: String {
    case second
    case minute
    case hour
    case day
    case week
    case month
    case year
    
    var singularInterval: String {
        switch self {
        case .second:
            return NSLocalizedString("second", comment: "singular seconds")
        case .minute:
            return NSLocalizedString("minute", comment: "singular minutes")
        case .hour:
            return NSLocalizedString("hour", comment: "singular hours")
        case .day:
            return NSLocalizedString("day", comment: "singular days")
        case .week:
            return NSLocalizedString("week", comment: "singular weeks")
        case .month:
            return NSLocalizedString("month", comment: "singular months")
        case .year:
            return NSLocalizedString("year", comment: "singular years")
        }
    }
    
    var pluralInterval: String {
        switch self {
        case .second:
            return NSLocalizedString("seconds", comment: "plural seconds")
        case .minute:
            return NSLocalizedString("minutes", comment: "plural minutes")
        case .hour:
            return NSLocalizedString("hours", comment: "plural hours")
        case .day:
            return NSLocalizedString("days", comment: "plural days")
        case .week:
            return NSLocalizedString("weeks", comment: "plural weeks")
        case .month:
            return NSLocalizedString("months", comment: "plural months")
        case .year:
            return NSLocalizedString("years", comment: "plural years")
        }
    }
    
}

enum Day: String {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var fullDay: String {
        switch self {
        case .monday:
            return NSLocalizedString("Monday", comment: "Day of the week")
        case .tuesday:
            return NSLocalizedString("Tuesday", comment: "Day of the week")
        case .wednesday:
            return NSLocalizedString("Wednesday", comment: "Day of the week")
        case .thursday:
            return NSLocalizedString("Thursday", comment: "Day of the week")
        case .friday:
            return NSLocalizedString("Friday", comment: "Day of the week")
        case .saturday:
            return NSLocalizedString("Saturday", comment: "Day of the week")
        case .sunday:
            return NSLocalizedString("Sunday", comment: "Day of the week")
        }
    }
    
    var abbreviatedDay: String {
        switch self {
        case .monday:
            return NSLocalizedString("Mo", comment: "Abbreviation of Monday")
        case .tuesday:
            return NSLocalizedString("Tu", comment: "Abbreviation of Tuesday")
        case .wednesday:
            return NSLocalizedString("We", comment: "Abbreviation of Wednesday")
        case .thursday:
            return NSLocalizedString("Th", comment: "Abbreviation of Thursday")
        case .friday:
            return NSLocalizedString("Fr", comment: "Abbreviation of Friday")
        case .saturday:
            return NSLocalizedString("Sa", comment: "Abbreviation of Saturday")
        case .sunday:
            return NSLocalizedString("Su", comment: "Abbreviation of Sunday")
        }
    }
}

func weekday(day : Day, nbOfSelectedDays: Int) -> String {
    if nbOfSelectedDays != 1 {
        return day.abbreviatedDay
    } else {
        return day.fullDay
    }
}

func selectedDay(day: Int) -> Day {
    switch day {
    case 1:
        return .sunday
    case 2:
        return .monday
    case 3:
        return .tuesday
    case 4:
        return .wednesday
    case 5:
        return .thursday
    case 6:
        return .friday
    case 7:
        return .saturday
    default:
        print("Error")
        return .monday
    }
}

func listOfSelectedDays(selectedDays: [Int]) -> String {
    var stringOfDays = ""
    if selectedDays.count > 0 {
        for day in selectedDays {
            let aDay = selectedDay(day: day)
            let dayAsString = weekday(day: aDay, nbOfSelectedDays: selectedDays.count)
            stringOfDays.append(dayAsString)
            
            if selectedDays.count > 1 {
                // Do not print comma after last word
                if selectedDays.index(of: day)! < selectedDays.count - 1 {
                    stringOfDays.append(", ")
                }
            }
        }
    }
    return stringOfDays
}

func patternPhrase(frequency: Int, interval: String) -> String {
    let newInterval: CustomTimeInterval = CustomTimeInterval(rawValue: interval)!
    if frequency != 1 {
        return String(format: NSLocalizedString("PLURAL_SENTENCE", comment: "Example 'Every 2 days'"), frequency, newInterval.pluralInterval)
    } else {
        return String(format: NSLocalizedString("every %@", comment: "Example: 'every year', 'every day'"), newInterval.singularInterval)
    }
}

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
    //formatter.locale = Locale(identifier: preferredLanguage)
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

func convertDateToString(_ format: DateFormats, date: Date) -> String {
    
    let formatter = DateFormatter()
    var dateFormat = ""
    //formatter.locale = Locale(identifier: preferredLanguage)
    
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
        if date.isToday() {
            return NSLocalizedString("Today", comment: "")
        } else if date.isTomorrow() {
            return NSLocalizedString("Tomorrow", comment: "")
        } else if date.isYesterday() {
            return NSLocalizedString("Yesterday", comment: "")
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


