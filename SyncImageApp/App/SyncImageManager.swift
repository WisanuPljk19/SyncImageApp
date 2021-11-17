//
//  SyncImageManager.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 17/11/2564 BE.
//

import Foundation
import RxSwift
import RxCocoa
import RxReachability
import Reachability

final class SyncImageManager {
    
    static let shared = SyncImageManager()
    private var repository: Repository
    
    private var disposeBag = DisposeBag()
    
    private var imageListOffline = [ImageData]()
    private var isProcessing = false
    private let reachability: Reachability! = try? Reachability()
    
    private init() {
        self.repository = Repository.shared
        try? reachability.startNotifier()
        subscribeNetwork()
    }
    
    func subscribeNetwork(){
        reachability.rx.isReachable.subscribe(onNext: { isReachable in
            Log.info("internet status: \(isReachable)")
        }).disposed(by: disposeBag)
    }
    
    func sync(){
        getImageData()
//        uploadImage()
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
//                self.uploadImage()
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
        
        repository.uploadImage(imageData: imageListOffline[0],
                               onSuccess: { id, remotePath in
                                let imageData = self.imageListOffline.removeFirst()
                                imageData.remotePath = remotePath
                                imageData.syncDate = Date()
                                _ = self.repository.updateImageData(imageData: imageData)
                                self.uploadImage()
                               },
                               onFailure: { storageError in
                                switch storageError {
                                case .retryLimitExceeded:
                                    Log.info("uploadImage failure cann't connect internet")
                                default:
                                    Log.error("uploadImage failure: \(storageError.debugDescription)")
                                }
                               })
    }
    
}
