//
//  GalleryViewModel.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 15/11/2564 BE.
//

import Foundation
import RxSwift

struct GalleryViewOutput {
    var onInitialList: PublishSubject<[ImageData]>
    var onInsertList: PublishSubject<[Int]>
    var onUpdateList: PublishSubject<[Int]>
    var onProcess: PublishSubject<(String, Float)>
    var onSuccess: PublishSubject<String>
}

class GalleryViewModel {
    
    var imageDataDisposeable: Disposable?
    
    var repository: Repository
    
    var limitData: LimitData?
    var imageList = [ImageData]()
    var imageListOffline = [ImageData]()
    var galleryViewOutput: GalleryViewOutput?
    
    
    init(_ output: GalleryViewOutput?) {
        self.repository = Repository.shared
        self.imageListOffline = []
        self.galleryViewOutput = output
    }
    
    func getImageData(){
        imageDataDisposeable = repository.getImageData().subscribe(onNext: { changeset, imageDataList, indexs in
            switch changeset {
            case .initial:
                self.imageList.append(contentsOf: imageDataList)
                self.imageListOffline = []
                self.galleryViewOutput?.onInitialList.onNext(imageDataList)
            case .insert:
                indexs.forEach { index in
                    self.imageList.append(imageDataList[index])
                    self.imageListOffline.append(imageDataList[index])
                }
                self.galleryViewOutput?.onInsertList.onNext(indexs)
            case .delete:
                break
            case .update:
                indexs.forEach { index in
                    self.imageList[index] = imageDataList[index]
                }
                self.galleryViewOutput?.onUpdateList.onNext(indexs)
            }
        })
    }
        
    func saveImageData(imageData: ImageData){
       _ = repository.saveImageData(imageData: imageData)
    }

    func syncImageUp(){
        imageListOffline = imageList.filter{ $0.syncDate == nil }
        uploadImage()
    }
    
    private func uploadImage(){
        guard imageListOffline.count > 0 else {
            return
        }
        
        print("imageListOffline: \(imageListOffline.count)")
        
        let imageData = imageListOffline.removeFirst()
        
        repository.uploadImage(imageData: imageData,
                               onSuccess: { id, remotePath in
                                imageData.remotePath = remotePath
                                imageData.syncDate = Date()
                                _ = self.repository.updateImageData(imageData: imageData)
                                self.uploadImage()
                               })
    }
    
    func subscribe(){
        getImageData()
        repository.subscribeUploadTask(onProcess: galleryViewOutput?.onProcess, onSuccess: galleryViewOutput?.onSuccess)
    }
    
    func unsubscribe(){
        imageDataDisposeable?.dispose()
        repository.unsubscribeUploadTask()
    }
    
    func generateFileName(fileType: String) -> String{
        guard let stringDate = DateTimeUtils.toString(from: Date()) else {
            fatalError("cann't convert date to string")
        }
        
        return "IMG_\(stringDate).\(fileType)"
    }
    
}
