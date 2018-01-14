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
    case cameraAddress
    case addRaspberry(token: String, raspSerial: String)
}

extension GuardService: TargetType {
    var baseURL: URL { return URL(string: "http://52.236.165.15/backend/v1")! }
    var path: String {
        switch self {
        case .cameraAddress:
            return "/camera_address"
        case .addRaspberry(_, _):
            return "/add_raspberry"
        }
    }
    var method: Moya.Method {
        switch self {
        case .cameraAddress:
            return .get
        case .addRaspberry:
            return .post
        }
        
    }
    var task: Task {
        switch self {
        case .cameraAddress: // Send no parameters
            return .requestPlain
        case .addRaspberry(let token ,let raspSerial):
            return .requestParameters(parameters: ["token": token, "serial": raspSerial], encoding: JSONEncoding.default)
        }
    }
    var sampleData: Data {
        switch self {
        case .cameraAddress:
            return "http://52.236.165.15/hls/test.m3u8".utf8Encoded
        case .addRaspberry(let token, let raspSerial):
            return "{\"token\": \(token), \"serial\": \"\(raspSerial)\"}".utf8Encoded
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
