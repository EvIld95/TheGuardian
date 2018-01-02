//
//  LoginViewController.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 27.11.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit
import MBProgressHUD
import IHKeyboardAvoiding

class LoginViewController: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
    private let backImageView: UIImageView! = UIImageView(image: UIImage(named: "guardLogo"))
    private let frontImageView: UIImageView! = UIImageView(image: UIImage(named: "guardLogo"))
    private var showingBack = false
    
    private var loginPage = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        KeyboardAvoiding.avoidingView = self.stackView
        let gesture = UITapGestureRecognizer(target: self, action: #selector(flip))
        self.logo.addGestureRecognizer(gesture)
        
        let gesture2 = UITapGestureRecognizer(target: self, action: #selector(touchedView))
        self.view.addGestureRecognizer(gesture2)
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
        
        hideKeyboard()
    }
    
    @IBAction func loginButtonTapped(sender: UIButton!) {
        hideKeyboard()
    }

    @IBAction func dontHaveAccountButtonTapped(sender: UIButton!) {
        
        if loginPage {
            dontHaveAccountButton.setTitle("I've already have an account! Go to Login Page", for: .normal)
            loginButton.setTitle("Register Now!", for: .normal)
        } else {
            dontHaveAccountButton.setTitle("Don't have account? Register here!", for: .normal)
            loginButton.setTitle("Log In", for: .normal)
        }
        
        loginPage = !loginPage
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func touchedView() {
        hideKeyboard()
    }
}
