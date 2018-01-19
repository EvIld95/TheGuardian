//
//  GuardianAppTests.swift
//  GuardianAppTests
//
//  Created by Paweł Szudrowicz on 19.01.2018.
//  Copyright © 2018 Paweł Szudrowicz. All rights reserved.
//

import XCTest
import Moya
import Moya_SwiftyJSONMapper
@testable import GuardianApp

class GuardianAppTests: XCTestCase {
    
    var provider: MoyaProvider<GuardService>!
    
    override func setUp() {
        super.setUp()
        provider = MoyaProvider<GuardService>(stubClosure: MoyaProvider.immediatelyStub)
    }
    
    func testCameraRequest() {
        provider.request(.cameraAddress(token: "debug")) { result in
            switch result {
            case let .success(moyaResponse):
                let data = try? moyaResponse.map(to: CameraResponseModel.self)
                guard let _ = data else {
                    XCTAssert(false)
                    return
                }
                
                XCTAssertEqual(data?.cameraAddress, "http://52.236.165.15/hls/test.m3u8")
                
            case .failure(_):
                XCTAssert(false)
            }
        }
    }
    
    func testGetRaspberryRequest() {
        provider.request(.getRaspberry(token: "debug", email: "pablo.szudrowicz@gmail.com")) { result in
            switch result {
            case let .success(moyaResponse):
                print(moyaResponse.data)
                let data = try? moyaResponse.map(to: RaspberriesModel.self)
                guard let _ = data else {
                    XCTAssert(false)
                    return
                }
                
                XCTAssertEqual(data?.raspberries["testSerial"], "Salon")
                
            case .failure(_):
                XCTAssert(false)
            }
        }
    }
    
    func testGetNotificationRequest() {
        provider.request(.getNotifications(token: "debug", raspSerial: "testSerial")) { result in
            switch result {
            case let .success(moyaResponse):
                print(moyaResponse.data)
                let data = try? moyaResponse.map(to: Notifications.self)
                guard let _ = data else {
                    XCTAssert(false)
                    return
                }
                
                XCTAssertEqual(data?.array[0].date, "2018-01-16")
                XCTAssertEqual(data?.array[0].message, "High Value of LPG")
                XCTAssertEqual(data?.array[0].serial, "00000000fb021b9a")
                XCTAssertEqual(data?.array[0].type, "LPGSensor")
                
                
            case .failure(_):
                XCTAssert(false)
            }
        }
    }
    
    

}
