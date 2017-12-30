//
//  CameraResponseModel.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 30.12.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import Foundation
import Moya_SwiftyJSONMapper
import SwiftyJSON

final class CameraResponseModel : ALSwiftyJSONAble {
    
    let cameraAddress: String?
    
    required init?(jsonData:JSON){
        self.cameraAddress = jsonData["id"].string
    }
    
}
