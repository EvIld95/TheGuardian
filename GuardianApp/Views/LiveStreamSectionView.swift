//
//  LiveStreamSectionView.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 31.12.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit

class LiveStreamSectionView: UIView, SectionViewDisplayer {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var info1Label: UILabel!
    @IBOutlet weak var info2Label: UILabel!
    
    func adjustSectionView(withSectionName section: String!) {
        self.titleLabel.text = "Live stream from \(section!)"
        self.info1Label.text = "Info1"
        self.info2Label.text = "Info2"
    }
    
}
