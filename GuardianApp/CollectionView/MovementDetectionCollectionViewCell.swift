//
//  MovementDetectionCollectionViewCell.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 30.12.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit

@IBDesignable
class MovementDetectionCollectionViewCell: UICollectionViewCell {
    var label: UILabel = {
        let lab = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        lab.textAlignment = .center
        lab.translatesAutoresizingMaskIntoConstraints = false
        return lab
    }()
    
    static var defaultColor = UIColor.yellow
    static var selectionColor = UIColor.red
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 3
        self.layer.cornerRadius = 6
    }
}

