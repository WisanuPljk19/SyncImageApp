//
//  LimitData.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 17/11/2564 BE.
//

import Foundation

struct LimitData{
    var png: Int
    var jpeg: Int
    var heic: Int
    
    init(limitEntity: LimitEntity) {
        self.png = limitEntity.png
        self.jpeg = limitEntity.jpeg
        self.heic = limitEntity.heic
    }
}
