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
    var fileType: String
    var remotePath: String? = nil
    var syncDate: Date? = nil
    
    init(id: String, name: String, localPath: String, fileType: String) {
        self.id = id
        self.name = name
        self.localPath = localPath
        self.fileType = fileType
    }
    
    class func buildImageDataFrom(imageEntity: ImageEntity) -> ImageData {
        let imageData = ImageData(id: imageEntity.id,
                                  name: imageEntity.name,
                                  localPath: imageEntity.localPath,
                                  fileType: imageEntity.fileType)
        imageData.updateDataSync(syncData: imageEntity.syncDate, remotePath: imageEntity.remotePath)
        return imageData
    }
    
    func updateDataSync(syncData: Date?, remotePath: String?){
        self.syncDate = syncData
        self.remotePath = remotePath
    }
    
}
