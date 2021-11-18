//
//  UICircleView.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 16/11/2564 BE.
//

import UIKit

@IBDesignable final class UICustomView: UIView {
    
    @IBInspectable var borderColor: UIColor {
        set {
            layer.borderColor = newValue.cgColor
        }
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            clipsToBounds = true
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            clipsToBounds = true
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

}
