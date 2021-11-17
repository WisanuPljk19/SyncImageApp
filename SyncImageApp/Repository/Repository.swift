//
//  Repository.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 16/11/2564 BE.
//

import Foundation
import RxSwift
import RxRealm
import FirebaseStorage

final class Repository {
    
    static let shared = Repository()

    private var realmManager: RealmManager
    private var remoteStorageManager: FirebaseStorageManager
    
    private init() {
        self.realmManager = RealmManager.shared
        self.remoteStorageManager = FirebaseStorageManager.shared
    }
    
    func getImageData() -> Observable<(RealmChangesetEnums, [ImageData], [Int])>{
        realmManager.getImageEntityChangeset().map { imageEntities, changeset in
            let changesetEnum = RealmChangesetEnums.getEnumsFrom(changeset)
            var indexChange:[Int] {
                switch changesetEnum {
                case .initial:
                    return []
                case .delete:
                    return changeset?.deleted ?? []
                case .update:
                    return changeset?.updated ?? []
                case .insert:
                    return changeset?.inserted ?? []
                }
            }
            return (changesetEnum,
                    imageEntities.toArray().map{ ImageData.buildImageDataFrom(imageEntity: $0)},
                    indexChange
            )
        }
    }

    func saveImageData(imageData: ImageData) -> Bool{
        return realmManager.saveImageEntity(imageEntity: ImageEntity.createImageEntityFrom(imageData: imageData)) != nil
    }
    
    func updateImageData(imageData: ImageData) -> Bool {
        return realmManager.updateImageEntity(id: imageData.id, syncDate: imageData.syncDate, remotePath: imageData.remotePath) != nil
    }
    
    func uploadImage(imageData: ImageData,
                     onSuccess onSuccessHandler: ((String, String) -> Void)? = nil,
                     onFailure onFailureHandler:((StorageErrorCode?) -> Void)? = nil) {
        remoteStorageManager.uploadImage(imageData, onSuccess: onSuccessHandler, onFailure: onFailureHandler)
    }
    
    func subscribeUploadTask(onProcess onProcessHandler: PublishSubject<(String, Float)>?,
                             onSuccess onSuccessHandler: PublishSubject<String>?){
        remoteStorageManager.subscribeUploadTask(onProcess: onProcessHandler, onSuccess: onSuccessHandler)
    }
    
    func unsubscribeUploadTask(){
        remoteStorageManager.unsubscribeUploadTask()
    }
    
    func getLimitData() -> LimitData{
        return LimitData(limitEntity: realmManager.getLimitsEntity() ??
                            realmManager.saveLimitData(limitEntity: LimitEntity.initialLimit())!)
    }
//    
//    func updateLimitData(limitData: LimitData) -> Bool{
//        return realmManager.updateLimitsEntity(jpeg: limitData.jpeg, png: limitData.png, heic: limitData.heic)
//    }
    
}
