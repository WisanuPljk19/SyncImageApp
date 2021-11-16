//
//  Repository.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 16/11/2564 BE.
//

import Foundation
import RxSwift

final class Repository {
    
    static let shared = Repository()

    private var realmManager: RealmManager
    private var remoteStorageManager: FirebaseStorageManager
    
    private init() {
        self.realmManager = RealmManager.shared
        self.remoteStorageManager = FirebaseStorageManager.shared
    }

    func saveImageData(imageData: ImageData) -> Bool{
        return realmManager.saveImageEntity(imageEntity: ImageEntity.createImageEntityFrom(imageData: imageData)) != nil
    }
    
    func updateImageData(imageData: ImageData) -> Bool {
        return realmManager.updateImageEntity(id: imageData.id, syncDate: imageData.syncDate, remotePath: imageData.remotePath) != nil
    }
    
    func uploadImage(imageData: ImageData, onSuccess onSuccessHandler: ((String, String) -> Void)? = nil) {
        remoteStorageManager.uploadImage(imageData, onSuccess: onSuccessHandler)
    }
    
    func subscribeUploadTask(onProcess onProcessHandler: PublishSubject<(String, Float)>?,
                             onSuccess onSuccessHandler: PublishSubject<String>?){
        remoteStorageManager.subscribeUploadTask(onProcess: onProcessHandler, onSuccess: onSuccessHandler)
    }
    
    func unsubscribeUploadTask(){
        remoteStorageManager.unsubscribeUploadTask()
    }
    
}
