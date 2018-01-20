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
    var lastNotification: Notification?
    var raspSerial: String!
    
    @IBAction func buttonTapped(button: UIButton!) {
        print("BUTTON TAPPED")
    }
    
    func adjustSectionView(withSectionName section: String!) {
        if let section = section {
            
            self.previewButton.layer.cornerRadius = 6
            self.previewButton.layer.borderColor = UIColor.black.cgColor
            self.previewButton.layer.borderWidth = 3
            self.previewButton.clipsToBounds = true
            
            self.raspSerial = FirebaseManager.sharedInstance.getRaspSerialFromPlace(place: section)
            
            GuardManager.sharedInstance.getNotifications(serial: self.raspSerial) { (notifications) in
                guard let notifications = notifications as? Notifications else { return }
                self.lastNotification = notifications.array.sorted(by: { (n1, n2) -> Bool in
                    n1.date > n2.date
                }).filter({ (notif) -> Bool in
                    return notif.type == "PIRSensor"
                }).first
                
                if let last = self.lastNotification {
                    self.informationLabel.text = "Last danger: \(last.date)"
                } else {
                    self.informationLabel.text = "No Danger!"
                }
            }
            
        } else {
            self.informationLabel.text = "No Guards Connected With You"
            self.previewButton.isHidden = true
        }
        
    }
}
