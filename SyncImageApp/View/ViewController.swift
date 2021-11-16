//
//  ViewController.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 15/11/2564 BE.
//

import UIKit

class ViewController: UIViewController {
    
    var picker = UIImagePickerController();
    var alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
    
    lazy var viewModel = {
        return GalleryViewModel(self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let cameraAction = UIAlertAction(title: "Camera", style: .default){
            UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: .default){
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
            UIAlertAction in
        }
        
        // Add the actions
        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        alert.dismiss(animated: true, completion: nil)
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        } else {
            let alertController: UIAlertController = {
                let controller = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                controller.addAction(action)
                return controller
            }()
            self.present(alertController, animated: true)
        }
    }
    func openGallery(){
        alert.dismiss(animated: true, completion: nil)
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}

extension ViewController: GalleryViewOutput {
    func onSuncAllSuccess() {
        Log.info("onSuncAllSuccess")
    }
    
    func onSyncSuccess(id: String) {
        Log.info("onSyncSuccess: \(id)")
    }
    
    func onSyncFailure(id: String, desc: String) {
        Log.info("onSyncFailure: \(id), \(desc)")
    }
    
    func onSyncProgress(id: String, percentage: Double) {
        Log.info("onSyncProgress: \(id), \(percentage)")
    }
    

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        /**
         /Users/wisanupaunglumjeak/Library/Developer/CoreSimulator/Devices/729E1336-D65B-414F-80D3-F6BBB36E27B8/data/Containers/Data/Application/0B3893AF-A105-40B3-A89F-F5F40F8CFCBA/Documents/
        */
        guard let image = (info[.originalImage] as? UIImage)?
                .recursiveReduce(expectSize: Constant.FILE_LIMIT_SIZE,
                                 percentage: 0.8) else{
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        let fileURL = info[.imageURL] as? URL
        
        let imageName = viewModel.generateFileName(fileType: fileURL?.pathExtension ?? "jpeg")
        
        guard let localPath = StorageManager.shared.saveImage(imageName: imageName, image: image) else {
            return
        }
        
        let imageData = ImageData(id: UUID().uuidString,
                                  name: imageName,
                                  localPath: localPath.absoluteString,
                                  contentType: "image/\(fileURL?.pathExtension ?? "jpeg")")
        
        viewModel.saveImageData(imageData: imageData)
        viewModel.syncImageUp()
    }
}
