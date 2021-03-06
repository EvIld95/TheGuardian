//
//  GuardService.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 30.12.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import Foundation
import Moya


enum GuardService {
    case cameraAddress(token: String)
    case addRaspberry(token: String, raspSerial: String, email: String)
    case getRaspberry(token: String, email: String)
    case assign(token: String, raspSerial: String, email: String)
    case updateFCMToken(token: String, fcmToken: String, email: String, deviceId: String)
    case changeGuardName(token: String, raspSerial: String, name: String)
    case getNotifications(token: String, raspSerial: String)
}

extension GuardService: TargetType {
    var baseURL: URL { return URL(string: "http://52.236.165.15/backend/v1")! }
    var path: String {
        switch self {
        case .cameraAddress(_):
            return "/camera_address"
        case .addRaspberry(_, _, _):
            return "/devices/add"
        case .getRaspberry(_, _):
            return "/devices/get"
        case .assign(_, _, _):
            return "/devices/assing"
        case .updateFCMToken(_, _, _, _):
            return "/fcmTokenUpdate"
        case .changeGuardName(_,_,_):
            return "/devices/changeRaspName"
        case .getNotifications(_, _):
            return "/devices/notifications"
        }
    }
    var method: Moya.Method {
        switch self {
        case .cameraAddress:
            return .post
        case .addRaspberry:
            return .post
        case .getRaspberry:
            return .post
        case .assign:
            return .post
        case .updateFCMToken:
            return .post
        case .changeGuardName:
            return .post
        case .getNotifications:
            return .post
        }
        
    }
    var task: Task {
        switch self {
        case .cameraAddress(let token):
            return .requestParameters(parameters: ["token": token], encoding: JSONEncoding.default)
        case .addRaspberry(let token ,let raspSerial, let email):
            return .requestParameters(parameters: ["token": token, "serial": raspSerial, "owner": email], encoding: JSONEncoding.default)
        case .getRaspberry(let token ,let email):
            return .requestParameters(parameters: ["token": token, "owner": email], encoding: JSONEncoding.default)
        case .assign(let token ,let raspSerial, let email):
            return .requestParameters(parameters: ["token": token, "serial": raspSerial, "owner": email], encoding: JSONEncoding.default)
        case .updateFCMToken(_ ,let fcmToken, let email, let deviceId):
            return .requestParameters(parameters: ["fcmToken": fcmToken, "email": email, "deviceId": deviceId], encoding: JSONEncoding.default)
        case .changeGuardName(let token ,let raspSerial, let name):
            return .requestParameters(parameters: ["token": token, "serial": raspSerial, "name": name], encoding: JSONEncoding.default)
        case .getNotifications(let token ,let raspSerial):
            return .requestParameters(parameters: ["token": token, "serial": raspSerial], encoding: JSONEncoding.default)
        }
    }
    var sampleData: Data {
        switch self {
        case .cameraAddress:
            return "{\"id\": \"http://52.236.165.15/hls/test.m3u8\"}".utf8Encoded
        case .addRaspberry(let token, let raspSerial, let email):
            return "{\"token\": \(token), \"serial\": \"\(raspSerial), \"owner\": \(email)\"}".utf8Encoded
        case .getRaspberry(_, _):
            return "[{\"serial\": \"testSerial\", \"name\": \"Salon\"}]".utf8Encoded
        case .assign(let token, let raspSerial, let email):
            return "{\"token\": \(token), \"owner\": \"\(email), \"serial\": \"\(raspSerial)\"}".utf8Encoded
        case .updateFCMToken(_ ,let fcmToken, let email, let deviceId):
            return "{\"fcmToken\": \(fcmToken), \"email\": \"\(email), \"deviceId\": \"\(deviceId)\"}".utf8Encoded
        case .changeGuardName(let token, let raspSerial, let name):
            return "{\"token\": \(token), \"name\": \"\(name), \"serial\": \"\(raspSerial)\"}".utf8Encoded
        case .getNotifications(_, _):
            return "[{\"type\": \"LPGSensor\", \"serial\": \"00000000fb021b9a\", \"message\": \"High Value of LPG\", \"date\": \"2018-01-16\"}]".utf8Encoded
        }
        
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
// MARK: - Helpers
private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
