//
//  FileManager.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 16/11/2564 BE.
//

import Foundation
import UIKit

final class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {
        
    }
    
    func saveImage(imageName: String, image: UIImage) -> String? {
        
        guard let documentsDirectory = Utils.getDocumentDir() else {
            return nil
        }

        let fileName = imageName
        
        guard let data = image.jpegData(compressionQuality: 1) else {
            return nil
        }
        
        let imageDir = documentsDirectory.appendingPathComponent(Constant.DIR_IMAGE_BUCKET)
        
        if !FileManager.default.fileExists(atPath: imageDir.path) {
            do {
                try FileManager.default.createDirectory(atPath: imageDir.path,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        let fileURL = imageDir.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }
        return "\(Constant.DIR_IMAGE_BUCKET)/\(fileName)"
    }
    
}
