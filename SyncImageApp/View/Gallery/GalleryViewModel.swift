//
//  GalleryViewModel.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 15/11/2564 BE.
//

import Foundation
import RxSwift

struct GalleryViewOutput {
    var onProcess: PublishSubject<(String, Float)>
    var onSuccess: PublishSubject<String>
}

class GalleryViewModel {
    
    var repository: Repository
    
    var limitData: LimitData?
    var imageList: [ImageData]
    var imageListOffline: [ImageData]
    var galleryViewOutput: GalleryViewOutput?
    
    
    init(_ output: GalleryViewOutput?) {
        self.repository = Repository.shared
        self.imageList = repository.getImageEntity()
        self.imageListOffline = []
        self.galleryViewOutput = output
    }
        
    func saveImageData(imageData: ImageData){
        if repository.saveImageData(imageData: imageData){
            imageList.append(imageData)
        }
    }

    func syncImageUp(){
        imageListOffline = imageList.filter{ $0.syncDate == nil }
        uploadImage()
    }
    
    private func uploadImage(){
        guard imageListOffline.count > 0 else {
//            galleryViewOutput?.onSuncAllSuccess()
            return
        }
        
        let imageData = imageListOffline.removeFirst()
        
        repository.uploadImage(imageData: imageData,
                               onSuccess: { id, remotePath in
                                imageData.remotePath = remotePath
                                imageData.syncDate = Date()
                                if self.repository.updateImageData(imageData: imageData) {
//                                    self.galleryViewOutput?.onSyncSuccess(id: id)
                                }
                                self.uploadImage()
                               })
    }
    
    func subscribeTask(){
        repository.subscribeUploadTask(onProcess: galleryViewOutput?.onProcess, onSuccess: galleryViewOutput?.onSuccess)
    }
    
    func unsubscribeTask(){
        repository.unsubscribeUploadTask()
    }
    
    func generateFileName(fileType: String) -> String{
        guard let stringDate = DateTimeUtils.toString(from: Date()) else {
            fatalError("cann't convert date to string")
        }
        
        return "IMG_\(stringDate).\(fileType)"
    }
    
}
