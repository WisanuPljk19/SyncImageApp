//
//  UIImage+.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 15/11/2564 BE.
//

import Foundation
import UIKit

extension UIImage {
    
    func reduce(percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let newSize = CGSize(width: size.width * percentage,
                            height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    func recursiveReduce(expectSize: Int, percentage: CGFloat, isOpaque: Bool = true) -> UIImage?{
        guard let data = jpegData(compressionQuality: 1.0) else {
            Log.info("reduce failure: data is nil")
           return nil
        }
        guard data.count > expectSize else {
            Log.info("reduce success: \(data.count)")
            return self
        }
        Log.info("image size: \(data.count)")
        return reduce(percentage: percentage, isOpaque: isOpaque)?
            .recursiveReduce(expectSize: expectSize,
                             percentage: percentage)
    }
    
}
