//
//  GalleryViewController.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 15/11/2564 BE.
//

import UIKit
import RxCocoa
import RxSwift
import RxRealm
import Lottie

class GalleryViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var btnAdd: UIButton!
    @IBOutlet var btnSetting: UIButton!
    @IBOutlet var viewUploading: UIView!
    
    var animationView = AnimationView()
    
    var picker = UIImagePickerController();
    var alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
    
    var onSyncStatusChange = PublishSubject<SyncStatus>()
    var onInitialList = PublishSubject<[ImageData]>()
    var onInsertList = PublishSubject<[Int]>()
    var onUpdateList = PublishSubject<[Int]>()
    var onProcess = PublishSubject<(String, Float)>()
    var onSuccess = PublishSubject<String>()
    
    lazy var viewModel = {
        return GalleryViewModel(GalleryViewOutput.init(onSyncStatusChange: onSyncStatusChange,
                                                       onInitialList: onInitialList,
                                                       onInsertList: onInsertList,
                                                       onUpdateList: onUpdateList,
                                                       onProcess: onProcess,
                                                       onSuccess: onSuccess))
    }()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.unsubscribe()
        animationView.stop()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupReactive()
        animationView.play()
    }
    
    private func setupAnimation(){
//        animationView.animation = Animation.named("lottie-upload")
        animationView.frame = viewUploading.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.5
        viewUploading.addSubview(animationView)
        viewUploading.alpha = 0
    }
    
    private func setupView(){
        btnAdd.setImage(#imageLiteral(resourceName: "ic_add").withRenderingMode(.alwaysTemplate), for: .normal)
        btnAdd.tintColor = .white
        
        btnSetting.setImage(#imageLiteral(resourceName: "ic_setting").withRenderingMode(.alwaysTemplate), for: .normal)
        btnSetting.tintColor = .white
    }
    
    private func setupReactive(){
        
        onSyncStatusChange.subscribe(onNext: { syncStauts in
            switch syncStauts {
            case .uploading:
                self.animationView.animation = Animation.named("lottie-upload")
            case .waitNetwork:
                self.animationView.animation = Animation.named("lottie-offline")
            case .done:
                break
            }

            self.controlAnimatin(isShow: syncStauts != .done)
        }).disposed(by: disposeBag)
        
        onInitialList.asObservable().subscribe(onNext: { _ in
            self.collectionView.reloadSections([0])
        }).disposed(by: disposeBag)
        
        onInsertList.asObservable().subscribe(onNext: { indexs in
            self.collectionView.insertItems(at: indexs.map{ IndexPath(item:$0, section: 0) })
        }).disposed(by: disposeBag)
        
        onUpdateList.asObservable().subscribe(onNext: { indexs in
            self.collectionView.reloadItems(at: indexs.map{ IndexPath(item: $0, section: 0) })
        }).disposed(by: disposeBag)
        
        onSuccess.asObservable().subscribe(onNext: { id in
            Log.info("onSuccess: \(id)")
        }).disposed(by: disposeBag)
        
        onProcess.asObservable().subscribe(onNext: { id, percentComplete in
            print("onSyncProgress: \(id), \(percentComplete)")
        }).disposed(by: disposeBag)
        
        viewModel.subscribe()
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
    private func openGallery(){
        alert.dismiss(animated: true, completion: nil)
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
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

    private func controlAnimatin(isShow: Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            self.viewUploading.alpha = isShow ? 1 : 0
        }, completion: { isSuccess in
            if isShow {
                self.animationView.play()
            }else {
                self.animationView.stop()
            }
        })
    }
}

extension GalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        var fileType: String
        if picker.sourceType == .photoLibrary,
           let fileURL = info[.imageURL] as? URL {
            fileType = fileURL.pathExtension
        }else {
            fileType = "jpeg"
        }
        
        guard let image = info[.originalImage] as? UIImage else{
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }

        image.recursiveReduce(expectSize: Constant.FILE_LIMIT_SIZE,
                              percentage: 0.8,
                              isOpaque: fileType.uppercased() == Constant.FILE_JPEG || fileType.uppercased() == Constant.FILE_HEIC) { isSuccess, imageReduce in
            
            guard let imageReduce = imageReduce else {
                return
            }
            
            let imageName = self.viewModel.generateFileName(fileType: fileType)
            
            guard let localPath = StorageManager.shared.saveImage(imageName: imageName, image: imageReduce) else {
                return
            }
            let imageData = ImageData(id: UUID().uuidString,
                                  name: imageName,
                                  localPath: localPath,
                                  fileType: fileType)
            DispatchQueue.main.async {
                self.viewModel.saveImageData(imageData: imageData)
            }
        }
    }
}

extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.viewModel.imageList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageItem", for: indexPath) as! ImageItem
        cell.setItem(imageData: self.viewModel.imageList[indexPath.row])
        return cell
    }
}
