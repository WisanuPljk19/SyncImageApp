//
//  GalleryViewModel.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 15/11/2564 BE.
//

import Foundation
import RxCocoa
import RxSwift
import RxRelay

struct GalleryViewOutput {
    var onSyncStatusChange: PublishSubject<SyncStatus>
    var onGetLimitData: PublishSubject<LimitData>
    var onInitialList: PublishSubject<[ImageData]>
    var onInsertList: PublishSubject<[Int]>
    var onUpdateList: PublishSubject<[Int]>
}

class GalleryViewModel {
    
    var imageDataDisposeable: Disposable?
    var limitDataDisposeable: Disposable?
    var uploadingDisposeable: Disposable?
    
    let syncImageManager: SyncImageManager
    let repository: Repository
    let galleryViewOutput: GalleryViewOutput?
    
    var limitData: LimitData!
    var imageList = [ImageData]()

    
    
    init(_ output: GalleryViewOutput?) {
        self.syncImageManager = SyncImageManager.shared
        self.repository = Repository.shared
        self.galleryViewOutput = output
    }
    
    func subscribeLimitData(){
        limitDataDisposeable = repository.subscribeLimitData().subscribe(onNext: { limitData in
            self.limitData = limitData
            self.galleryViewOutput?.onGetLimitData.onNext(limitData)
        })
    }
    
    func subscribeImageData(){
        imageDataDisposeable = repository.getImageData().subscribe(onNext: { changeset, imageDataList, indexs in
            switch changeset {
            case .initial:
                guard self.imageList.count != imageDataList.count else {
                    return
                }
                self.imageList = imageDataList
                self.galleryViewOutput?.onInitialList.onNext(imageDataList)
            case .insert:
                indexs.forEach { index in
                    self.imageList.append(imageDataList[index])
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
    
    func subscribe(){
        if let onSyncStatusChange = galleryViewOutput?.onSyncStatusChange {
            uploadingDisposeable = syncImageManager.syncStatusSubject.bind(to: onSyncStatusChange)
        }
        subscribeLimitData()
        subscribeImageData()
    }
    
    func unsubscribe(){
        limitDataDisposeable?.dispose()
        uploadingDisposeable?.dispose()
        imageDataDisposeable?.dispose()
    }
    
    func generateFileName(fileType: String) -> String{
        guard let stringDate = DateTimeUtils.toString(from: Date()) else {
            fatalError("cann't convert date to string")
        }
        
        return "IMG_\(stringDate).\(fileType)"
    }
    
    func calLimitCount(iamgeType: String) -> Int{
        return imageList.filter{ $0.fileType.uppercased() == iamgeType.uppercased() && $0.syncDate == nil }.count
    }

    func validateLimitCount(imageType: String) -> Bool{
        var limit: Int
        switch imageType.uppercased(){
        case Constant.FILE_JPEG:
            limit = limitData.jpeg
        case Constant.FILE_PNG:
            limit = limitData.png
        case Constant.FILE_HEIC:
            limit = limitData.heic
        default:
            fatalError("invalid image type")
        }
        return calLimitCount(iamgeType: imageType) - limit < 0
    }
}
