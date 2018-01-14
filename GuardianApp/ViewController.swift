//
//  ViewController.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 23.11.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Moya
import RxSwift
import Firebase


class ViewController: UIViewController {
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var camerasLabel: UILabel!
    
    
    var lastTouchedButton: UIButton?
    var lastVisitedPlace: String!
    var firstLayoutSubview = true
    @IBOutlet weak var warningButton: UIButton!
    var lastSelectedIndexPath: IndexPath?
    var loggedInUserMail: String!
    
    let disposeBag = DisposeBag()
    
    
    var serialToPlaceDict = Dictionary<String, String>()
    
    var guardianPlaces = ["Salon", "Hall", "Garage", "Bedroom", "Kitchen", "Outside", "Child Room", "Dining Room", "Tarrace"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (i, place) in guardianPlaces.enumerated() {
            serialToPlaceDict["rasp\(i)Serial"] = place
        }
        
        
        setupRx()
        
        self.lastVisitedPlace = guardianPlaces.first!
        addFirebaseListener()
        
//        for place in serialToPlaceDict.keys {
//            FirebaseManager.sharedInstance.addNewSensor(raspSerial: place, name: "TempSensor", place: place)
//            FirebaseManager.sharedInstance.addNewSensor(raspSerial: place, name: "COSensor", place: place)
//            FirebaseManager.sharedInstance.addNewSensor(raspSerial: place, name: "LPGSensor", place: place)
//            FirebaseManager.sharedInstance.addNewSensor(raspSerial: place, name: "FlameSensor", place: place)
//        }
        
        
        GuardManager.sharedInstance.fetchCameraAddress { (response) in
            print(response)
            guard let resp = response as? CameraResponseModel else { return }
            print(resp.cameraAddress!)
            DispatchQueue.main.async {
                let videoURL = URL(string: resp.cameraAddress!)
                let player = AVPlayer(url: videoURL!)
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = self.playerView.bounds
                self.playerView.layer.addSublayer(playerLayer)
                player.play()
            }
            //StreamManager.sharedInstance.playStreamOn(view: self.playerView)
            //StreamManager.sharedInstance.streamVideoFrom(urlString: resp.cameraAddress!)
        }
        
        lastVisitedPlace = guardianPlaces.first!
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1 ) {
            self.setupCustomView(sv: .WarningView)
        }
        
        setupNavBar()
        warningButton.imageView?.contentMode = .scaleAspectFit
        buttonSelectedSetup(button: warningButton)
        lastTouchedButton = warningButton
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = nil
        collectionView.allowsMultipleSelection = false
        collectionView.allowsSelection = true
        
        collectionView.setNeedsLayout()
        collectionView.layoutIfNeeded()
        
        //addLine()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("ViewWillApperar")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if(firstLayoutSubview) {
            self.collectionView.reloadData()
            collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .left)
            lastSelectedIndexPath =  IndexPath(item: 0, section: 0)
        }
        firstLayoutSubview = false
    }
    
    func setupRx() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.receivedNotification.asObservable().skip(1).distinctUntilChanged().subscribe(onNext: { (value) in
            let alertController = UIAlertController(title: "Danger!", message: "\(value)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    func addFirebaseListener() {
        FirebaseManager.sharedInstance.addSerialToPlaceDict(dict: serialToPlaceDict)
        FirebaseManager.sharedInstance.stopListenForAllSensorsUpdates()
        //listen only for active sensors
        FirebaseManager.sharedInstance.listenForAllSensorUpdates(){ (sensor: SensorModel) in
            var info = [String: String]()
            info["LPGSensor"] = "Detected high value of LPG in the air!\n"
            info["FlameSensor"] = "Detected Fire!\n"
            info["COSensor"] = "Detected high value of CO in the air!\n"
            info["TempSensor"] = "Detected high temperature!\n"
            
            var message = ""
            
            if(sensor.value > 0.3 && sensor.name != "TempSensor") {
                message += info[sensor.name]!
            } else if(sensor.value > 30) {
                message += info[sensor.name]!
            }
            
            if message.count > 0 {
                message.removeLast(1)
                self.presentAlertView(title: "DANGER in \(sensor.place!)!", info: message)
            }
        
        }
    }
    
    func presentAlertView(title: String, info: String) {
        let alertController = UIAlertController(title: title, message: info, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addLine() {
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1))
        lineView.backgroundColor = .yellow
        camerasLabel.addSubview(lineView)
        
        lineView.bottomAnchor.constraint(equalTo: camerasLabel.topAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        lineView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    func setupCustomView(sv: ViewsName) {
        contentView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        let customView = Bundle.main.loadNibNamed(sv.rawValue, owner: self, options: nil)!.first as! UIView
        customView.translatesAutoresizingMaskIntoConstraints = true
        customView.autoresizingMask = []
        customView.frame.origin = contentView.bounds.origin
        customView.isUserInteractionEnabled = true
        customView.bringSubview(toFront: contentView)
        customView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
        
        contentView.addSubview(customView)
        
        let displayerSection = customView as! SectionViewDisplayer
        displayerSection.adjustSectionView(withSectionName: lastVisitedPlace)
    }
    
    func setupNavBar() {
        
        let imageView = UIImageView(image: UIImage(named: "guardName"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let leftButtonWidth: CGFloat = 100
        let rightButtonWidth: CGFloat = 100
        let width = view.frame.width - leftButtonWidth - rightButtonWidth
        let offset = (rightButtonWidth - leftButtonWidth) / 2
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 22))
        container.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor, constant: -offset),
            imageView.widthAnchor.constraint(equalToConstant: width)
            ])
        
        self.navigationItem.titleView = container
    }
    
    func resetLastTouchedButton() {
        if let button = lastTouchedButton {
            button.layer.cornerRadius = 0
            button.layer.borderWidth = 0
            button.layer.borderColor = nil
        }
    }
    
    func buttonSelectedSetup(button: UIButton!){
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.black.cgColor
    }
    
    @IBAction func tempButtonTouched(button: UIButton!) {
        guard lastTouchedButton != button else { return }
        
        setupCustomView(sv: .SensorSectionView)
        checkButton(button: button)
    }
    
    @IBAction func movementButtonTouched(button: UIButton!) {
        guard lastTouchedButton != button else { return }
        
        setupCustomView(sv: .MovementDetectionView)
        checkButton(button: button)
    }
    
    @IBAction func warningButtonTouched(button: UIButton!) {
        guard lastTouchedButton != button else { return }
        
        setupCustomView(sv: .WarningView)
        checkButton(button: button)
    }
    
    @IBAction func liveStreamButtonTouched(button: UIButton!) {
        guard lastTouchedButton != button else { return }
        
        setupCustomView(sv: .LiveStreamSectionView)
        checkButton(button: button)
    }
    
    @IBAction func settingsButtonTouched(button: UIButton!) {
        guard lastTouchedButton != button else { return }
        
        setupCustomView(sv: .StatusSectionView)
        checkButton(button: button)
    }
    
    private func checkButton(button: UIButton!) {
        buttonSelectedSetup(button: button)
        resetLastTouchedButton()
        lastTouchedButton = button
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return guardianPlaces.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GuardianCollectionViewCell
        
        if(indexPath.row == guardianPlaces.count) {
            cell.imageView.image = UIImage(named: "add")
            cell.label.text = "New"
            cell.label.textColor = .red
        } else {
            cell.imageView.image = UIImage(named: "camera")
            cell.label.text = guardianPlaces[indexPath.row]
            cell.label.textColor = .black
        }
        
        if(cell.isSelected) {
            cell.backgroundColor = cell.selectionColor
        } else {
            cell.backgroundColor = cell.defaultColor
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GuardianCollectionViewCell
        //guard indexPath.row != guardianPlaces.count else { return }
        guard lastSelectedIndexPath!.item != indexPath.item else { return }
        
        if(indexPath.row == guardianPlaces.count) {
            let alertController = UIAlertController(title: "Add new guard", message: "Write guard serial", preferredStyle: .alert)
            
            alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
                textField.placeholder = "Serial number"
            })
            
            alertController.addAction(UIAlertAction(title: "SEND", style: .default, handler: { (action) in
                GuardManager.sharedInstance.addRaspberryToDatabase(serial: alertController.textFields![0].text!)
            }))
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            cell.backgroundColor = cell.selectionColor
            self.placeLabel.text = cell.label.text
            lastVisitedPlace = cell.label.text
            let subview = self.contentView.subviews.first! as! SectionViewDisplayer
            subview.adjustSectionView(withSectionName: cell.label.text)
            
            collectionView.deselectItem(at: lastSelectedIndexPath!, animated: false)
    //        if let cellLast = collectionView.cellForItem(at: lastSelectedIndexPath!) as? GuardianCollectionViewCell {
    //            cellLast.backgroundColor = cellLast.defaultColor
    //        }
            collectionView.reloadItems(at: [lastSelectedIndexPath!])
            lastSelectedIndexPath = indexPath
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height - 20
        let width = height / 0.9
        return CGSize(width: width, height: height)
    }
    
}
