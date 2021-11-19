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
import CoreServices

class GalleryViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var btnAdd: UIButton!
    @IBOutlet var btnSetting: UIButton!
    @IBOutlet var viewUploading: UIView!
    @IBOutlet var lbJpegCount: UILabel!
    @IBOutlet var lbJpegLimit: UILabel!
    @IBOutlet var lbPngCount: UILabel!
    @IBOutlet var lbPngLimit: UILabel!
    @IBOutlet var lbHeicCount: UILabel!
    @IBOutlet var lbHeicLimit: UILabel!
    
    var animationView = AnimationView()
    
    var imagePicker = UIImagePickerController()
    lazy var documentPicker: UIDocumentPickerViewController = {
        if #available(iOS 14.0, *) {
            return UIDocumentPickerViewController(forOpeningContentTypes: [.png,.jpeg, .heic], asCopy: true)
        } else {
            return UIDocumentPickerViewController(documentTypes: [String(kUTTypePNG), String(kUTTypeJPEG)], in: .import)
        }
    }()
    
    var alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
    
    var onSyncStatusChange = PublishSubject<SyncStatus>()
    var onGetLimitData = PublishSubject<LimitData>()
    var onInitialList = PublishSubject<[ImageData]>()
    var onInsertList = PublishSubject<[Int]>()
    var onUpdateList = PublishSubject<[Int]>()
    var onProcess = PublishSubject<(String, Float)>()
    var onSuccess = PublishSubject<String>()
    
    lazy var viewModel = {
        return GalleryViewModel(GalleryViewOutput.init(onSyncStatusChange: onSyncStatusChange,
                                                       onGetLimitData: onGetLimitData,
                                                       onInitialList: onInitialList,
                                                       onInsertList: onInsertList,
                                                       onUpdateList: onUpdateList))
    }()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupReactive()
        setupAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.unsubscribe()
        animationView.stop()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.subscribe()
        animationView.play()
    }
    
    private func setupAnimation(){
        animationView.frame = viewUploading.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.5
        viewUploading.addSubview(animationView)
        viewUploading.alpha = 0
    }
        
    private func setupView(){
        imagePicker.delegate = self
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        setupCollectionView()
        btnAdd.setImage(#imageLiteral(resourceName: "ic_add").withRenderingMode(.alwaysTemplate), for: .normal)
        btnAdd.tintColor = .white
        
        btnSetting.setImage(#imageLiteral(resourceName: "ic_setting").withRenderingMode(.alwaysTemplate), for: .normal)
        btnSetting.tintColor = .white
        self.setLimitLabel(imageType: nil)
    }
    
    private func setupCollectionView(){
        let size = (UIScreen.main.bounds.width - 24) / 3
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.itemSize = CGSize(width: size, height: size)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 8
        collectionView!.collectionViewLayout = layout
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
        
        onGetLimitData.asObserver().subscribe(onNext: { limitData in
            self.lbJpegLimit.text = "\(limitData.jpeg)"
            self.lbPngLimit.text = "\(limitData.png)"
            self.lbHeicLimit.text = "\(limitData.heic)"
        }).disposed(by: disposeBag)
        
        onInitialList.asObservable().subscribe(onNext: { _ in
            self.collectionView.reloadSections([0])
            self.setLimitLabel(imageType: nil)
        }).disposed(by: disposeBag)
        
        onInsertList.asObservable().subscribe(onNext: { indexs in
            self.collectionView.insertItems(at: indexs.map{ IndexPath(item:$0, section: 0) })
            indexs.forEach{ self.setLimitLabel(imageType: self.viewModel.imageList[$0].fileType) }
        }).disposed(by: disposeBag)
        
        onUpdateList.asObservable().subscribe(onNext: { indexs in
            self.collectionView.reloadItems(at: indexs.map{ IndexPath(item: $0, section: 0) })
            indexs.forEach{ self.setLimitLabel(imageType: self.viewModel.imageList[$0].fileType) }
        }).disposed(by: disposeBag)
    }
    
    private func setLimitLabel(imageType: String?){
        switch imageType?.uppercased() {
        case Constant.FILE_JPEG:
            setTextWithAnimation(uiLabel: self.lbJpegCount,
                                 text: "\(self.viewModel.calLimitCount(iamgeType: Constant.FILE_JPEG))")
        case Constant.FILE_PNG:
            setTextWithAnimation(uiLabel: self.lbPngCount,
                                 text: "\(self.viewModel.calLimitCount(iamgeType: Constant.FILE_PNG))")
        case Constant.FILE_HEIC:
            setTextWithAnimation(uiLabel: self.lbHeicCount,
                                 text: "\(self.viewModel.calLimitCount(iamgeType: Constant.FILE_HEIC))")
        default:
            setTextWithAnimation(uiLabel: self.lbJpegCount,
                                 text: "\(self.viewModel.calLimitCount(iamgeType: Constant.FILE_JPEG))")
            setTextWithAnimation(uiLabel: self.lbPngCount,
                                 text: "\(self.viewModel.calLimitCount(iamgeType: Constant.FILE_PNG))")
            setTextWithAnimation(uiLabel: self.lbHeicCount,
                                 text: "\(self.viewModel.calLimitCount(iamgeType: Constant.FILE_HEIC))")
        }
    }
    
    private func setTextWithAnimation(uiLabel: UILabel, text: String){
        UIView.transition(with: uiLabel,
                          duration: 0.25,
                          options: .transitionCrossDissolve,
                          animations: {
            uiLabel.text = text
        }, completion: nil)
    }
    
    private func openCamera(){
        alert.dismiss(animated: true, completion: nil)
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
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
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    private func openFile(){
        alert.dismiss(animated: true, completion: nil)
        self.present(documentPicker, animated: true, completion: nil)
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
        
        let fileAction = UIAlertAction(title: "File", style: .default){
            UIAlertAction in
            self.openFile()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
            UIAlertAction in
        }
        
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(fileAction)
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
    
    func validateImportImage(fileType: String) -> Bool{
        guard viewModel.validateLimitCount(imageType: fileType) else {
            Utils.presentBanner(title: "cann't import image",
                                subTitle: "Because count of offline files (\(fileType) has reached its limit.",
                                style: .warning)
            return false
        }
        return true
    }
    
    func processImageImport(image: UIImage, fileType: String){
        
        guard validateImportImage(fileType: fileType) else {
            return
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

extension GalleryViewController: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        controller.dismiss(animated: true) {
            guard let url = urls.first,
                  let image = UIImage(contentsOfFile: url.path) else {
                return
            }
            
            self.processImageImport(image: image, fileType: url.pathExtension.lowercased())
        }
    }
}

extension GalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: { self.storeImage(info: info) })
    }
    
    private func storeImage(info: [UIImagePickerController.InfoKey : Any]){
        var fileType: String
        if imagePicker.sourceType == .photoLibrary,
           let fileURL = info[.imageURL] as? URL {
            fileType = fileURL.pathExtension
        }else {
            fileType = "jpeg"
        }
        
        guard let image = info[.originalImage] as? UIImage else{
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }

        processImageImport(image: image, fileType: fileType)
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
