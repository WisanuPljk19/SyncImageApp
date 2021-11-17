//
//  LimitsViewController.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 17/11/2564 BE.
//

import UIKit

class LimitsViewController: UIViewController {
    
    @IBOutlet var btnSave: UIButton!
    @IBOutlet var tfJpeg: UITextField!
    @IBOutlet var tfPng: UITextField!
    @IBOutlet var tfHeic: UITextField!
    
    
    lazy var viewModel = {
        return LimitsViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView(){
        btnSave.setImage(#imageLiteral(resourceName: "ic_save").withRenderingMode(.alwaysTemplate),
                        for: .normal)
        btnSave.tintColor = .white
        tfJpeg.text = "\(viewModel.limitData.jpeg)"
        tfPng.text = "\(viewModel.limitData.png)"
        tfHeic.text = "\(viewModel.limitData.heic)"
    }
    
    @IBAction func savePress(_ sender: Any) {
    }
    
    
}
