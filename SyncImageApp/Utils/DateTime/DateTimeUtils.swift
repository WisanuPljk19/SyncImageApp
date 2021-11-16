//
//  DateTimeUtils.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 16/11/2564 BE.
//

import Foundation

class DateTimeUtils {
    
    public class func toDate(from string: String?,
                             dateFormat: DateTimeFormat = .timestamp,
                             locale: Locale = .current,
                             timeZone: TimeZone = .current) -> Date? {
        guard let dateString = string else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = dateFormat.format
        formatter.timeZone = timeZone
        return formatter.date(from: dateString)
    }
    
    public class func toString(from date: Date?,
                               dateFormat: DateTimeFormat = .timestamp,
                               locale: Locale = .current,
                               timeZone: TimeZone = .current) -> String? {
        guard let date = date else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = dateFormat.format
        return formatter.string(from: date)
    }
    
}
