//
//  Utils.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 15/11/2564 BE.
//

import Foundation
import UIKit
import NotificationBannerSwift

class Utils {
    
    class func calculatePercentComplete(complete: Float, total: Float) -> Float{
        return 100.0 * complete / total
    }
    
    class func getDocumentDir() -> URL?{
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    class func presentBanner(title: String, subTitle: String, style: BannerStyle){
        FloatingNotificationBanner(title: title,
                                   subtitle: subTitle,
                                   style: style).show(bannerPosition: .top,
                                                      queue: .init(maxBannersOnScreenSimultaneously: 3),
                                                      cornerRadius: 8,
                                                      shadowColor: UIColor(red: 0.431, green: 0.459, blue: 0.494, alpha: 1),
                                                      shadowBlurRadius: 16,
                                                      shadowEdgeInsets: UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8))
    }
}

