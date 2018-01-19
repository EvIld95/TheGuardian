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
    
    func testCameraRequest() {
        let provider = MoyaProvider<GuardService>(stubClosure: MoyaProvider.immediatelyStub)
        
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
        let provider = MoyaProvider<GuardService>(stubClosure: MoyaProvider.immediatelyStub)
        
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
        let provider = MoyaProvider<GuardService>(stubClosure: MoyaProvider.immediatelyStub)
        
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
    
    
    
    
//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//
}
