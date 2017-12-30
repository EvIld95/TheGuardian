//
//  MovementDetectionView.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 30.12.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit

class MovementDetectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, SectionViewDisplayer {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var label: UILabel!
    
    let historyOfMovementDetection = ["1","2","3","4","5","6","7","8","9","10"]
    var lastSelectedIndexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.backgroundColor = .clear
        self.collectionView.register(MovementDetectionCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.allowsMultipleSelection = false
    }
    
    func adjustSectionView(withSectionName section: String!) {
        self.label.text = "Guard [\(section!)] history:"
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return historyOfMovementDetection.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MovementDetectionCollectionViewCell
        cell.label.text = historyOfMovementDetection[indexPath.item]
        
        
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
        
        if let lastSelectedIndexPath = lastSelectedIndexPath {
            collectionView.deselectItem(at: lastSelectedIndexPath, animated: false)
            //        if let cellLast = collectionView.cellForItem(at: lastSelectedIndexPath!) as? GuardianCollectionViewCell {
            //            cellLast.backgroundColor = cellLast.defaultColor
            //        }
            collectionView.reloadItems(at: [lastSelectedIndexPath])
        }
        lastSelectedIndexPath = indexPath
    }
    
    
    @IBAction func buttonTapped(button: UIButton!) {
        
    }
    

}
