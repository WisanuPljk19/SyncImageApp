//
//  ImageItem.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 16/11/2564 BE.
//

import UIKit
import Kingfisher

class ImageItem: UICollectionViewCell {
    
    @IBOutlet var lbFileType: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var icSync: UICustomView!
    
    func setItem(imageData: ImageData) {
        if let url = Utils.getDocumentDir()?.appendingPathComponent(imageData.localPath) {
            KF.url(url)
                .placeholder(#imageLiteral(resourceName: "ic_image"))
                .loadDiskFileSynchronously()
                .cacheMemoryOnly()
                .fade(duration: 0.25)
                .set(to: self.imageView)
        }else {
            self.imageView.image = #imageLiteral(resourceName: "ic_image")
        }
        icSync.isHidden = imageData.syncDate != nil
        lbFileType.text = imageData.contentType
    }
    
}
