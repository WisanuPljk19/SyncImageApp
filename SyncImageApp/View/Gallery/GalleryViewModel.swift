//
//  GalleryViewModel.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 15/11/2564 BE.
//

import Foundation

protocol GalleryViewOutput {
    func onSuncAllSuccess()
    func onSyncSuccess(id: String)
    func onSyncFailure(id: String, desc: String)
    func onSyncProgress(id: String,  percentage: Double)
}

class GalleryViewModel {
    
    var limitData: LimitData?
    var imageList: [ImageData]
    var imageListOffline: [ImageData]
    var galleryViewOutput: GalleryViewOutput?
    
    init(_ output: GalleryViewOutput?) {
        self.imageList = []
        self.imageListOffline = []
        self.galleryViewOutput = output
    }

    func syncImageUp(){
        imageListOffline = imageList.filter{ $0.syncDate == nil }
        uploadImage()
    }
    
    private func uploadImage(){
        guard imageListOffline.count > 0 else {
            galleryViewOutput?.onSuncAllSuccess()
            return
        }
        
        let imageData = imageListOffline.removeFirst()
        
        FirebaseStorageManager.shared.uploadImage(imageData,
                                                  onProcess: galleryViewOutput?.onSyncProgress,
                                                  onSuccess: { id, remotePath in
                                                    imageData.remotePath = remotePath
                                                    imageData.syncDate = Date()
                                                    // commit
                                                    self.galleryViewOutput?.onSyncSuccess(id: id)
                                                    self.uploadImage()
                                                  }, onFailure: galleryViewOutput?.onSyncFailure)
    }
    
}
