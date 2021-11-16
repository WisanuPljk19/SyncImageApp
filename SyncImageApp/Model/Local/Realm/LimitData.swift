//
//  LimitData.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 15/11/2564 BE.
//

import Foundation
import RealmSwift

class LimitData: Object {
    @Persisted var png = 0
    @Persisted var jpeg = 0
    @Persisted var heic = 0
}
