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
    @IBOutlet var vUploaded: UICustomView!
    @IBOutlet var imgUploaded: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgUploaded.image = #imageLiteral(resourceName: "ic_upload").withRenderingMode(.alwaysTemplate)
        imgUploaded.tintColor = .white
    }
    
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
        vUploaded.isHidden = imageData.syncDate == nil
        lbFileType.text = imageData.fileType
    }
    
}
