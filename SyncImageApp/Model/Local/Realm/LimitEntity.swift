//
//  LimitData.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 15/11/2564 BE.
//

import Foundation
import RealmSwift

class LimitEntity: Object {
    @Persisted var png: Int
    @Persisted var jpeg: Int
    @Persisted var heic: Int
    
    class func initialLimit() -> LimitEntity{
        let limitEntity = LimitEntity()
        limitEntity.png = Constant.LIMIT_PNG_QTY
        limitEntity.jpeg = Constant.LIMIT_JPEG_QTY
        limitEntity.heic = Constant.LIMIT_HEIC_QTY
        return limitEntity
    }
}
