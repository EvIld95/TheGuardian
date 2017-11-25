//
//  GuardianCollectionViewCell.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 24.11.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit

@IBDesignable
class GuardianCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    @IBInspectable var defaultColor: UIColor!
    @IBInspectable var selectionColor: UIColor!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 3
        self.layer.cornerRadius = 6
    }

}
