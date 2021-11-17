//
//  UIImage+.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 15/11/2564 BE.
//

import Foundation
import UIKit

extension UIImage {
    
    func reduce(percentage: CGFloat, isOpaque: Bool) -> UIImage? {
        let newSize = CGSize(width: size.width * percentage,
                             height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        let newImage = UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        return newImage
    }
    
    func recursiveReduce(expectSize: Int, percentage: CGFloat, isOpaque: Bool, onComplete: ((Bool, UIImage?) -> Void)? = nil){
        DispatchQueue.global(qos: .userInteractive).async {
            guard let data = self.jpegData(compressionQuality: 1.0) else {
                Log.info("reduce failure: data is nil")
                onComplete?(false, nil)
                return
            }
            guard data.count > expectSize else {
                Log.info("reduce success: \(data.count)")
                onComplete?(true, self)
                return
            }
            Log.info("image size: \(data.count)")
            self.reduce(percentage: percentage, isOpaque: isOpaque)?
                .recursiveReduce(expectSize: expectSize,
                                 percentage: percentage,
                                 isOpaque: isOpaque,
                                 onComplete: onComplete)
        }
    }
}
