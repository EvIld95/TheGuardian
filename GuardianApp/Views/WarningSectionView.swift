//
//  WarningSectionView.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 25.11.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//
import FirebaseStorage
import UIKit
import AVFoundation
import MBProgressHUD

class WarningSectionView: UIView, SectionViewDisplayer {

    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var informationLabel: UILabel!
    var lastNotification: Notification?
    var raspSerial: String!
    
    @IBAction func buttonTapped(button: UIButton!) {

//        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "film", ofType:"avi")!)
//        let player = AVPlayer(url: url)
//        let parent = self.parentViewController as! ViewController
//        let playerLayer = AVPlayerLayer(player: player)
//        playerLayer.frame = parent.playerView.bounds
//        parent.playerView.layer.sublayers?.forEach({ (layer) in
//            layer.removeFromSuperlayer()
//        })
//        parent.playerView.layer.addSublayer(playerLayer)
//        player.play()
        
        if let notification = lastNotification {
            let urlN = notification.videoURL//"https://firebasestorage.googleapis.com/v0/b/guardapp-ac65a.appspot.com/o/test%2F1516534473580375.avi?alt=media&token=11ec9b23-b268-4b3b-a75c-b4070aa108af"
            let fileName = urlN.split(separator: "/")[4].replacingOccurrences(of: "avi", with: "mp4")
            print(fileName)
            let ref = Storage.storage().reference().child(self.raspSerial).child(fileName)
            let parent = self.parentViewController as! ViewController
            MBProgressHUD.showAdded(to: parent.playerView, animated: true)
            
            ref.downloadURL { url, error in
                if let _ = error {
                    // Handle any errors
                } else {
                    print(url)
                    let sessionConfig = URLSessionConfiguration.default
                    let session = URLSession(configuration: sessionConfig)
                    let request = try! URLRequest(url: url!, method: .get)
                    
                    // Create destination URL
                    let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
                    let destinationFileUrl = documentsUrl.appendingPathComponent("downloadedFile2.avi")
                    
                    let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                        if let tempLocalUrl = tempLocalUrl, error == nil {
                            
                            do {
                                try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                            } catch (let writeError) {
                                print("Error creating a file \(destinationFileUrl) : \(writeError)")
                            }
                            
                            DispatchQueue.main.async {
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
                            print("Failure: %@", error?.localizedDescription);
                        }
                    }
                    task.resume()
                
                }
            }
        }
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
