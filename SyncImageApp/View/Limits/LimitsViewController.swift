//
//  LimitsViewController.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 17/11/2564 BE.
//

import UIKit
import RxCocoa
import RxSwift

class LimitsViewController: UIViewController {
    
    @IBOutlet var lbApp: UILabel!
    @IBOutlet var btnSave: UIButton!
    @IBOutlet var tfJpeg: UITextField!
    @IBOutlet var tfPng: UITextField!
    @IBOutlet var tfHeic: UITextField!
    
    var disposeBag = DisposeBag()
    
    lazy var viewModel = {
        return LimitsViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupReactive()
    }
    
    private func setupView(){
        btnSave.setImage(#imageLiteral(resourceName: "ic_save").withRenderingMode(.alwaysTemplate),
                        for: .normal)
        btnSave.tintColor = .white
        tfJpeg.text = "\(viewModel.limitData.jpeg)"
        tfPng.text = "\(viewModel.limitData.png)"
        tfHeic.text = "\(viewModel.limitData.heic)"
    }
    
    private func setupReactive(){
        
        SyncImageManager.shared.reachability.rx.isReachable.subscribe(onNext: { isReachable in
            Log.info("internet status: \(isReachable)")
            self.lbApp.text = "\(isReachable)"
        }).disposed(by: disposeBag)
        tfJpeg
            .rx
            .controlEvent(.editingChanged)
            .withLatestFrom(tfJpeg.rx.text.orEmpty)
            .subscribe(onNext: { text in
                self.viewModel.limitData.jpeg = Int(text) ?? 0
            }).disposed(by: disposeBag)
        
        tfPng
            .rx
            .controlEvent(.editingChanged)
            .withLatestFrom(tfPng.rx.text.orEmpty)
            .subscribe(onNext: { text in
                self.viewModel.limitData.png = Int(text) ?? 0
            }).disposed(by: disposeBag)
        
        tfHeic
            .rx
            .controlEvent(.editingChanged)
            .withLatestFrom(tfHeic.rx.text.orEmpty)
            .subscribe(onNext: { text in
                self.viewModel.limitData.heic = Int(text) ?? 0
            }).disposed(by: disposeBag)
    }
    
    @IBAction func savePress(_ sender: Any) {
        let (isPass, message) = viewModel.validateLimitData()
        guard isPass else {
            Log.info("save limit invalidate: \(message!)")
            return
        }
        viewModel.updateLimits()
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
