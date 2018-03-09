//
//  ViewController.swift
//  PocketProtectorV2
//
//  Created by Ryan Peck on 2/2/18.
//  Copyright © 2018 Ryan Peck. All rights reserved.
//
// Bluetooth code credit to

import UIKit
import CoreData
import Foundation
import CoreBluetooth
import MessageUI
import SendBirdSDK
import MapKit
import CoreLocation

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, SBDChannelDelegate, CLLocationManagerDelegate{

    // add this if using text MFMessageComposeViewControllerDelegate
    
    let locationManager = CLLocationManager() //GPS manager
    let delegateIdentifier = "1100" //id for message sent
    var currStatus = "Safe"
    let status = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 21))
    let panic = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 21))
    let settings = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 21))
    var name = "User"
    var number = "111-111-1111"
    var manager:CBCentralManager!
    let scanningDelay = 1.0
    var bluetoothObjects = [[Any]]()
    var detectedPeripheral: CBPeripheral?
    var latitude = 1.0
    var longitude = 1.0
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        latitude = locValue.latitude
        longitude = locValue.longitude
    }
    
    func saveRecent() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Identity",
                                                in: managedContext)!
        
        let recent = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Identity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.execute(deleteRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        recent.setValue(number, forKeyPath: "eNumber")
        recent.setValue(name, forKeyPath: "name")
        recent.setValue(currStatus, forKeyPath: "safe")
        
        do {
            try managedContext.save()
            print(recent.value(forKey: "name") as! String)
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func panicTapped(sender: UIButton) {
        if(currStatus == "Panic"){
            currStatus = "Safe"
            panic.setTitle("Panic", for: .normal)
            panic.backgroundColor = UIColor.red
        }
        else{
            currStatus = "Panic"
            panic.setTitle("Safe", for: .normal)
            panic.backgroundColor = UIColor.green
            sendEText()
        }
        saveRecent()
        status.text = "Your current status is: " + currStatus
    }
    
    func sendEText(){
//        let controller = MFMessageComposeViewController()
//        controller.body = "Hello Neil. This was sent from the Senior Design App"
//        manipulateNumber()
//        controller.recipients = [number]
//        controller.messageComposeDelegate = self
        var customMessage = "Hello Neil. My current location is: "
        customMessage.append(String(latitude))
        customMessage.append(" , ")
        customMessage.append(String(longitude))
        SBDOpenChannel.getWithUrl("distress_signal_activate") { (channel, error) in
            if error != nil {
                NSLog("Error: %@", error!)
                return
            }
            
            channel?.enter(completionHandler: { (error) in
                if error != nil {
                    NSLog("Error: %@", error!)
                    return
                }
                
                channel?.sendUserMessage(customMessage, data: nil, completionHandler: { (userMessage, error) in
                    if error != nil {
                        NSLog("Error: %@", error!)
                        return
                    }
                    
                    print(userMessage ?? "can't cast")
                    print("was sent")
                    
                })
                
                let previousMessageQuery = channel?.createPreviousMessageListQuery()
                previousMessageQuery?.loadPreviousMessages(withLimit: 30, reverse: true, completionHandler: { (messages, error) in
                    if error != nil {
                        NSLog("Error: %@", error!)
                        return
                    }
                    for message in messages!{
                        print(message)
                    }
                })
            })
        }
        //self.present(controller, animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func manipulateNumber(){
        var offset = 0
        for i in 0...number.count-1{
            let ind = number.index(number.startIndex, offsetBy: i-offset)
            if (number[ind] < "0" || number[ind] > "9"){
                number.remove(at: ind)
                offset = offset + 1
            }
        }
        print(number)
    }
    
    func settingsTapped(sender: UIButton){
        saveRecent()
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "Settings")
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("We are live")
        manager = CBCentralManager(delegate: self, queue: nil)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = delegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Identity")
        do{
            let information = try managedContext.fetch(fetchRequest)
            for person in information{ //there should only ever be one person
                name = person.value(forKeyPath: "name") as! String
                number = person.value(forKeyPath: "eNumber") as! String
                currStatus = person.value(forKeyPath: "safe") as! String
            }
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        // Greeting Label
        let greeting = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        greeting.center = CGPoint(x: self.view.frame.size.width / 2, y: 85)
        greeting.textAlignment = .center
        greeting.text = "Hello " + name
        self.view.addSubview(greeting)
        // Status Label
        status.center = CGPoint(x: self.view.frame.size.width / 2, y: 150)
        status.textAlignment = .center
        status.text = "Your current status is: " + currStatus
        self.view.addSubview(status)
        // Emergency Contact Label
        let contact = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 21))
        contact.center = CGPoint(x: self.view.frame.size.width / 2, y: 225)
        contact.textAlignment = .center
        contact.text = "Current Contact is: " + number
        self.view.addSubview(contact)
        // Panic Button
        panic.layer.cornerRadius = 5
        panic.center = CGPoint(x: self.view.frame.size.width / 2, y: 300)
        if(currStatus == "Safe"){
            panic.setTitle("Panic", for: .normal)
            panic.backgroundColor = UIColor.red
        }else{
            panic.setTitle("Safe", for: .normal)
            panic.backgroundColor = UIColor.green
        }
        panic.contentHorizontalAlignment = .center
        self.view.addSubview(panic)
        panic.addTarget(self, action: #selector(panicTapped(sender:)), for: .touchUpInside)
        // Settings Button
        settings.layer.cornerRadius = 5
        settings.center = CGPoint(x: self.view.frame.size.width / 2, y: 375)
        settings.setTitle("Change Settings", for: .normal)
        settings.contentHorizontalAlignment = .center
        settings.backgroundColor = UIColor.blue
        self.view.addSubview(settings)
        settings.addTarget(self, action: #selector(settingsTapped(sender:)), for: .touchUpInside)
        // Connect to messaging service
        SBDMain.connect(withUserId: name, completionHandler: {(user, error) in
            if(error != nil){
                NSLog("Error: %@", error!)
                return
            }
            else{
                print("SBD connection successful")
            }
        })
        SBDMain.add(self as SBDChannelDelegate, identifier: delegateIdentifier)
        
        // location manager asks for permission
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            print("trying GPS")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        if central.state == .poweredOn{
            manager.scanForPeripherals(withServices: nil, options: nil)
            print("scanning")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        print("i see something")
        didReadPeripheral(peripheral, rssi: RSSI)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        
        didReadPeripheral(peripheral, rssi: RSSI)
        
        delay(scanningDelay){
            peripheral.readRSSI()
        }
        
    }
    
    func didReadPeripheral(_ peripheral: CBPeripheral, rssi: NSNumber){
        
        if let deviceName = peripheral.name{
            for item in bluetoothObjects{
                if((item[0] as! String).contains(deviceName)){
                    
                }else{
                    bluetoothObjects.append([deviceName, rssi])
                }
            }
            print(deviceName)
            detectedPeripheral = peripheral
            if let detectedPeripheral = detectedPeripheral{
                detectedPeripheral.delegate = self
                if(deviceName == "Adafruit Bluefruit LE"){
                    print("trying to connect")
                    manager.connect(detectedPeripheral, options: nil)
                }
            }
            manager.stopScan()
        }
        print(bluetoothObjects)
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral){
        peripheral.readRSSI()
        print("Connected to bluetooth")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
