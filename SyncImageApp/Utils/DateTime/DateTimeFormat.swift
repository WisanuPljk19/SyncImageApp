//
//  DateFormat.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 16/11/2564 BE.
//

import Foundation

public enum DateTimeFormat {
    
    case display
    case timestamp
    
    var format: String {
        switch self {
        case .display:
            return "dd MMM yyyy"
        case .timestamp:
            return "yyyyMMdd_HHmmssSSS"
        }
    }
    
}
