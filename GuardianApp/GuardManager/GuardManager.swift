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
}
