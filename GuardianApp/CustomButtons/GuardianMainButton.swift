//
//  GuardianButton.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 23.11.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class GuardianMainButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 6
    @IBInspectable var backgroundButtonColor = UIColor.white {
        didSet {
            self.layer.backgroundColor = backgroundButtonColor.cgColor
        }
    }
    
    @IBInspectable var borderButtonColor: UIColor! = UIColor.gray {
        didSet {
            self.layer.borderColor = borderButtonColor.cgColor
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.backgroundColor =  backgroundButtonColor.cgColor
        self.layer.borderWidth = 3
        self.layer.borderColor = borderButtonColor.cgColor
        self.layer.cornerRadius = cornerRadius
    }
    
}

class GuardianSelectionButton: UIButton {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.imageEdgeInsets = UIEdgeInsetsMake(5,5,5,5)
    }
}

