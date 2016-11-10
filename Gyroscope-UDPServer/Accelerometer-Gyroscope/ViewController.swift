//
//  ViewController.swift
//  Accelerometer-Gyroscope
//
//  Created by Ki Han on 9/1/16.
//  Copyright © 2016 Ki Development. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreMotion
import CocoaAsyncSocket

class ViewController: UIViewController, GCDAsyncUdpSocketDelegate{
    
    //Instance Variables
    
    var currentMaxAccelX: Double = 0.0
    var currentMaxAccelY: Double = 0.0
    var currentMaxAccelZ: Double = 0.0
    
    var currentMaxRotX: Double = 0.0
    var currentMaxRotY: Double = 0.0
    var currentMaxRotZ: Double = 0.0
    
    var motionManager = CMMotionManager()
    var udpSocket:GCDAsyncUdpSocket!
    //Outlets
    
    @IBOutlet var accX: UILabel!
    @IBOutlet var accY: UILabel!
    @IBOutlet var accZ: UILabel!
    @IBOutlet var maxAccX: UILabel!
    @IBOutlet var maxAccY: UILabel!
    @IBOutlet var maxAccZ: UILabel!
    
    @IBOutlet var rotX: UILabel!
    @IBOutlet var rotY: UILabel!
    @IBOutlet var rotZ: UILabel!
    @IBOutlet var maxRotX: UILabel!
    @IBOutlet var maxRotY: UILabel!
    @IBOutlet var maxRotZ: UILabel!
    
    @IBOutlet weak var roll: UILabel!
    @IBOutlet weak var pitch: UILabel!
    @IBOutlet weak var yaw: UILabel!
    
    @IBAction func resetMaxValues() {
        currentMaxAccelX = 0
        currentMaxAccelY = 0
        currentMaxAccelZ = 0
        
        currentMaxRotX = 0
        currentMaxRotY = 0
        currentMaxRotZ = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resetMaxValues()
        
        udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)

        motionManager.gyroUpdateInterval = 0.2
        motionManager.accelerometerUpdateInterval = 0.2
        
        //Start Recording Data
        
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (accelerometerData: CMAccelerometerData?, NSError) -> Void in
            
            self.outputAccData(accelerometerData!.acceleration)
            if(NSError != nil) {
                print("\(NSError)")
            }
        }
        
        motionManager.startGyroUpdates(to: OperationQueue.current!, withHandler: { (gyroData: CMGyroData?, NSError) -> Void in
            self.outputRotData(gyroData!.rotationRate)
            if (NSError != nil){
                print("\(NSError)")
            }
            
        self.motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {(motionData: CMDeviceMotion?, NSError) -> Void in self.outputRPY(data: motionData!)
                if (NSError != nil){
                    print("\(NSError)")
                }
            })

        })
    }
    
    func outputRPY(data: CMDeviceMotion){
        let rpyattitude = motionManager.deviceMotion!.attitude
        roll?.text  = "\(rpyattitude.roll * (180.0 / M_PI))"
        pitch?.text   = "\(rpyattitude.pitch * (180.0 / M_PI))"
        yaw?.text     = "\(rpyattitude.yaw * (180.0 / M_PI))"
        
        let data2send = Data(base64Encoded: "\(rpyattitude.roll)|\(rpyattitude.pitch)|\(rpyattitude.yaw)")
        
        self.udpSocket.send(data2send!, withTimeout: -1, tag: 1)
        //udpSocket.sendData:data toHost:@"192.168.10.111" port:550 withTimeout:-1 tag:1];

    }
    
    func outputAccData(_ acceleration: CMAcceleration){
        
        accX?.text = "\(acceleration.x).2fg"
        
        if fabs(acceleration.x) > fabs(currentMaxAccelX) {
            currentMaxAccelX = acceleration.x
        }
        
        accY?.text = "\(acceleration.y).2fg"
        
        if fabs(acceleration.y) > fabs(currentMaxAccelY) {
            currentMaxAccelY = acceleration.y
        }
        
        accZ?.text = "\(acceleration.z).2fg"
        
        if fabs(acceleration.z) > fabs(currentMaxAccelZ) {
            currentMaxAccelZ = acceleration.z
        }
        
        maxAccX?.text = "\(currentMaxAccelX).2f"
        maxAccY?.text = "\(currentMaxAccelY).2f"
        maxAccZ?.text = "\(currentMaxAccelZ).2f"
        
        
    }
    
    func outputRotData(_ rotation: CMRotationRate){
        
        rotX?.text = "\(rotation.x).2fr/s"
        
        if fabs(rotation.x) > fabs(currentMaxRotX) {
            currentMaxRotX = rotation.x
        }
        
        rotY?.text = "\(rotation.y).2fr/s"
        
        if fabs(rotation.y) > fabs(currentMaxRotY) {
            currentMaxRotY = rotation.y
        }
        
        rotZ?.text = "\(rotation.z).2fr/s"
        
        if fabs(rotation.z) > fabs(currentMaxRotZ) {
            currentMaxRotZ = rotation.z
        }
        
        maxRotX?.text = "\(currentMaxRotX).2f"
        maxRotY?.text = "\(currentMaxRotY).2f"
        maxRotZ?.text = "\(currentMaxRotZ).2f"
        
    }
    
}

