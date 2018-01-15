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
import FirebaseAuth
import Firebase
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    private let backImageView: UIImageView! = UIImageView(image: UIImage(named: "guardLogo"))
    private let frontImageView: UIImageView! = UIImageView(image: UIImage(named: "guardLogo"))
    private var showingBack = false
    let disposeBag = DisposeBag()
    
    private var loginPage = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailAddressTextField.text = "pablo.szudrowicz@gmail.com"
        self.passwordTextField.text = "qwerty"
        
        setupRx()
        
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
    
    func setupRx() {
        let emailRx = emailAddressTextField.rx.text.orEmpty.throttle(0.5,scheduler:MainScheduler.instance).map { (inputText) -> Bool in
            return ( (inputText.count > 0) && (inputText.contains("@")) )
        }
        let passwordRx = passwordTextField.rx.text.orEmpty.throttle(0.5, scheduler: MainScheduler.instance).map { (inputText) ->Bool in
            return (inputText.count) > 0
        }
        
        Observable.combineLatest(emailRx, passwordRx).subscribe(onNext: { (email, password) in
            if(email == true && password == true) {
                self.loginButton.isEnabled = true
                self.loginButton.alpha = 1.0
            } else {
                self.loginButton.isEnabled = false
                self.loginButton.alpha = 0.5
            }
        }).disposed(by: disposeBag)
    }
    
    @objc func flip() {
        let toView = showingBack ? frontImageView : backImageView
        let fromView = showingBack ? backImageView : frontImageView
        
        UIView.transition(from: fromView!, to: toView!, duration: 0.3, options: .transitionFlipFromRight, completion: nil)
        showingBack = !showingBack
        
        hideKeyboard()
    }
    
    @IBAction func loginButtonTapped(sender: UIButton!) {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        if loginPage {
            Auth.auth().signIn(withEmail: emailAddressTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                MBProgressHUD.hide(for: self.view, animated: true)
                guard error == nil else {
                    let alertController = UIAlertController(title: "Error!", message: error!.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                self.performSegue(withIdentifier: "loggedInSuccess", sender: nil)
            })
            
        } else {
            Auth.auth().createUser(withEmail: emailAddressTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                MBProgressHUD.hide(for: self.view, animated: true)
                guard error == nil else {
                    let alertController = UIAlertController(title: "Error!", message: error!.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                self.performSegue(withIdentifier: "loggedInSuccess", sender: nil)
            })
        }
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navController = segue.destination as! UINavigationController
        let viewController = navController.topViewController as! ViewController
        viewController.loggedInUserMail = self.emailAddressTextField.text!
        
    }
}
