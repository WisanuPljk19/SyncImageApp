//
//  RealmManager.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 16/11/2564 BE.
//

import Foundation
import RealmSwift
import RxRealm
import RxSwift

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
    
    func getLimitsEntity() -> LimitEntity? {
        return realm.objects(LimitEntity.self).first
    }
    
    func getLimitsEntityChangeset() -> Observable<(AnyRealmCollection<LimitEntity>, RealmChangeset?)> {
        Observable.changeset(from: realm.objects(LimitEntity.self))
    }
    
    func saveLimitData(limitEntity: LimitEntity) -> LimitEntity?{
        do {
            try realm.write {
                self.realm.add(limitEntity)
            }
            return limitEntity
        } catch {
            return nil
        }
    }
    
    func updateLimitsEntity(jpeg: Int, png: Int, heic: Int) -> LimitEntity? {
        guard let limitEntity = realm.objects(LimitEntity.self).first else {
            return nil
        }
        
        do {
            try realm.write{
                limitEntity.jpeg = jpeg
                limitEntity.png = png
                limitEntity.heic = heic
            }
            return limitEntity
        } catch {
            return nil
        }
    }
    
    func getImageEntityChangeset() -> Observable<(AnyRealmCollection<ImageEntity>, RealmChangeset?)>{
        Observable.changeset(from: realm.objects(ImageEntity.self))
    }
    
    func getImageEntities(isSync: Bool?) -> [ImageEntity] {
        return realm.objects(ImageEntity.self).toList(of: ImageEntity.self)
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
