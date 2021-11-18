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
    
    private init(){
        _storageRef = Storage.storage().reference().child(FirebaseStorageConfigs.CHILD_REF_PATH)
    }
    
    func uploadImage(_ imageData: ImageData,
                     onSuccess:((String, String) -> Void)?,
                     onFailure:((StorageErrorCode?) -> Void)?) {
        
        guard let localUrl = Utils.getDocumentDir()?.appendingPathComponent(imageData.localPath) else {
            return
        }
        idOnUploading = imageData.id
        let uploadTask = _storageRef
            .child(localUrl.lastPathComponent)
            .putFile(from: localUrl,
                     metadata: buildStorageMetadata(fileType: imageData.fileType))
        
        uploadTask.observe(.success) { snapshot in
            onSuccess?(imageData.id, snapshot.reference.fullPath)
        }

        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError? {
                onFailure?(StorageErrorCode(rawValue: error.code))
            }
        }
    }
}

extension FirebaseStorageManager {
    func buildStorageMetadata(fileType: String) -> StorageMetadata{
        let metadata = StorageMetadata()
        metadata.contentType = "image/\(fileType)"
        return metadata
    }
}
