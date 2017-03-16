//
//  SecondViewController.swift
//  CloudKit_Chat
//
//  Created by Jarosław Pawlak on 13.03.2017.
//  Copyright © 2017 Jarosław Pawlak. All rights reserved.
//

import UIKit
import CloudKit

class ChatController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var otherPerson: CKUserIdentity?
    var currentUser: CKRecord?
    var cloud: CloudController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cloud = CloudController()
        self.title = otherPerson?.nameComponents?.givenName
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

