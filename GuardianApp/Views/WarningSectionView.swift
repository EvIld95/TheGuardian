//
//  WarningSectionView.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 25.11.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit

class WarningSectionView: UIView, SectionViewDisplayer {

    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var informationLabel: UILabel!
    
    @IBAction func buttonTapped(button: UIButton!) {
        print("BUTTON TAPPED")
    }
    
    func adjustSectionView(withSectionName section: String!) {
        if let section = section {
            self.informationLabel.text = "Last danger in \(section): \(Date().description)"
            self.previewButton.layer.cornerRadius = 6
            self.previewButton.layer.borderColor = UIColor.black.cgColor
            self.previewButton.layer.borderWidth = 3
            self.previewButton.clipsToBounds = true
        } else {
            self.informationLabel.text = "No Guards Connected With You"
            self.previewButton.isHidden = true
        }
    }
}
