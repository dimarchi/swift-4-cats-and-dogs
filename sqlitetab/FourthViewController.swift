//
//  FourthViewController.swift
//  sqlitetab
//
//  Created by Koulutus on 01/11/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

class FourthViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var dbPath : URL?
    var owners: [[String]] = []

    var catID : String = ""
    var catName : String = ""
    var catBreed : String = ""
    var catBirth : String = ""
    var catDeath : String = ""
    var catOwner : String = ""
    var catNotificationID : String = "0"
    
    @IBOutlet weak var catIdField: UILabel!
    @IBOutlet weak var catNameField: UITextField!
    @IBOutlet weak var catBreedField: UITextField!
    
    @IBOutlet weak var catDateBirthPicker: UIDatePicker!
    @IBAction func catBirthPick(_ sender: UIDatePicker) {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        catBirth = dateFormat.string(from: catDateBirthPicker.date)
        NSLog(catBirth)
    }
    
    @IBOutlet weak var catDateDeathPicker: UIDatePicker!
    @IBAction func catDeathPick(_ sender: UIDatePicker) {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        catDeath = dateFormat.string(from: catDateDeathPicker.date)
        NSLog(catDeath)
    }
    
    @IBOutlet weak var catOwnerPicker: UIPickerView!
    
    @IBAction func catAddButton(_ sender: Any) {
        addCat()
    }
    
    @IBAction func catDeleteButton(_ sender: UIButton) {
        deleteCat(path: dbPath!, val: [catNotificationID])
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
        NSLog((dbPath?.absoluteString)!)
        
        owners = ownerQuery(path: dbPath!)
        
        catOwnerPicker.delegate = self
        catOwnerPicker.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(getNotificationID(notification:)), name: .catID, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        owners = ownerQuery(path: dbPath!)
        getCat(path: dbPath!, val: catNotificationID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearText()
    }
    
    @objc func getNotificationID(notification : Notification)
    {
        let thisID = notification.userInfo?["id"] as? String
        catNotificationID = thisID!
        NSLog("cat notification id: " + thisID!)
    }
    
    func clearText()
    {
        catIdField.text = ""
        catNameField.text = ""
        catBreedField.text = ""
        catDateBirthPicker.setDate(Date(), animated: true)
        catDateDeathPicker.setDate(Date(), animated: true)
        catNotificationID = "0"
    }
    
    func addCat()
    {
        catID = catIdField.text!
        catName = catNameField.text!
        catBreed = catBreedField.text!
        NSLog("cat owner's id: " + catOwner)
        
        var passingValidation : Bool = false
        
        passingValidation = validationAlert()
        
        if (passingValidation)
        {
            if (catNotificationID == "0")
            {
                addNewCat(path: dbPath!, val: [catName, catBreed, catBirth, catDeath])
                tabBarController?.selectedIndex = 1
            }
            else
            {
                if (catNotificationID != "")
                {
                    updateOldCat(path: dbPath!, val: [catName, catBreed, catBirth, catDeath, catID])
                    tabBarController?.selectedIndex = 1
                }
            }
        }
    }
    
    func addNewCat(path: URL, val: Array<Any>)
    {
        // insert into cat (name,breed,datebirth,datedeath) values ('Galileo','katukissa', '1990-01-01', '');"
        let sql = "insert into cat (name, breed, datebirth, datedeath) values (?, ?, ?, ?)"
        let connection = FMDatabase(path: path.absoluteString)
        if (connection.open())
        {
            try! connection.executeUpdate(sql, values: val)
        }
        connection.close()
    }
    
    func updateOldCat(path: URL, val: Array<Any>)
    {
        let sql = "update cat set name = ?, breed = ?, datebirth = ?, datedeath = ? where id = ?;"
        let connection = FMDatabase(path: path.absoluteString)
        if (connection.open())
        {
            try! connection.executeUpdate(sql, values: val)
        }
        connection.close()
    }
    
    func getCat(path: URL, val: String)
    {
        NSLog("getCat id: " + val)
        if val == "0"
        {
            return
        }
        
        let sql = "select * from cat where id = ?;"
        let connection = FMDatabase(path: path.absoluteString)
        var result = FMResultSet()
        
        if (connection.open())
        {
            result = connection.executeQuery(sql, withArgumentsIn: [val])!
            
            while result.next()
            {
                catIdField.text = result.string(forColumn: "id")
                catNameField.text = result.string(forColumn: "name")
                catBreedField.text = result.string(forColumn: "breed")
                catBirth = result.string(forColumn: "datebirth")!
                catDeath = result.string(forColumn: "datedeath")!
                
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "yyyy-MM-dd"
                if let dateBirth = dateFormat.date(from: catBirth)
                {
                    catDateBirthPicker.date = dateBirth
                }
                
                if let dateDeath = dateFormat.date(from: catDeath)
                {
                    catDateDeathPicker.date = dateDeath
                }
            }
        }
        connection.close()
    }
    
    func deleteCat(path: URL, val: Array<Any>)
    {
        let sql = "delete from cat where id = ?;"
        let connection = FMDatabase(path: path.absoluteString)
        
        if (connection.open())
        {
            try! connection.executeUpdate(sql, values: val)
        }
        connection.close()
    }
    
    func ownerQuery(path: URL) -> [[String]]
    {
        let sql = "select id, firstname, familyname from person"
        let connection = FMDatabase(path: path.absoluteString)
        var result = FMResultSet()
        var data : [[String]] = []
        
        data.append(["0", "No owner"])
        
        if (connection.open())
        {
            result = try! connection.executeQuery(sql, values: nil)
            
            while result.next()
            {
                let id = result.string(forColumn: "id")
                let firstName = result.string(forColumn: "firstname")
                let lastName = result.string(forColumn: "familyname")
                let fullName = firstName! + " " + lastName!
                data.append([id!, fullName])
                
            }
        }
        connection.close()
        return data
    }
    
    func validationAlert() -> Bool
    {
        let catName = catNameField.text
        
        var validation : Bool = false
        
        if (catName == "")
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return owners.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return owners[row][1]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        NSLog("selected cat owner: " + owners[row][0])
        catOwner = owners[row][0]
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
