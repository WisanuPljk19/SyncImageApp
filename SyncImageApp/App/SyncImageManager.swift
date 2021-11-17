//
//  SyncImageManager.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 17/11/2564 BE.
//

import Foundation
import RxSwift

final class SyncImageManager {
    
    static let shared = SyncImageManager()

    private var disposeBag = DisposeBag()
    private var repository: Repository
    private var imageListOffline = [ImageData]()
    private var isProcessing = false
    
    private init() {
        self.repository = Repository.shared
    }
    
    func sync(){
        getImageData()
        uploadImage()
    }
    
    func getImageData(){
        repository.getImageData().asObservable().subscribe(onNext: { changeset, imageDataList, indexs in
            switch changeset {
            case .initial:
                self.imageListOffline = imageDataList.filter{ $0.syncDate == nil }
            case .insert:
                indexs.forEach { index in
                    self.imageListOffline.append(imageDataList[index])
                }
            default:
                break
            }
            if !self.isProcessing {
                self.uploadImage()
            }
        }).disposed(by: disposeBag)
    }
    
    private func uploadImage(){
        guard imageListOffline.count > 0 else {
            Log.info("stop processing")
            isProcessing = false
            return
        }
        Log.info("start processing")
        isProcessing = true
        let imageData = imageListOffline.removeFirst()

        repository.uploadImage(imageData: imageData,
                               onSuccess: { id, remotePath in
                                imageData.remotePath = remotePath
                                imageData.syncDate = Date()
                                _ = self.repository.updateImageData(imageData: imageData)
                                self.uploadImage()
                               })
    }
    
}
