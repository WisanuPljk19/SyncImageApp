//
//  ImageEntity.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 15/11/2564 BE.
//

import Foundation
import RealmSwift

class ImageEntity: Object {
    @Persisted var id: String
    @Persisted var name: String
    @Persisted var localPath: String
    @Persisted var contentType: String
    @Persisted var remotePath: String?
    @Persisted var syncDate: Date?
    
    class func createImageEntityFrom(imageData: ImageData) -> ImageEntity{
        let imageEntity = ImageEntity()
        imageEntity.id = imageData.id
        imageEntity.name = imageData.name
        imageEntity.localPath = imageData.localPath
        imageEntity.contentType = imageData.contentType
        return imageEntity
    }
}



