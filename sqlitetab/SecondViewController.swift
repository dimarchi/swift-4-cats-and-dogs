//
//  SecondViewController.swift
//  sqlitetab
//
//  Created by Tarmo Turunen on 01/11/2017.
//  Copyright © 2017 Tarmo Turunen. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var cats: [[String]] = []
    var dbPath : URL?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catCellReuseIdentifier") as! CatTableViewCell //1.
        let catID = cats[indexPath.row][0]
        let catName = cats[indexPath.row][1] //2.
        //cell.textLabel?.text = text //3.
        cell.catIdLabel?.text = catID
        cell.catNameLabel.text = catName
        return cell //4.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = indexPath.item
        let selectedCatID = cats[selectedItem][0]
        NSLog("Cat page selected id: " + selectedCatID)
        
        let CatDict: [String : String] = ["id" : selectedCatID]
        NotificationCenter.default.post(name: .catID, object: nil, userInfo: CatDict)
        
        sleep(1)
        tabBarController?.selectedIndex = 3
    }
    

    @IBOutlet weak var catTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // using default filemanager
        // FileManager.default
        // find path to database by finding document directory first
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        // the path to db location is set into document directory root
        // and name of db is set
        let dbName : String = "cats.sqlite"
        dbPath = path[0].appendingPathComponent(dbName, isDirectory: false)
        NSLog((dbPath?.absoluteString)!)
        
        cats = catQuery(path: dbPath!)
        
        catTableView.delegate = self
        catTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cats = catQuery(path: dbPath!)
        catTableView.reloadData()
    }
    
    func catQuery(path: URL) -> [[String]]
    {
        let sql = "select id, name from cat"
        let connection = FMDatabase(path: path.absoluteString)
        var result = FMResultSet()
        var data : [[String]] = []
        
        data.append(["0", "No cat"])
        
        if (connection.open())
        {
            result = try! connection.executeQuery(sql, values: nil)
            
            while result.next()
            {
                let id = result.string(forColumn: "id")
                let name = result.string(forColumn: "name")
                data.append([id!, name!])
                
            }
        }
        connection.close()
        return data
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

