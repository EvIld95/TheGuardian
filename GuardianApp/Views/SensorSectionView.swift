//
//  SensorSectionView.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 31.12.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit
import M13ProgressSuite

class SensorSectionView: UIView, SectionViewDisplayer {
    @IBOutlet weak var titleLabel: UILabel!
    //@IBOutlet weak var sensor1Label: UILabel!
    //@IBOutlet weak var sensor2Label: UILabel!
    @IBOutlet weak var sensor3Label: UILabel!
    @IBOutlet weak var sensor4Label: UILabel!
    
    @IBOutlet weak var sensor1NameLabel: UILabel!
    @IBOutlet weak var sensor2NameLabel: UILabel!
    @IBOutlet weak var sensor3NameLabel: UILabel!
    @IBOutlet weak var sensor4NameLabel: UILabel!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    
    var progressBorderedBarView : M13ProgressViewBorderedBar!
    var progressBorderedBarView2 : M13ProgressViewBorderedBar!
    
    var raspSerial: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareProgressBars()
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        FirebaseManager.sharedInstance.stopListenForSensorUpdates(raspSerial: raspSerial)
        self.leftView.removeFromSuperview()
        self.rightView.removeFromSuperview()
    }
    
    func prepareProgressBars() {
        progressBorderedBarView = M13ProgressViewBorderedBar(frame: CGRect(x: 0, y: 0, width: self.leftView.frame.width, height: self.leftView.frame.height))
        progressBorderedBarView.cornerType = M13ProgressViewBorderedBarCornerTypeRounded
        progressBorderedBarView.cornerRadius = 8.0
        progressBorderedBarView.animationDuration = 1.5
        progressBorderedBarView.primaryColor = .green
        self.leftView.addSubview(progressBorderedBarView)
        progressBorderedBarView.secondaryColor = .orange
        progressBorderedBarView.translatesAutoresizingMaskIntoConstraints = false
        progressBorderedBarView.bottomAnchor.constraint(equalTo: self.leftView.bottomAnchor).isActive = true
        progressBorderedBarView.topAnchor.constraint(equalTo: self.leftView.topAnchor).isActive = true
        progressBorderedBarView.trailingAnchor.constraint(equalTo: self.leftView.trailingAnchor, constant: -20).isActive = true
        progressBorderedBarView.leadingAnchor.constraint(equalTo: self.leftView.leadingAnchor).isActive = true
        
        
        
        progressBorderedBarView2 = M13ProgressViewBorderedBar(frame: CGRect(x: 0, y: 0, width: self.rightView.frame.width, height: self.rightView.frame.height))
        progressBorderedBarView2.cornerType = M13ProgressViewBorderedBarCornerTypeRounded
        progressBorderedBarView2.cornerRadius = 8.0
        progressBorderedBarView2.animationDuration = 1.5
        progressBorderedBarView2.secondaryColor = .orange
        progressBorderedBarView2.primaryColor = UIColor(hue: 0.33 , saturation: 0.8, brightness: 1, alpha: 1)
        
        self.rightView.addSubview(progressBorderedBarView2)
        progressBorderedBarView2.translatesAutoresizingMaskIntoConstraints = false
        progressBorderedBarView2.bottomAnchor.constraint(equalTo: self.rightView.bottomAnchor).isActive = true
        progressBorderedBarView2.topAnchor.constraint(equalTo: self.rightView.topAnchor).isActive = true
        progressBorderedBarView2.trailingAnchor.constraint(equalTo: self.rightView.trailingAnchor, constant: -20).isActive = true
        progressBorderedBarView2.leadingAnchor.constraint(equalTo: self.rightView.leadingAnchor).isActive = true
        
        self.progressBorderedBarView.setProgress(0, animated: true)
        self.progressBorderedBarView2.setProgress(0, animated: true)
    }
    
    func adjustSectionView(withSectionName section: String!) {
        
        self.titleLabel.text = "Sensors Status from \(section!) "
        //self.place = section!
        print(FirebaseManager.sharedInstance.serialToPlaceDict!)
        self.raspSerial = FirebaseManager.sharedInstance.serialToPlaceDict!.filter { (key, value) -> Bool in
                return value == section!
            }.map { (key, value) -> String in
                return key }.first!
        
        FirebaseManager.sharedInstance.listenForSensorUpdates(raspSerial: raspSerial) { [unowned self] sensors in
            self.sensor1NameLabel.text = sensors[0].name
            self.sensor2NameLabel.text = sensors[2].name
            self.sensor3NameLabel.text = sensors[1].name
            self.sensor4NameLabel.text = sensors[3].name
            
            self.progressBorderedBarView.primaryColor = UIColor(hue: CGFloat(0.33 - (sensors[0].value * 0.33)), saturation: 1, brightness: 1, alpha: 1)
            self.progressBorderedBarView2.primaryColor = UIColor(hue: CGFloat(0.33 - (sensors[2].value * 0.33)), saturation: 1, brightness: 1, alpha: 1)
            
            self.progressBorderedBarView.setProgress(CGFloat(sensors[0].value), animated: true)
            self.progressBorderedBarView2.setProgress(CGFloat(sensors[2].value), animated: true)
            
            
            self.sensor3Label.text = sensors[1].value > 0 ? "HIGH VALUE!" : "OK"
            self.sensor3Label.textColor = sensors[1].value > 0 ? .red : .green
            self.sensor4Label.text = "\(sensors[3].value!)"
            self.sensor4Label.textColor = sensors[3].value > 30 ? .red : .green
        }
        
        func presentAlertView(title: String, info: String) {
            if let parent = self.parentViewController {
                let alertController = UIAlertController(title: title, message: info, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                parent.present(alertController, animated: true, completion: nil)
            }
            
        }
    }
    
}
