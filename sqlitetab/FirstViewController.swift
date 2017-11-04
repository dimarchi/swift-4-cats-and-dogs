//
//  FirstViewController.swift
//  sqlitetab
//
//  Created by Koulutus on 01/11/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

extension Notification.Name
{
    static let ownerID = Notification.Name("ownerID")
}

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var owners: [[String]] = []
    var dbPath : URL?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return owners.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ownerCellReuseIdentifier") as! OwnerTableViewCell
        let ownerID = owners[indexPath.row][0]
        let ownerName = owners[indexPath.row][1]
        cell.ownerIdLabel?.text = ownerID
        cell.ownerNameLabel?.text = ownerName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = indexPath.item
        let selectedOwnerID = owners[selectedItem][0]
        NSLog("Owner page selected id: " + selectedOwnerID)
        
        let UserDict: [String : String] = ["id" : selectedOwnerID]
        NotificationCenter.default.post(name: .ownerID, object: nil, userInfo: UserDict)
        
        sleep(1)
        tabBarController?.selectedIndex = 2
    }
    
    @IBOutlet weak var ownerTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // using default filemanager
        // FileManager.default
        // find path to database by finding document directory first
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        // the path to db location is set into document directory root
        // and name of db is set
        let dbName : String = "cats.sqlite"
        dbPath = path[0].appendingPathComponent(dbName, isDirectory: false)
        NSLog((dbPath?.absoluteString)!)
        
        if !FileManager.default.fileExists(atPath: (dbPath?.absoluteString)!)
        {
            // no db found, must be created
            executeQuery(path: dbPath!, sqlStatement: "create table if not exists person (id integer primary key autoincrement, firstname text, familyname text, phone integer);")
            executeQuery(path: dbPath!, sqlStatement: "create table if not exists cat (id integer primary key autoincrement, name text, breed text, datebirth date, datedeath date);")
            executeQuery(path: dbPath!, sqlStatement: "create table if not exists ownership (id integer primary key autoincrement, ownerid integer, catid integer, datebegin date, dateend date, ownership bit, foreign key (ownerid) references person(id), foreign key (catid) references cat(id));")
             /*
            // inserts some preliminary data for testing
            executeQuery(path: dbPath!, sqlStatement: "insert into person (firstname, familyname) values ('Janne','Kemppi');")
            executeQuery(path: dbPath!, sqlStatement: "insert into person (firstname, familyname) values ('Sari','Kemppi');")
            executeQuery(path: dbPath!, sqlStatement: "insert into person (firstname, familyname) values ('Sanna','Kemppi');")
            executeQuery(path: dbPath!, sqlStatement: "insert into person (firstname, familyname) values ('Anne','Kemppi');")
            executeQuery(path: dbPath!, sqlStatement: "insert into cat (name,breed,datebirth,datedeath) values ('Jenny','katukissa', '1990-01-01', '2017-11-23');")
            executeQuery(path: dbPath!, sqlStatement: "insert into cat (name,breed,datebirth,datedeath) values ('Galileo','katukissa', '1990-01-01', '');")
            executeQuery(path: dbPath!, sqlStatement: "insert into ownership (ownerid, catid, datebegin, dateend, ownership) values (1, 1, '1990-01-01', '2017-11-23', 0)")
            executeQuery(path: dbPath!, sqlStatement: "insert into ownership (ownerid, catid, datebegin, dateend, ownership) values (1, 2, '1990-01-01', '', 1)")
            */
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        owners = ownerQuery(path: dbPath!)
        ownerTableView.dataSource = self
        ownerTableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        owners = ownerQuery(path: dbPath!)
        ownerTableView.reloadData()
    }
 
    func executeQuery(path: URL, sqlStatement : String)
    {
        let connection = FMDatabase(path: path.absoluteString)
        if (connection.open())
        {
            connection.executeStatements(sqlStatement)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

