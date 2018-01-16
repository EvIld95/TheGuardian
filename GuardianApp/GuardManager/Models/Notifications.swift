//
//  Notification.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 16.01.2018.
//  Copyright © 2018 Paweł Szudrowicz. All rights reserved.
//

import Foundation


import Foundation
import Moya_SwiftyJSONMapper
import SwiftyJSON

final class Notifications : ALSwiftyJSONAble {
    
    var array = [Notification]()
    
    required init?(jsonData:JSON){
        print(jsonData)
        for element in jsonData.array! {
            let message = element["message"].string!
            let type = element["type"].string!
            let date = element["date"].string!
            let notification = Notification(message: message, type: type, date: date)
            array.append(notification)
        }
        
    }
    
}

final class Notification {
    var message: String
    var type: String
    var date: String
    init(message: String, type: String, date: String) {
        self.message = message
        self.type = type
        self.date = date
    }
}

