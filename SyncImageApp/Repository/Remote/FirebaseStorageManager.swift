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
    
    private init(){
        _storageRef = Storage.storage().reference().child(FirebaseStorageConfigs.CHILD_REF_PATH)
    }
    
    func uploadImage(_ imageData: ImageData,
                     onProcess:((String, Double) -> Void)? = nil,
                     onSuccess:((String, String) -> Void)? = nil,
                     onFailure:((String, String) -> Void)? = nil) {
        
        guard let localUrl = imageData.localPath.toUrl else {
            onFailure?(imageData.id, "cann't convert localPath \(imageData.localPath) to URL")
            return
        }
        
        let uploadTask = _storageRef
            .child(localUrl.lastPathComponent)
            .putFile(from: localUrl,
                     metadata: buildStorageMetadata(contentType: imageData.contentType))
        
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = Utils.calculatePercentComplete(complete: Double(snapshot.progress!.completedUnitCount),
                                                                 total: Double(snapshot.progress!.totalUnitCount))
            onProcess?(imageData.id, percentComplete)
        }
        
        uploadTask.observe(.success) { snapshot in
            onSuccess?(imageData.id, snapshot.reference.fullPath)
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError?,
               let storageErrorCode = StorageErrorCode(rawValue: error.code){
                switch storageErrorCode {
                case .objectNotFound:
                    Log.info("upload failure(objectNotFound) \(error.localizedDescription)")
                case .cancelled:
                    Log.info("upload failure(cancelled) \(error.localizedDescription)")
                case .unknown:
                    Log.info("upload failure(unknown) \(error.localizedDescription)")
                default:
                    Log.info("upload failure \(error.localizedDescription)")
                }
                onFailure?(imageData.id, error.localizedDescription)
            }
        }
    }
}

extension FirebaseStorageManager {
    func buildStorageMetadata(contentType: String) -> StorageMetadata{
        let metadata = StorageMetadata()
        metadata.contentType = contentType
        return metadata
    }
}
