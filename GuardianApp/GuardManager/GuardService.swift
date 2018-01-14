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
    case addRaspberry(token: String, raspSerial: String)
    case getRaspberry(token: String, email: String)
    case assign(token: String, raspSerial: String, email: String)
}

extension GuardService: TargetType {
    var baseURL: URL { return URL(string: "http://52.236.165.15/backend/v1")! }
    var path: String {
        switch self {
        case .cameraAddress(_):
            return "/camera_address"
        case .addRaspberry(_, _):
            return "/devices/add"
        case .getRaspberry(_, _):
            return "/devices"
        case .assign(_, _, _):
            return "/devices/assing"
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
        }
        
    }
    var task: Task {
        switch self {
        case .cameraAddress(let token):
            return .requestParameters(parameters: ["token": token], encoding: JSONEncoding.default)
        case .addRaspberry(let token ,let raspSerial):
            return .requestParameters(parameters: ["token": token, "serial": raspSerial], encoding: JSONEncoding.default)
        case .getRaspberry(let token ,let email):
            return .requestParameters(parameters: ["token": token, "owner": email], encoding: JSONEncoding.default)
        case .assign(let token ,let raspSerial, let email):
            return .requestParameters(parameters: ["token": token, "serial": raspSerial, "owner": email], encoding: JSONEncoding.default)
        }
    }
    var sampleData: Data {
        switch self {
        case .cameraAddress:
            return "http://52.236.165.15/hls/test.m3u8".utf8Encoded
        case .addRaspberry(let token, let raspSerial):
            return "{\"token\": \(token), \"serial\": \"\(raspSerial)\"}".utf8Encoded
        case .getRaspberry(let token, let email):
            return "{\"token\": \(token), \"owner\": \"\(email)\"}".utf8Encoded
        case .assign(let token, let raspSerial, let email):
            return "{\"token\": \(token), \"owner\": \"\(email), \"serial\": \"\(raspSerial)\"}".utf8Encoded
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
