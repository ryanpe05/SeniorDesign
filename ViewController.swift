//
//  ViewController.swift
//  PocketProtectorV2
//
//  Created by Ryan Peck on 2/2/18.
//  Copyright © 2018 Ryan Peck. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import CoreBluetooth


class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var currStatus = "Safe"
    let status = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 21))
    let panic = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 21))
    let settings = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 21))
    var name = "User"
    var number = "111-111-1111"
    var manager:CBCentralManager!
    let scanningDelay = 1.0
    
    
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
        }
        saveRecent()
        status.text = "Your current status is: " + currStatus
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
        greeting.center = CGPoint(x: self.view.frame.size.width / 2, y: 285)
        greeting.textAlignment = .center
        greeting.text = "Hello " + name
        self.view.addSubview(greeting)
        // Status Label
        status.center = CGPoint(x: self.view.frame.size.width / 2, y: 350)
        status.textAlignment = .center
        status.text = "Your current status is: " + currStatus
        self.view.addSubview(status)
        // Emergency Contact Label
        let contact = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 21))
        contact.center = CGPoint(x: self.view.frame.size.width / 2, y: 425)
        contact.textAlignment = .center
        contact.text = "Current Contact is: " + number
        self.view.addSubview(contact)
        // Panic Button
        panic.layer.cornerRadius = 5
        panic.center = CGPoint(x: self.view.frame.size.width / 2, y: 500)
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
        settings.center = CGPoint(x: self.view.frame.size.width / 2, y: 575)
        settings.setTitle("Change Settings", for: .normal)
        settings.contentHorizontalAlignment = .center
        settings.backgroundColor = UIColor.blue
        self.view.addSubview(settings)
        settings.addTarget(self, action: #selector(settingsTapped(sender:)), for: .touchUpInside)
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
        
        
    }
    
    func didReadPeripheral(_ peripheral: CBPeripheral, rssi: NSNumber){
        
        if let name = peripheral.name{
            print(name)
        }
        
        delay(scanningDelay){
            peripheral.readRSSI()
        }
        
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
