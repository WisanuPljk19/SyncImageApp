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

enum SyncStatus {
    case waitNetwork
    case uploading
    case done
}

final class SyncImageManager {
    
    static let shared = SyncImageManager()
    private var repository: Repository
    
    private var disposeBag = DisposeBag()
    
    private var imageListOffline = [ImageData]()
    var syncStatusSubject = BehaviorSubject<SyncStatus>.init(value: .done)
    let reachability: Reachability! = try? Reachability()
    
    private init() {
        self.repository = Repository.shared
        try? reachability.startNotifier()
    }
    
    func subscribeNetwork(){
        reachability.rx.isReachable.subscribe(onNext: { isReachable in
            if isReachable && self.imageListOffline.count > 0,
               let syncStatus = try? self.syncStatusSubject.value(), syncStatus != .uploading {
                self.uploadImage()
            }
        }).disposed(by: disposeBag)
    }
    
    func sync(){
        subscribeNetwork()
        getImageData()
    }

    private func isNetworkReachable() -> Bool{
        return reachability.connection != .unavailable
    }
    
    private func changeSyncStatus(status: SyncStatus){
        if let syncStatus = try? self.syncStatusSubject.value(), syncStatus != status {
            syncStatusSubject.onNext(status)
        }
    }
    
    private func getImageData(){
        repository.getImageData().asObservable().subscribe(onNext: { changeset, imageDataList, indexs in
            switch changeset {
            case .initial:
                self.imageListOffline = imageDataList.filter{ $0.syncDate == nil }
            case .insert:
                indexs.forEach { index in
                    self.imageListOffline.append(imageDataList[index])
                }
            default:
                return
            }
            if let syncStatus = try? self.syncStatusSubject.value(), syncStatus != .uploading {
                self.uploadImage()
            }
        }).disposed(by: disposeBag)
    }
    
    private func uploadImage(){
        
        guard imageListOffline.count > 0 else {
            Log.info("stop processing list clear")
            changeSyncStatus(status: .done)
            return
        }
        
        guard isNetworkReachable() else {
            Log.info("stop processing wait network")
            changeSyncStatus(status: .waitNetwork)
            return
        }
        
        Log.info("start processing")
        changeSyncStatus(status: .uploading)
        
        repository.uploadImage(imageData: imageListOffline[0],
                               onSuccess: { id, remotePath in
            let imageData = self.imageListOffline.removeFirst()
            imageData.remotePath = remotePath
            imageData.syncDate = Date()
            _ = self.repository.updateImageData(imageData: imageData)
            self.uploadImage()
        }, onFailure: { storageError in
            switch storageError {
            case .retryLimitExceeded:
                Log.info("uploadImage failure cann't connect internet")
            default:
                Log.error("uploadImage failure: \(storageError.debugDescription)")
            }
            self.uploadImage()
        })
    }
}
