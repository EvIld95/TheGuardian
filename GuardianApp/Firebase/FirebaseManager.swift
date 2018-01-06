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
    
    func addNewSensor(raspSerial: String, name: String!) {
        let ref = Database.database().reference()
        ref.child("sensor").child(raspSerial).updateChildValues([name : ["value" : 0.0]])
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
        let ref = Database.database().reference().child("sensor")
        var sensors = [String : [SensorModel]]()
        
        handlerSensorUpdates = ref.observe(.childChanged, with: { (snapshot) in
            sensors.removeAll()
            //print(snapshot.value)
            if let array = snapshot.value as? [String: [String: AnyObject]] {
                //print(array)
//                //MARK: TO DO
//                //Separete and search only sensors from raspberry of the current user
                sensors[snapshot.key] = [SensorModel]()
                
                for (sensorName, innerDict) in array {
                    
                    let sensor = SensorModel()
                    sensor.raspSerial = snapshot.key
                    sensor.name = sensorName
                    sensor.value = innerDict["value"]! as! Double
                    
                    sensors[snapshot.key]!.append(sensor)
                }
                //print(sensors)
                completion(sensors)
            }
            
        })
    }
            
//                    //print(dict[dictKey])
//                    let innerDict = (dict[dictKey] as! [Dictionary<String, AnyObject>])
//
//                    for sensorDevice in innerDict {
//                        print(sensorDevice)
//                        //for sensorDict =
//                        //for
////                        let sensor = SensorModel()
////                        sensor.raspSerial = dictKey
////                        sensor.name = sensorName
////                        sensor.value = innerDict[sensorName]!["value"]! as! Double
////                        if var array = sensors[dictKey] {
////                            array.append(sensor)
////                        } else {
////                            sensors[dictKey] = [SensorModel]()
////                            sensors[dictKey]!.append(sensor)
////                        }
//
//                    }
//                }
//                //print(sensors)
//                //completion(sensors)
//            }
//       })
//    }
    
    func stopListenForSensorUpdates(raspSerial: String) {
        let ref = Database.database().reference().child("sensor").child(raspSerial)
        ref.removeObserver(withHandle: handlerSensorUpdates)
    }
    
}
