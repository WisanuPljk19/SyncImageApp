//
//  FirebaseStorageManager.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 15/11/2564 BE.
//

import Foundation
import FirebaseStorage
import RxSwift

final class FirebaseStorageManager {
    
    static let shared = FirebaseStorageManager()
    
    private var _storageRef: StorageReference
    private var idOnUploading: String?
    private var observProcess: PublishSubject<(String, Float)>?
    private var observSuccess: PublishSubject<String>?
    
    private init(){
        _storageRef = Storage.storage().reference().child(FirebaseStorageConfigs.CHILD_REF_PATH)
    }
    
    func uploadImage(_ imageData: ImageData,
                     onSuccess:((String, String) -> Void)?,
                     onFailure:((StorageErrorCode?) -> Void)?) {
        
        guard let localUrl = Utils.getDocumentDir()?.appendingPathComponent(imageData.localPath) else {
//            onFailure?(imageData.id, "cann't convert localPath \(imageData.localPath) to URL")
            return
        }
        idOnUploading = imageData.id
        let uploadTask = _storageRef
            .child(localUrl.lastPathComponent)
            .putFile(from: localUrl,
                     metadata: buildStorageMetadata(fileType: imageData.fileType))

        uploadTask.observe(.progress) { snapshot in
            let percentComplete = Utils.calculatePercentComplete(complete: Float(snapshot.progress!.completedUnitCount),
                                                                 total: Float(snapshot.progress!.totalUnitCount))
            self.observProcess?.onNext((imageData.id, percentComplete))
        }
        
        uploadTask.observe(.success) { snapshot in
            self.observSuccess?.onNext(imageData.id)
            onSuccess?(imageData.id, snapshot.reference.fullPath)
        }

        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError? {
                onFailure?(StorageErrorCode(rawValue: error.code))
            }
        }
    }
    
    func subscribeUploadTask(onProcess: PublishSubject<(String, Float)>?,
                          onSuccess: PublishSubject<String>?) {
        self.observProcess = onProcess
        self.observSuccess = onSuccess
    }
    
    func unsubscribeUploadTask(){
        self.observProcess = nil
        self.observSuccess = nil
    }
}

extension FirebaseStorageManager {
    func buildStorageMetadata(fileType: String) -> StorageMetadata{
        let metadata = StorageMetadata()
        metadata.contentType = "image/\(fileType)"
        return metadata
    }
}
