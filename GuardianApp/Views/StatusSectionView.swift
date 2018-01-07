//
//  StatusSectionView.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 27.11.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class StatusSectionView: UIView, SectionViewDisplayer {

    @IBOutlet weak var labelPlace: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    weak var owner: ViewController!
    var place: String!
    
    func adjustSectionView(withSectionName section: String!) {
        self.place = section!
        self.labelPlace.text = "Guardian [\(section!)]:"
        
        if(UserDefaults.standard.bool(forKey: "NoActive\(self.place)") == true) {
            self.labelStatus.text = "DISARMED"
            self.segmentedControl.selectedSegmentIndex = 1
        } else {
            self.labelStatus.text = "ARMED"
            self.segmentedControl.selectedSegmentIndex = 0
        }
        
    }
    
    @IBAction func segmentedControlAction(segment: UISegmentedControl!) {
        let option = segmentedControl.selectedSegmentIndex == 0 ? "activate" : "disactive"
        let alertController = UIAlertController(title: "Guard Status", message: "Are you sure you want to \(option) guard control?", preferredStyle: .alert)
        let actionYes = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.labelStatus.text = " \(self.segmentedControl.titleForSegment(at: self.segmentedControl.selectedSegmentIndex) ?? "ARMED")"
            
            if self.segmentedControl.selectedSegmentIndex == 1 { //disarmed
                UserDefaults.standard.set(true, forKey: "NoActive\(self.place)")
                UserDefaults.standard.synchronize()
                FirebaseManager.sharedInstance.stopListenForSensorUpdates(inPlace: self.place)
            } else {
                UserDefaults.standard.set(false, forKey: "NoActive\(self.place)")
                UserDefaults.standard.synchronize()
                let viewController = self.parentViewController! as! ViewController
                viewController.addFirebaseListener()
            }
        }
        let actionNo = UIAlertAction(title: "no", style: .cancel, handler: nil)
        alertController.addAction(actionYes)
        alertController.addAction(actionNo)
        let parentView = self.superview?.parentViewController
        if let parentView = parentView {
            parentView.present(alertController, animated: true, completion: nil)
        }
    }
    
    

}
