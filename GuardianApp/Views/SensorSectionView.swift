//
//  SensorSectionView.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 31.12.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit

class SensorSectionView: UIView, SectionViewDisplayer {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sensor1Label: UILabel!
    @IBOutlet weak var sensor2Label: UILabel!
    @IBOutlet weak var sensor3Label: UILabel!
    
    func adjustSectionView(withSectionName section: String!) {
        self.titleLabel.text = "Sensors Status from \(section!)"
        self.sensor1Label.text = "Value sensor1"
        self.sensor2Label.text = "Value sensor2"
        self.sensor3Label.text = "Value sensor3"
    }
    
}
