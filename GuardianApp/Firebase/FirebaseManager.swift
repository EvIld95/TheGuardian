//
//  FirebaseManager.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 04.01.2018.
//  Copyright © 2018 Paweł Szudrowicz. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class FirebaseManager {
    static let sharedInstance = FirebaseManager()
    
    var handlerSensorUpdates: UInt!
    var raspNames : [String]?
    var handlersOfAllRaspsDict = [String: UInt]()
    
    func addNewSensor(raspSerial: String, name: String!, place: String!) {
        let ref = Database.database().reference()
        ref.child("sensor").child(raspSerial).updateChildValues([name : ["value" : 0.0, "place" : place]])
    }
    
    func addRaspNames(rasps: [String]) {
        self.raspNames?.removeAll()
        self.raspNames = rasps
    }
    
    
    func listenForSensorUpdates(raspSerial: String, completion: @escaping ([SensorModel]) -> ()) {
        let ref = Database.database().reference().child("sensor").child(raspSerial)
        var sensors = [SensorModel]()
        
        handlerSensorUpdates = ref.observe(.value, with: { (snapshot) in
            sensors.removeAll()
            
            if let dict = snapshot.value as? [String: AnyObject] {
                for dictKey in dict.keys {
                    let sensor = SensorModel()
                    sensor.raspSerial = raspSerial
                    sensor.name = dictKey
                    sensor.value = dict[dictKey]!["value"]! as! Double
                    if snapshot.key == raspSerial {
                        sensors.append(sensor)
                    }
                }
                completion(sensors)
            }
        })
    }
    
    func listenForAllSensorUpdates(completion: @escaping ([String : [SensorModel]]) -> ()) {
        guard let raspNames = raspNames else { return }
        
        
        let ref = Database.database().reference().child("sensor")
        var sensors = [String : [SensorModel]]()
        
        for place in raspNames {
            if(UserDefaults.standard.bool(forKey: "NoActive\(place)") == false) {
                handlersOfAllRaspsDict[place] = ref.child(place).observe(.childChanged, with: { (snapshot) in
                    sensors.removeAll()
                    print(snapshot.key)
                    if let dict = snapshot.value as? Dictionary<String, AnyObject> {
                        sensors[dict["place"]! as! String] = [SensorModel]()
                        
                        let sensor = SensorModel()
                        sensor.raspSerial = place
                        sensor.name = snapshot.key
                        sensor.value = dict["value"]! as! Double
                        sensor.place = dict["place"]! as! String
                        sensors[dict["place"]! as! String]!.append(sensor)
                        
                        completion(sensors)
                    }
                    
                })
            }
        }
        
        //if we want to listen all listeners:
//        handlerSensorUpdates = ref.child(place).observe(.childChanged, with: { (snapshot) in
//            sensors.removeAll()
//            print(snapshot.value)
//            if let array = snapshot.value as? [String: [String: AnyObject]] {
//                //print(array)
//                //                //MARK: TO DO
//                //                //Separete and search only sensors from raspberry of the current user
//                sensors[snapshot.key] = [SensorModel]()
//
//                for (sensorName, innerDict) in array {
//
//                    let sensor = SensorModel()
//                    sensor.raspSerial = snapshot.key
//                    sensor.name = sensorName
//                    sensor.value = innerDict["value"]! as! Double
//
//                    sensors[snapshot.key]!.append(sensor)
//                }
//                //print(sensors)
//                completion(sensors)
//            }
//
//        })
    }
    
    func stopListenForSensorUpdates(raspSerial: String) {
        let ref = Database.database().reference().child("sensor").child(raspSerial)
        ref.removeObserver(withHandle: handlerSensorUpdates)
    }
    
    func stopListenForSensorUpdates(inPlace: String) {
        
        //TO DO: Concert inPlace to raspSerial
        let ref = Database.database().reference().child("sensor").child(inPlace)
        ref.removeObserver(withHandle: handlersOfAllRaspsDict[inPlace]!)
    }
    
    func stopListenForAllSensorsUpdates() {
        guard let raspNames = raspNames else { return }
        
        for place in raspNames {
            let ref = Database.database().reference().child("sensor").child(place)
            ref.removeAllObservers()
        }
    }
    
}
