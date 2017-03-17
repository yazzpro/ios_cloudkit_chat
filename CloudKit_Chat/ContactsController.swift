//
//  FirstViewController.swift
//  CloudKit_Chat
//
//  Created by Jarosław Pawlak on 13.03.2017.
//  Copyright © 2017 Jarosław Pawlak. All rights reserved.
//

import UIKit
import CloudKit

class ContactsController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var cloud: CloudController?
    var users: [CKUserIdentity]?
    var currentUser: CKRecord?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cloud = CloudController()
        cloud?.fetchCurrentUser(callback: { currentUser in
            self.currentUser = currentUser
            self.cloud?.subscribeToMessages(user: currentUser.recordID)
            self.cloud?.requestDiscoverability {
                self.cloud?.discoverAppUsers(callback: { (users) in
                    self.users = users
                    DispatchQueue.main.async {
                        self.tableView!.reloadData()
                    }
                })
 
            }
        })

            // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let user = self.users?[indexPath.row];
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell");
        cell?.textLabel?.text = user?.nameComponents?.description
        return cell!
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let u = self.users
        {
            return u.count
        }
        return 0
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowChat")
        {
            var ip = self.tableView.indexPathForSelectedRow
            var d = segue.destination as! ChatController
            d.currentUser = self.currentUser
            d.otherPerson = self.users![ip!.row]
        }
        
    }

}

