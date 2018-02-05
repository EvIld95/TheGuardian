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
import MBProgressHUD


class ViewController: UIViewController {
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var camerasLabel: UILabel!
    @IBOutlet weak var buttonSensors: UIButton!
    @IBOutlet weak var buttonHistoryNotification: UIButton!
    @IBOutlet weak var buttonStream: UIButton!
    @IBOutlet weak var buttonSetting: UIButton!
    
    
    var lastTouchedButton: UIButton?
    var lastVisitedPlace: String!
    var firstLayoutSubview = true
    @IBOutlet weak var warningButton: UIButton!
    var lastSelectedIndexPath: IndexPath?
    var loggedInUserMail: String!
    var firstRun = false
    let disposeBag = DisposeBag()
    
    
    var serialToPlaceDict = Variable<Dictionary<String, String>>(Dictionary<String, String>())
    var sortedKeys = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        setupRx()
        GuardManager.sharedInstance.getMyRaspberries { (response) in
            guard let rasp = response as? RaspberriesModel else { return }
            
            self.updateRaspberries(rasp: rasp)
            MBProgressHUD.hide(for: self.view, animated: true)
            self.collectionView.reloadData()
            self.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .left)
            self.lastSelectedIndexPath =  IndexPath(item: 0, section: 0)
            self.addFirebaseListener()
            self.setupCustomView(sv: .WarningView)
            StreamManager.sharedInstance.playStreamOn(view: self.playerView)
            if let firstKey = self.sortedKeys.first {
                StreamManager.sharedInstance.streamVideoFrom(urlString: "http://52.236.165.15:80/hls/\(firstKey).m3u8")
            }
        }
        
        GuardManager.sharedInstance.updateFCMToken(){print("Token updated")}
        
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
        
//        let gesture = UITapGestureRecognizer(target: self.playerView, action: #selector(touchedView))
//        gesture.cancelsTouchesInView = true
//        self.view.addGestureRecognizer(gesture)
        
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func touchedView() {
        hideKeyboard()
    }
    
    func updateRaspberries(rasp: RaspberriesModel) {
        for (raspSerial, name) in rasp.raspberries {
            self.serialToPlaceDict.value[raspSerial] = name
        }
        
        self.sortedKeys = self.serialToPlaceDict.value.keys.sorted(by: { (k1, k2) -> Bool in
            return k1 < k2
        })
        
        if let firstKey = self.sortedKeys.first {
            self.lastVisitedPlace = self.serialToPlaceDict.value[firstKey]
        }
    }
    
    func setupRx() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.receivedNotification.asObservable().skip(1).distinctUntilChanged().subscribe(onNext: { (value) in
            let alertController = UIAlertController(title: "Danger!", message: "\(value)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        self.serialToPlaceDict.asObservable().subscribe(onNext: { (dict) in
            if dict.count == 0 {
                self.buttonStream.isEnabled = false
                self.buttonSensors.isEnabled = false
                self.buttonSetting.isEnabled = false
                self.buttonHistoryNotification.isEnabled = false
            } else {
                self.buttonStream.isEnabled = true
                self.buttonSensors.isEnabled = true
                self.buttonSetting.isEnabled = true
                self.buttonHistoryNotification.isEnabled = true
            }
        }).disposed(by: disposeBag)
    }
    
    func addFirebaseListener() {
        FirebaseManager.sharedInstance.addSerialToPlaceDict(dict: serialToPlaceDict.value)
        FirebaseManager.sharedInstance.stopListenForAllSensorsUpdates()
        //listen only for active sensors
        FirebaseManager.sharedInstance.listenForAllSensorUpdates(){ (sensor: SensorModel) in
            var info = [String: String]()
            info["LPGSensor"] = "Detected high value of LPG in the air!\n"
            info["FlameSensor"] = "Detected Fire!\n"
            info["COSensor"] = "Detected high value of CO in the air!\n"
            info["TempSensor"] = "Detected high temperature!\n"
            
            var message = ""
            
            if(sensor.value > 0.35 && sensor.name != "TempSensor") {
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
        return serialToPlaceDict.value.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GuardianCollectionViewCell
        
        if(indexPath.row == serialToPlaceDict.value.count) {
            cell.imageView.image = UIImage(named: "add")
            cell.label.text = "New"
            cell.label.textColor = .red
        } else {
            cell.imageView.image = UIImage(named: "camera")
            cell.label.text = serialToPlaceDict.value[sortedKeys[indexPath.item]]!
            cell.label.textColor = .black
        }
        
        if(cell.isSelected ) {
            cell.backgroundColor = cell.selectionColor
        } else {
            cell.backgroundColor = cell.defaultColor
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GuardianCollectionViewCell

        guard lastSelectedIndexPath!.item != indexPath.item || indexPath.item == serialToPlaceDict.value.count else { return }
        
        if(indexPath.row == serialToPlaceDict.value.count) {
            let alertController = UIAlertController(title: "Add new guard", message: "Write guard serial", preferredStyle: .alert)
            
            alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
                textField.placeholder = "Serial number"
            })
            
            alertController.addAction(UIAlertAction(title: "SEND", style: .default, handler: { (action) in
                MBProgressHUD.showAdded(to: self.view, animated: true)
                GuardManager.sharedInstance.addRaspberryToDatabase(serial: alertController.textFields![0].text!) {
                    GuardManager.sharedInstance.getMyRaspberries { (response) in
                        guard let rasp = response as? RaspberriesModel else { return }
                        
                        self.updateRaspberries(rasp: rasp)
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.collectionView.reloadData()
                        self.addFirebaseListener()
                    }
                }
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            cell.backgroundColor = cell.selectionColor
            self.placeLabel.text = cell.label.text
            lastVisitedPlace = cell.label.text
            let subview = self.contentView.subviews.first! as! SectionViewDisplayer
            subview.adjustSectionView(withSectionName: cell.label.text)
            let key = sortedKeys[indexPath.row]
            StreamManager.sharedInstance.streamVideoFrom(urlString: "http://52.236.165.15:80/hls/\(key).m3u8")
            
            collectionView.deselectItem(at: lastSelectedIndexPath!, animated: false)
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
