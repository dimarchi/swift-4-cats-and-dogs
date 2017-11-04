//
//  FourthViewController.swift
//  sqlitetab
//
//  Created by Koulutus on 01/11/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

class FourthViewController: UIViewController {
    
    var dbPath : URL?
    var catName : String?
    var catBreed : String?
    var catBirth : String?
    var catDeath : String?
    var catOwner : String?
    
    @IBOutlet weak var catIdField: UILabel!
    @IBOutlet weak var catNameField: UITextField!
    @IBOutlet weak var catBreedField: UITextField!
    
    @IBOutlet weak var catDateBirthPicker: UIDatePicker!
    @IBAction func catBirthPick(_ sender: UIDatePicker) {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        let date = Date()
        let dateString = dateFormat.string(from: date)
        NSLog(dateString)
    }
    
    @IBOutlet weak var catDateDeathPicker: UIDatePicker!
    @IBAction func catDeathPick(_ sender: UIDatePicker) {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        let date = Date()
        let dateString = dateFormat.string(from: date)
        NSLog(dateString)
    }
    
    @IBOutlet weak var catOwnerPicker: UIPickerView!
    
    @IBAction func catAddButton(_ sender: Any) {
        
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
    }
    
    func addCat(path: URL, val: Array<Any>)
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
