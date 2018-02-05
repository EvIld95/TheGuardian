//
//  MovementDetectionView.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 30.12.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit
import FirebaseStorage
import MBProgressHUD
import AVFoundation

class MovementDetectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, SectionViewDisplayer, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var label: UILabel!
    
    var historyOfNotifications = [Notification]()
    var lastSelectedIndexPath: IndexPath?
    var raspSerial: String!
    var place : String!
    let sessionConfig = URLSessionConfiguration.default
    var session: URLSession!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.session = URLSession(configuration: sessionConfig)
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
        self.label.text = "Notifications history from \(section!)"
        self.place = section!
        self.raspSerial = FirebaseManager.sharedInstance.getRaspSerialFromPlace(place: section!)
        GuardManager.sharedInstance.getNotifications(serial: self.raspSerial) { (notifications) in
            guard let notifications = notifications as? Notifications else { return }
            self.historyOfNotifications.removeAll()
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            for notification in notifications.array.sorted(by: { (n1, n2) -> Bool in
                n1.date > n2.date
            }) {
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
        let notif = historyOfNotifications[indexPath.item].date
        cell.label.text = notif.dropLast(16).lowercased()
        
        
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
            collectionView.reloadItems(at: [lastSelectedIndexPath])
        }
        lastSelectedIndexPath = indexPath
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CGFloat(150)
        let height = collectionView.frame.height - 10
        return CGSize(width: width, height: height)
    }
    
    @IBAction func buttonTapped(button: UIButton!) {
        let i = lastSelectedIndexPath!.item
        let notification = historyOfNotifications[i]
        let alertController = UIAlertController(title: "Notification from \(self.place!) on \(historyOfNotifications[i].date.dropLast(16).lowercased())", message: historyOfNotifications[i].message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        
        if notification.videoURL != "" {
            let action2 = UIAlertAction(title: "Play", style: .default, handler: { (action) in
                let urlN = notification.videoURL
                let fileName = urlN.split(separator: "/")[4].replacingOccurrences(of: "avi", with: "mp4")
                print(fileName)
                let ref = Storage.storage().reference().child(self.raspSerial).child(String(fileName))
                let parent = self.parentViewController as! ViewController
                MBProgressHUD.showAdded(to: parent.view, animated: true)
                
                ref.downloadURL { url, error in
                if let url = url {
                    
                    let session = URLSession(configuration: self.sessionConfig)
                
                    let request = try! URLRequest(url: url, method: .get)
                    
                    // Create destination URL
                    let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
                    let destinationFileUrl = documentsUrl.appendingPathComponent("downloadedFile2.avi")
                    
                    let task = self.session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                        
                        if let tempLocalUrl = tempLocalUrl, error == nil {
                            let fileManager = FileManager.default
                            if fileManager.fileExists(atPath: destinationFileUrl.path) {
                                try! fileManager.removeItem(atPath: destinationFileUrl.path)
                                print("Removed file")
                            }
                            
                            do {
                                try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                            } catch (let writeError) {
                                print("Error creating a file \(destinationFileUrl) : \(writeError)")
                            }
                            
                            DispatchQueue.main.sync {
                                MBProgressHUD.hide(for: parent.view, animated: true)
                                let player = AVPlayer(url: destinationFileUrl)
                                let playerLayer = AVPlayerLayer(player: player)
                                playerLayer.frame = parent.playerView.bounds
                                parent.playerView.layer.sublayers?.forEach({ (layer) in
                                    layer.removeFromSuperlayer()
                                })
                                parent.playerView.layer.addSublayer(playerLayer)
                                player.play()
                            }
                            
                        } else {
                            print("Failure: %@", error!.localizedDescription);
                        }
                    }
                    task.resume()
                        
                }
                }
            })
            alertController.addAction(action2)
        }
        if let parent = self.parentViewController {
            parent.present(alertController, animated: true, completion: nil)
        }
    }
}
