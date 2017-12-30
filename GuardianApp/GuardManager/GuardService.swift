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
}

extension GuardService: TargetType {
    var baseURL: URL { return URL(string: "http://52.236.165.15:8080/v1")! }
    var path: String {
        switch self {
        case .cameraAddress:
            return "/camera_address"
        }
    }
    var method: Moya.Method {
        switch self {
        case .cameraAddress:
            return .get
        }
    }
    var task: Task {
        switch self {
        case .cameraAddress: // Send no parameters
            return .requestPlain
        }
    }
    var sampleData: Data {
        switch self {
        case .cameraAddress:
            return "http://52.236.165.15:80/hls/test.m3u8".utf8Encoded
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
