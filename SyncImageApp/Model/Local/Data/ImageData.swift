//
//  ImageData.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 16/11/2564 BE.
//

import Foundation

class ImageData {
    var id: String
    var name: String
    var localPath: String
    var contentType: String
    var remotePath: String? = nil
    var syncDate: Date? = nil
    
    init(id: String, name: String, localPath: String, contentType: String) {
        self.id = id
        self.name = name
        self.localPath = localPath
        self.contentType = contentType
    }
    
    class func buildImageDataFrom(imageEntity: ImageEntity) -> ImageData {
        let imageData = ImageData(id: imageEntity.id,
                                  name: imageEntity.name,
                                  localPath: imageEntity.localPath,
                                  contentType: imageEntity.contentType)
        imageData.updateDataSync(syncData: imageEntity.syncDate, remotePath: imageEntity.remotePath)
        return imageData
    }
    
    func updateDataSync(syncData: Date?, remotePath: String?){
        self.syncDate = syncData
        self.remotePath = remotePath
    }
    
}
