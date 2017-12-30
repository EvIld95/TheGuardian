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
    
    var guardianPlaces = ["Salon", "Hall", "Garage", "Bedroom", "Kitchen", "Outside", "Child Room", "Dining Room", "Tarrace"]
    override func viewDidLoad() {
        super.viewDidLoad()
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
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .left)
        lastSelectedIndexPath =  IndexPath(item: 0, section: 0)
        collectionView.setNeedsLayout()
        collectionView.layoutIfNeeded()
        collectionView.reloadItems(at: [lastSelectedIndexPath!])
        
        addLine()
        
        let videoURL = URL(string: "http://52.236.165.15:80/hls/camera.m3u8")
        let player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.playerView.bounds
        self.playerView.layer.addSublayer(playerLayer)
        player.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if(firstLayoutSubview) {
            self.collectionView.reloadData()
        }
        firstLayoutSubview = false
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
        
        
        buttonSelectedSetup(button: button)
        resetLastTouchedButton()
        lastTouchedButton = button
    }
    
    @IBAction func movementButtonTouched(button: UIButton!) {
        guard lastTouchedButton != button else { return }
        
        setupCustomView(sv: .MovementDetectionView)
        buttonSelectedSetup(button: button)
        resetLastTouchedButton()
        lastTouchedButton = button
    }
    
    @IBAction func warningButtonTouched(button: UIButton!) {
        guard lastTouchedButton != button else { return }
        
        setupCustomView(sv: .WarningView)
        buttonSelectedSetup(button: button)
        resetLastTouchedButton()
        lastTouchedButton = button
    }
    
    @IBAction func doorButtonTouched(button: UIButton!) {
        guard lastTouchedButton != button else { return }
        buttonSelectedSetup(button: button)
        resetLastTouchedButton()
        lastTouchedButton = button
    }
    
    @IBAction func settingsButtonTouched(button: UIButton!) {
        guard lastTouchedButton != button else { return }
        
        setupCustomView(sv: .StatusSectionView)
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
        return guardianPlaces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GuardianCollectionViewCell
        cell.imageView.image = UIImage(named: "camera")
        cell.label.text = guardianPlaces[indexPath.row]
        
        if(cell.isSelected) {
            cell.backgroundColor = cell.selectionColor
        } else {
            cell.backgroundColor = cell.defaultColor
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GuardianCollectionViewCell
        guard lastSelectedIndexPath!.item != indexPath.item else { return }
        
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
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height - 20
        let width = height / 1.2
        return CGSize(width: width, height: height)
    }
    
}
