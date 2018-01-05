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
    
    
    @IBOutlet weak var sensor1NameLabel: UILabel!
    @IBOutlet weak var sensor2NameLabel: UILabel!
    @IBOutlet weak var sensor3NameLabel: UILabel!
    
    var place: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        FirebaseManager.sharedInstance.stopListenForSensorUpdates(raspSerial: place)
    }
    
    func adjustSectionView(withSectionName section: String!) {
        
        self.titleLabel.text = "Sensors Status from \(section!) "
        self.place = section!
        FirebaseManager.sharedInstance.listenForSensorUpdates(raspSerial: section!) { sensors in
            self.sensor1NameLabel.text = sensors[0].name
            self.sensor2NameLabel.text = sensors[1].name
            self.sensor3NameLabel.text = sensors[2].name
            
            self.sensor1Label.text = "\(sensors[0].value ?? 0.0)"
            self.sensor2Label.text = "\(sensors[1].value ?? 0.0)"
            self.sensor3Label.text = "\(sensors[2].value ?? 0.0)"
            print(sensors)
        }
    }
    
}
