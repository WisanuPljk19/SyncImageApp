//
//  GalleryViewController.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 15/11/2564 BE.
//

import UIKit
import RxSwift

class GalleryViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var picker = UIImagePickerController();
    var alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
    
    var onProcess = PublishSubject<(String, Float)>()
    var onSuccess = PublishSubject<String>()
    
    lazy var viewModel = {
        return GalleryViewModel(GalleryViewOutput.init(onProcess: onProcess,
                                                       onSuccess: onSuccess))
    }()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.unsubscribeTask()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupReactive()
    }
    
    private func setupReactive(){
        onSuccess.asObservable().subscribe(onNext: { id in
            Log.info("onSuccess: \(id)")
        }).disposed(by: disposeBag)
        
        onProcess.asObservable().subscribe(onNext: { id, percentComplete in
            print("onSyncProgress: \(id), \(percentComplete)")
        }).disposed(by: disposeBag)
        
        viewModel.subscribeTask()
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
    
    @IBAction func addImage(_ button: UIButton){
        
        alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
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

}

extension GalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        DispatchQueue.main.async {
            
            var fileType: String
            if picker.sourceType == .photoLibrary,
               let fileURL = info[.imageURL] as? URL {
                fileType = fileURL.pathExtension
            }else {
                fileType = "jpeg"
            }
            
            guard let image = (info[.originalImage] as? UIImage)?
                    .recursiveReduce(expectSize: Constant.FILE_LIMIT_SIZE,
                                     percentage: 0.8,
                                     isOpaque: fileType.uppercased() == Constant.FILE_JPEG || fileType.uppercased() == Constant.FILE_HEIC) else{
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
            }
            
            let imageName = self.viewModel.generateFileName(fileType: fileType)
            
            guard let localPath = StorageManager.shared.saveImage(imageName: imageName, image: image) else {
                return
            }
            
            let imageData = ImageData(id: UUID().uuidString,
                                      name: imageName,
                                      localPath: localPath,
                                      contentType: "image/\(fileType)")
            
            self.viewModel.saveImageData(imageData: imageData)
            self.collectionView.insertItems(at: [IndexPath(item: self.viewModel.imageList.count - 1,
                                                      section: 0)])
        }
    }

}

extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.viewModel.imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageItem", for: indexPath) as! ImageItem
        cell.setItem(imageData: self.viewModel.imageList[indexPath.item])
        return cell
    }
}
