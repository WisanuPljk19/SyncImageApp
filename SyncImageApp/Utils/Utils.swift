//
//  Utils.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 15/11/2564 BE.
//

import Foundation
import UIKit

class Utils {
    class func calculatePercentComplete(complete: Double, total: Double) -> Double{
        return 100.0 * complete / total
    }
    
    func isImageSizeGeaterMoreThan(_ imageSize: Int, maximumSize: Int) -> Bool{
        return imageSize < maximumSize
    }
}

