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
    
    func adjustSectionView(withSectionName section: String!) {
        self.labelPlace.text = "Guardian [\(section!)]:"
        self.labelStatus.text = " \(segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex) ?? "ARMED")"
    }
    
    @IBAction func segmentedControlAction(segment: UISegmentedControl!) {
        let option = segmentedControl.selectedSegmentIndex == 0 ? "activate" : "disactive"
        let alertController = UIAlertController(title: "Guard Status", message: "Are you sure you want to \(option) guard control?", preferredStyle: .alert)
        let actionYes = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.labelStatus.text = " \(self.segmentedControl.titleForSegment(at: self.segmentedControl.selectedSegmentIndex) ?? "ARMED")"
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
