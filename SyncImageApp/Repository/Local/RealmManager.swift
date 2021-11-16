//
//  RealmManager.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 16/11/2564 BE.
//

import Foundation
import RealmSwift

final class RealmManager {
    
    static let shared = RealmManager()
    
    var realm: Realm
    
    private init() {
        do {
            let realmConfig = Realm.Configuration(schemaVersion: 1)
            self.realm = try Realm(configuration: realmConfig)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func saveImageEntity(imageEntity: ImageEntity) -> ImageEntity?{
        do {
            try realm.write {
                self.realm.add(imageEntity)
            }
            return imageEntity
        } catch {
            Log.info("cann't save ImageEntity with id: \(imageEntity.id), error \(error.localizedDescription)")
            return nil
        }
    }
        
        
    func updateImageEntity(id: String, syncDate: Date?, remotePath: String?) -> ImageEntity?{
        guard let imageEntity = realm.objects(ImageEntity.self).filter("id = %@", id).first else {
            Log.info("cann't find ImageEntity with id: \(id)")
            return nil
        }
        
        do {
            try realm.write{
                imageEntity.syncDate = syncDate
                imageEntity.remotePath = remotePath
            }
            return imageEntity
        } catch {
            Log.info("cann't update ImageEntity with id: \(id), error \(error.localizedDescription)")
            return nil
        }
    }
}
