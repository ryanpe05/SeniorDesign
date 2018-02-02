//
//  SecondViewController.swift
//  PocketProtectorV2
//
//  Created by Ryan Peck on 2/2/18.
//  Copyright © 2018 Ryan Peck. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class SecondViewController: UIViewController {
    
    var currStatus = "Safe"
    let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 21))
    let nameSpace = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 21))
    let contactLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 21))
    let contactSpace = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 21))
    let saveButton = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 21))
    var name = "User2"
    var number = "111-111-1111"
    
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
        recent.setValue(contactSpace.text, forKeyPath: "eNumber")
        recent.setValue(nameSpace.text, forKeyPath: "name")
        recent.setValue(currStatus, forKeyPath: "safe")
        
        do {
            try managedContext.save()
            print(recent.value(forKey: "name") as! String)
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    func returnTapped(sender: UIButton){
        saveRecent()
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "Default")
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let myColor = UIColor.black
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = delegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Identity")
        do{
            let information = try managedContext.fetch(fetchRequest)
            for person in information{ //there should only ever be one person
                name = person.value(forKeyPath: "name") as! String
                number = person.value(forKeyPath: "eNumber") as! String
            }
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        // Greeting Label
        let greeting = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        greeting.center = CGPoint(x: self.view.frame.size.width / 2, y: 285)
        greeting.textAlignment = .center
        greeting.text = "Adjust Settings"
        self.view.addSubview(greeting)
        // Name Label
        nameLabel.center = CGPoint(x: self.view.frame.size.width / 2 - 100, y: 350)
        nameLabel.textAlignment = .center
        nameLabel.text = "Your current name is: "
        self.view.addSubview(nameLabel)
        // Name entering space
        nameSpace.center = CGPoint(x: self.view.frame.size.width / 2 + 100, y: 350)
        nameSpace.text = name
        nameSpace.layer.borderColor = myColor.cgColor
        nameSpace.layer.borderWidth = 1.0
        self.view.addSubview(nameSpace)
        // Emergency Contact Label
        contactLabel.center = CGPoint(x: self.view.frame.size.width / 2 - 100, y: 425)
        contactLabel.textAlignment = .center
        contactLabel.text = "Current Contact is: "
        self.view.addSubview(contactLabel)
        // Emergency contact entering space
        contactSpace.center = CGPoint(x: self.view.frame.size.width / 2 + 100, y: 425)
        contactSpace.text = number
        contactSpace.layer.borderColor = myColor.cgColor
        contactSpace.layer.borderWidth = 1.0
        self.view.addSubview(contactSpace)
        // Return Button
        saveButton.layer.cornerRadius = 5
        saveButton.center = CGPoint(x: self.view.frame.size.width / 2, y: 575)
        saveButton.setTitle("Save", for: .normal)
        saveButton.contentHorizontalAlignment = .center
        saveButton.backgroundColor = UIColor.blue
        self.view.addSubview(saveButton)
        saveButton.addTarget(self, action: #selector(returnTapped(sender:)), for: .touchUpInside)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
