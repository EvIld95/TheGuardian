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
    var serialToPlaceDict : Dictionary<String, String>?
    var previousValuesOfSensors = [String: Double]()
    var handlersOfAllRaspsDict = [String: UInt]()
    
    func addNewSensor(raspSerial: String, name: String!, place: String!) {
        let ref = Database.database().reference()
        ref.child("sensor").child(raspSerial).updateChildValues([name : ["value" : 0.0]])
    }
    
    func addSerialToPlaceDict(dict: Dictionary<String, String>) {
        self.serialToPlaceDict?.removeAll()
        self.serialToPlaceDict = dict
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
    
  
    
    func listenForAllSensorUpdates(completion: @escaping (SensorModel) -> ()) {
        guard let serialToPlaceDict = serialToPlaceDict else { return }
        
        let ref = Database.database().reference().child("sensor")
        
        for (raspSerial, name) in serialToPlaceDict {
            if(UserDefaults.standard.bool(forKey: "NoActive\(raspSerial)") == false) {
                handlersOfAllRaspsDict[raspSerial] = ref.child(raspSerial).observe(.childChanged, with: { (snapshot) in
                    print(snapshot.key)
                    if let dict = snapshot.value as? Dictionary<String, AnyObject> {
                        let sensor = SensorModel()
                        sensor.raspSerial = raspSerial
                        sensor.name = snapshot.key
                        sensor.value = dict["value"]! as! Double
                        sensor.place = name
                        if let pv = self.previousValuesOfSensors[sensor.name] {
                            if sensor.value! - pv > 0 {
                                completion(sensor)
                            }
                        }
                        self.previousValuesOfSensors[sensor.name] = sensor.value
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
        
        let raspSerial = self.getRaspSerialFromPlace(place: inPlace)
        let ref = Database.database().reference().child("sensor").child(raspSerial)
        ref.removeObserver(withHandle: handlersOfAllRaspsDict[raspSerial]!)
    }
    
    func getRaspSerialFromPlace(place:String) -> String {
        return self.serialToPlaceDict!.filter { (key, value) -> Bool in
            return value == place
            }.map { (key, value) -> String in
                return key }.first!
    }
    
    func stopListenForAllSensorsUpdates() {
        guard let serialToPlaceDict = serialToPlaceDict else { return }
        
        for raspSerial in serialToPlaceDict.keys {
            let ref = Database.database().reference().child("sensor").child(raspSerial)
            ref.removeAllObservers()
        }
    }
    
}
