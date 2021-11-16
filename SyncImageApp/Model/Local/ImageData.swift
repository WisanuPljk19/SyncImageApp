//
//  ImageData.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 15/11/2564 BE.
//

import Foundation
import RealmSwift

class ImageData: Object {
    @Persisted var id: String
    @Persisted var name: String
    @Persisted var localPath: String
    @Persisted var contentType: String
    @Persisted var remotePath: String?
    @Persisted var syncDate: Date?
}



