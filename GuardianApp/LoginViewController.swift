//
//  LoginViewController.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 27.11.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!
    
    private let backImageView: UIImageView! = UIImageView(image: UIImage(named: "guardLogo"))
    private let frontImageView: UIImageView! = UIImageView(image: UIImage(named: "guardLogo"))
    private var showingBack = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(flip))
        self.logo.addGestureRecognizer(gesture)
    }
  
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        frontImageView.contentMode = .scaleAspectFit
        backImageView.contentMode = .scaleAspectFit
        frontImageView.frame = logo.frame
        backImageView.frame = logo.frame
        logo.addSubview(frontImageView)
        frontImageView.translatesAutoresizingMaskIntoConstraints = true
        backImageView.translatesAutoresizingMaskIntoConstraints = true
    }
    
    @objc func flip() {
            let toView = showingBack ? frontImageView : backImageView
            let fromView = showingBack ? backImageView : frontImageView
            
            UIView.transition(from: fromView!, to: toView!, duration: 0.3, options: .transitionFlipFromRight, completion: nil)
            showingBack = !showingBack
    }

}
