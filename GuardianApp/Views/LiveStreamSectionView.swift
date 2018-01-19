//
//  LiveStreamSectionView.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 31.12.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit

class LiveStreamSectionView: UIView, SectionViewDisplayer {
    @IBOutlet weak var titleLabel: UILabel!
    
    func adjustSectionView(withSectionName section: String!) {
        self.titleLabel.text = "Live stream from \(section!)"
        let raspSerial = FirebaseManager.sharedInstance.getRaspSerialFromPlace(place: section!)
        StreamManager.sharedInstance.streamVideoFrom(urlString: "http://52.236.165.15:80/hls/\(raspSerial).m3u8")
    }
    
}
