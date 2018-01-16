//
//  MovementDetectionView.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 30.12.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit

class MovementDetectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, SectionViewDisplayer, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var label: UILabel!
    
    var historyOfNotifications = [Notification]()
    var lastSelectedIndexPath: IndexPath?
    var raspSerial: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.button.layer.cornerRadius = 6
        self.button.layer.borderColor = UIColor.black.cgColor
        self.button.layer.borderWidth = 3
        self.button.clipsToBounds = true
        self.collectionView.backgroundColor = .clear
        self.collectionView.register(MovementDetectionCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.allowsMultipleSelection = false
    }
    
    func adjustSectionView(withSectionName section: String!) {
        self.label.text = "Guard [\(section!)] history:"
        
        self.raspSerial = FirebaseManager.sharedInstance.getRaspSerialFromPlace(place: section!)
        GuardManager.sharedInstance.getNotifications(serial: self.raspSerial) { (notifications) in
            guard let notifications = notifications as? Notifications else { return }
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            for notification in notifications.array {
                self.historyOfNotifications.append(notification)
            }
            self.collectionView.reloadData()
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return historyOfNotifications.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MovementDetectionCollectionViewCell
        cell.label.text = historyOfNotifications[indexPath.item].date
        
        
        if(cell.isSelected) {
            cell.backgroundColor = MovementDetectionCollectionViewCell.selectionColor
        } else {
            cell.backgroundColor = MovementDetectionCollectionViewCell.defaultColor
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MovementDetectionCollectionViewCell
        cell.backgroundColor = MovementDetectionCollectionViewCell.selectionColor
        
        if let lastSelectedIndexPath = lastSelectedIndexPath{
            collectionView.deselectItem(at: lastSelectedIndexPath, animated: false)
            //        if let cellLast = collectionView.cellForItem(at: lastSelectedIndexPath!) as? GuardianCollectionViewCell {
            //            cellLast.backgroundColor = cellLast.defaultColor
            //        }
            collectionView.reloadItems(at: [lastSelectedIndexPath])
        }
        lastSelectedIndexPath = indexPath
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 3
        let height = collectionView.frame.height - 10
        return CGSize(width: width, height: height)
    }
    
    @IBAction func buttonTapped(button: UIButton!) {
        let i = lastSelectedIndexPath!.item
        let alertController = UIAlertController(title: "Notification from \(historyOfNotifications[i].type)", message: historyOfNotifications[i].message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        if let parent = self.parentViewController {
            parent.present(alertController, animated: true, completion: nil)
        }
    }
    

}
