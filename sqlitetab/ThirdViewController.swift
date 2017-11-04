//
//  ThirdViewController.swift
//  sqlitetab
//
//  Created by Koulutus on 01/11/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {
    
    var dbPath : URL?
    var ownersId : String = ""
    var ownersFirstName : String = ""
    var ownersLastName : String = ""
    var ownersPhone : String = ""
    var ownerNotificationID : String = "0"

    @IBOutlet weak var ownerIdField: UILabel!
    @IBOutlet weak var ownerFirstNameField: UITextField!
    @IBOutlet weak var ownerLastNameField: UITextField!
    @IBOutlet weak var ownerPhoneField: UITextField!
    
    @IBAction func ownerAddButton(_ sender: UIButton) {
        ownersId = ownerIdField.text!
        ownersFirstName = ownerFirstNameField.text!
        ownersLastName = ownerLastNameField.text!
        ownersPhone = ownerPhoneField.text!
        
        var passingValidation : Bool = false
        
        passingValidation = validationAlert()
        
        if (passingValidation)
        {
            if ( ownerNotificationID == "0")
            {
                if (ownersFirstName != "" && ownersLastName != "" && ownersPhone != "")
                {
                    addOwner(path: dbPath!, val: [ownersFirstName, ownersLastName, ownersPhone])
                }
            }
            else
            {
                if (ownerNotificationID != "")
                {
                    if (ownersFirstName != "" && ownersLastName != "" && ownersPhone != "")
                    {
                        updateOwner(path: dbPath!, val: [ownersFirstName, ownersLastName, ownersPhone, ownersId])
                    }
                }
            }
            clearText()
            sleep(1)
            tabBarController?.selectedIndex = 0
        }
    }
    
    @IBAction func ownerDeleteButton(_ sender: UIButton) {
         if (ownerNotificationID != "0")
         {
            let sql = "delete from person where id = ?;"
            let connection = FMDatabase(path: dbPath?.absoluteString)
         if (connection.open())
         {
            try! connection.executeUpdate(sql, values: [ownerNotificationID])
         }
         connection.close()
         }
        clearText()
        sleep(1)
        tabBarController?.selectedIndex = 0
    }
    
    @IBAction func clearButton(_ sender: UIButton) {
        clearText()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // using default filemanager
        // FileManager.default
        // find path to database by finding document directory first
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        // the path to db location is set into document directory root
        // and name of db is set
        let dbName : String = "cats.sqlite"
        dbPath = path[0].appendingPathComponent(dbName, isDirectory: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(getNotificationID(notification:)), name: .ownerID, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getOwner(path: dbPath!, val: ownerNotificationID)
    }
    
    @objc func getNotificationID(notification : Notification)
    {
        let thisID = notification.userInfo?["id"] as? String
        ownerNotificationID = thisID!
        NSLog("notification id: " + thisID!)
    }
    
    func clearText()
    {
        ownerIdField.text = ""
        ownerFirstNameField.text = ""
        ownerLastNameField.text = ""
        ownerPhoneField.text = ""
        ownerNotificationID = "0"
    }
    
    func validationAlert() -> Bool
    {
        let firstName = ownerFirstNameField.text
        let lastName = ownerLastNameField.text
        let phone = ownerPhoneField.text
        
        var validation : Bool = false
        
        if (firstName == "" || lastName == "" || phone == "")
        {
            let alert = UIAlertController(title: "Missing data", message: "Some of the required infromation was not provided.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            {
                (action: UIAlertAction!) in
                DispatchQueue.main.async {
                    NSLog("Validation failed.")
                }
                
            }
            
            alert.addAction(okAction)
            
            
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            validation = true
        }
        return validation
    }
    
    func getOwner(path: URL, val: String)
    {
        NSLog("getOwner id: " + val)
        if val == "0"
        {
            return
        }
        
        let sql = "select * from person where id = ?;"
        let connection = FMDatabase(path: path.absoluteString)
        var result = FMResultSet()
        
        if (connection.open())
        {
            result = connection.executeQuery(sql, withArgumentsIn: [val])!
            
            while result.next()
            {
                ownerIdField.text = result.string(forColumn: "id")
                ownerFirstNameField.text = result.string(forColumn: "firstname")
                ownerLastNameField.text = result.string(forColumn: "familyname")
                ownerPhoneField.text = result.string(forColumn: "phone")
            }
        }
        connection.close()
    }
    
    func addOwner(path: URL, val: Array<Any>)
    {
        let sql = "insert into person (firstname, familyname, phone) values (?, ?, ?);"
        let connection = FMDatabase(path: path.absoluteString)
        if (connection.open())
        {
            try! connection.executeUpdate(sql, values: val)
        }
        connection.close()
        clearText()
        sleep(1)
        tabBarController?.selectedIndex = 0
    }
    
    func updateOwner(path: URL, val: Array<Any>)
    {
        let sql = "update person set firstname = ?, familyname = ?, phone = ? where id = ?;"
        let connection = FMDatabase(path: path.absoluteString)
        if (connection.open())
        {
            try! connection.executeUpdate(sql, values: val)
        }
        connection.close()
        clearText()
        sleep(1)
        tabBarController?.selectedIndex = 0
    }
/*
    func idNotification(_ notification : Notification)
    {
        ownerNotificationID = (notification.userInfo?["id"] as? String)!
    }
*/
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
