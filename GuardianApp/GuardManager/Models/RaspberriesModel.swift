//
//  RaspberriesModel.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 14.01.2018.
//  Copyright © 2018 Paweł Szudrowicz. All rights reserved.
//

import Foundation


import Foundation
import Moya_SwiftyJSONMapper
import SwiftyJSON

final class RaspberriesModel : ALSwiftyJSONAble {
    
    var raspberries = [String: String]()
    
    required init?(jsonData:JSON){
        print(jsonData)
        for element in jsonData.array! {
            let name = element["name"].string!
            let raspSerial = element["serial"].string!
            raspberries[raspSerial] = name
        }
        
    }
    
}
