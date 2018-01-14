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

class GuardManager {
    static let sharedInstance = GuardManager()
    
    func fetchCameraAddress(completion: @escaping (ALSwiftyJSONAble?) -> ()) {
        let provider = MoyaProvider<GuardService>()
        provider.request(.cameraAddress) { result in
            switch result {
            case let .success(moyaResponse):
                let data = try? moyaResponse.map(to: CameraResponseModel.self)
                completion(data)
                
            case let .failure(_):
                completion(nil)
            }
        }
    }
    
    func addRaspberryToDatabase(serial: String) {
        let provider = MoyaProvider<GuardService>()
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            provider.request(.addRaspberry(token: "James", raspSerial: "Potter")) { result in
                print(result)
            }
        }
    }
}
