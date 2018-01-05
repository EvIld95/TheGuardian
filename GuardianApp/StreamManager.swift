//
//  StreamManager.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 05.01.2018.
//  Copyright © 2018 Paweł Szudrowicz. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import RxSwift


class StreamManager {
    static let sharedInstance = StreamManager()
    private let disposeBag = DisposeBag()
    
    var streamView: UIView?
    var currentPlayer: AVPlayer?
    var currentUrlString: String?

    
    init() {
        setupRx()
    }
    
    private func setupRx() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.inBackground.asObservable().subscribe(onNext: { (value) in
            if let streamView = self.streamView {
                if let player = self.currentPlayer {
                    if value == false {
                        self.streamVideoFrom(urlString: self.currentUrlString!)
                        print("Enter foreground")
                    } else {
                        print("Enter background")
                        streamView.subviews.forEach({ (view) in
                            view.removeFromSuperview()
                        })
                    }
                }
            }
        }).disposed(by: disposeBag)
    }
    
    func playStreamOn(view: UIView) {
        self.streamView = view
    }
    
    func streamVideoFrom(urlString: String) {
        guard let streamView = self.streamView else { print("ADD STREAM VIEW"); return}
        
        let videoURL = URL(string: urlString)
        let player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        self.currentPlayer = player
        self.currentUrlString = urlString
        playerLayer.player = player
        playerLayer.frame = streamView.bounds
        DispatchQueue.main.async {
            streamView.layer.addSublayer(playerLayer)
            player.play()
        }
    }
    
    
    
}
