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
    
    
    var lastTouchedButton: UIButton?
    @IBOutlet weak var warningButton: UIButton!
    var guardianPlaces = ["Salon", "Hall", "Garage", "Bedroom", "Kitchen", "Outside"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCustomView()
        setupNavBar()
        warningButton.imageView?.contentMode = .scaleAspectFit
        buttonSelectedSetup(button: warningButton)
        lastTouchedButton = warningButton
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = nil
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .left)
        
        let videoURL = URL(string: "http://52.236.165.15:80/hls/camera.m3u8")
        let player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.playerView.bounds
        self.playerView.layer.addSublayer(playerLayer)
        player.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupCustomView() {
        let customView = Bundle.main.loadNibNamed("WarningView", owner: self, options: nil)!.first as! WarningSectionView
        customView.translatesAutoresizingMaskIntoConstraints = true
        customView.autoresizingMask = []
        customView.frame.origin = contentView.bounds.origin
        
        customView.frame = CGRect(x: -contentView.frame.width/2, y: 0, width: contentView.frame.width, height: contentView.frame.height)
        
        print(customView.frame)
        contentView.addSubview(customView)
    }
    
    func setupNavBar() {
        
        let imageView = UIImageView(image: UIImage(named: "guardianName"))
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
        buttonSelectedSetup(button: button)
        resetLastTouchedButton()
        lastTouchedButton = button
    }
    
    @IBAction func warningButtonTouched(button: UIButton!) {
        guard lastTouchedButton != button else { return }
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
        buttonSelectedSetup(button: button)
        resetLastTouchedButton()
        lastTouchedButton = button
    }

}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
        cell.backgroundColor = cell.selectionColor
        self.placeLabel.text = cell.label.text
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? GuardianCollectionViewCell
        if let cell = cell {
            cell.backgroundColor = cell.defaultColor
        }
        
    }
}
