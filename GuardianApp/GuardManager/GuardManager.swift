//
//  GuardManager.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 30.12.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit
import Moya
import Moya_SwiftyJSONMapper
import SwiftyJSON
import FirebaseAuth
import FirebaseMessaging

class GuardManager {
    static let sharedInstance = GuardManager()
    
    func fetchCameraAddress(completion: @escaping (ALSwiftyJSONAble?) -> ()) {
        let provider = MoyaProvider<GuardService>()
        
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            print(idToken!)
            guard error == nil else { return }
            provider.request(.cameraAddress(token: idToken!)) { result in
                switch result {
                case let .success(moyaResponse):
                    let data = try? moyaResponse.map(to: CameraResponseModel.self)
                    completion(data)
                    
                case let .failure(_):
                    completion(nil)
                }
            }
        }
    }
    
    func addRaspberryToDatabase(serial: String, completion: @escaping () -> ()) {
        let provider = MoyaProvider<GuardService>()
        let currentUser = Auth.auth().currentUser
        let email = Auth.auth().currentUser!.email
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            provider.request(.addRaspberry(token: idToken!, raspSerial: serial, email: email!)) { result in
                switch result {
                case let .success:
                    completion()
                    
                case let .failure:
                    print("ERROR")
                }
            }
        }
    }
    
    func assignRaspberryToUser(serial: String, completion: @escaping () -> ()) {
        let provider = MoyaProvider<GuardService>()
        let currentUser = Auth.auth().currentUser
        let email = Auth.auth().currentUser!.email
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            provider.request(.assign(token: idToken!, raspSerial: serial, email: email!)) { result in
                switch result {
                case let .success:
                    print(result)
                    completion()
                    
                case let .failure:
                    print("ERROR")
                }
            }
        }
    }
    
    func getMyRaspberries(completion: @escaping (ALSwiftyJSONAble?) -> ()) {
        let provider = MoyaProvider<GuardService>()
        let currentUser = Auth.auth().currentUser
        let email = Auth.auth().currentUser!.email
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            guard error == nil else { return }
            provider.request(.getRaspberry(token: idToken!, email: email!)) { result in
                switch result {
                case let .success(moyaResponse):
                    let data = try? moyaResponse.map(to: RaspberriesModel.self)
                    completion(data)
                    
                case let .failure(_):
                    completion(nil)
                }
            }
        }
    }
    
    func updateFCMToken(completion: @escaping () -> ()) {
        let provider = MoyaProvider<GuardService>()
        let currentUser = Auth.auth().currentUser
        let email = Auth.auth().currentUser!.email
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            guard error == nil else { return }
            provider.request(.updateFCMToken(token: idToken!, fcmToken: Messaging.messaging().fcmToken!, email: email!, deviceId: deviceId)) { result in
                switch result {
                case let .success:
                    completion()
                    
                case let .failure:
                    print("ERROR")
                }
            }
        }
    }
    
    func changeGuardName(serial: String,name: String, completion: @escaping () -> ()) {
        let provider = MoyaProvider<GuardService>()
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            guard error == nil else { return }
            provider.request(.changeGuardName(token: idToken!, raspSerial: serial, name: name)) { result in
                switch result {
                case let .success:
                    completion()
                    
                case let .failure:
                    print("ERROR")
                }
            }
        }
    }
    
    
    func getNotifications(serial: String, completion: @escaping (ALSwiftyJSONAble?) -> ()) {
        let provider = MoyaProvider<GuardService>()
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            guard error == nil else { return }
            provider.request(.getNotifications(token: idToken!, raspSerial: serial)) { result in
                switch result {
                case let .success(moyaResponse):
                    let data = try? moyaResponse.map(to: Notifications.self)
                    completion(data)
                    
                case let .failure(_):
                    completion(nil)
                }
            }
        }
    }
}
