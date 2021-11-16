//
//  Repository.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 16/11/2564 BE.
//

import Foundation
import UIKit

final class Repository {
    
    static let shared = Repository()

    private var realmManager: RealmManager

    private init() {
        self.realmManager = RealmManager.shared
    }

    func saveImageData(imageData: ImageData) -> Bool{
        return realmManager.saveImageEntity(imageEntity: ImageEntity.createImageEntityFrom(imageData: imageData)) != nil
    }
    
    func updateImageData(imageData: ImageData) -> Bool {
        return realmManager.updateImageEntity(id: imageData.id, syncDate: imageData.syncDate, remotePath: imageData.remotePath) != nil
    }
    
    
}
