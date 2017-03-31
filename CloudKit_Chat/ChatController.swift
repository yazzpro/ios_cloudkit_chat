//
//  SecondViewController.swift
//  CloudKit_Chat
//
//  Created by Jarosław Pawlak on 13.03.2017.
//  Copyright © 2017 Jarosław Pawlak. All rights reserved.
//

import UIKit
import CloudKit

class ChatController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var otherPerson: CKUserIdentity?
    var currentUser: CKRecord?
    var cloud: CloudController?
    var records: [CKRecord]?
    var kbVisible = false
    @IBOutlet weak var newMessageText: UITextField!
    @IBAction func sendMessageAction(_ sender: Any) {
        cloud?.sendMessage(from: (currentUser?.recordID)!, to: (otherPerson?.userRecordID)!, message: newMessageText.text!){ (record) in
            self.records?.append(record)
            self.tableView.reloadData()
            self.newMessageText.text = ""
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        cloud = CloudController()

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: .UIKeyboardWillShow , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: .UIKeyboardWillHide , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.newMessageArrived(userData:)), name: NSNotification.Name(rawValue: "IncomingMessage"), object: nil)
        //NotificationCenter.default.post(name: "IncomingMessage", object: nil, userInfo: notification.recordFields)
        
        refreshMessages()
                self.title = otherPerson?.nameComponents?.givenName
                // Do any additional setup after loading the view, typically from a nib.
    }

    func refreshMessages()
    {
        cloud?.getMessages(user1: (currentUser?.recordID)!, user2: (otherPerson?.userRecordID)!,  callback: { (records) in
            self.records = records
            self.tableView.reloadData()
            var lastId = self.records?.count
            var ip = IndexPath(row: lastId!-1, section: 0)
            if ip.row > 0
            {
                self.tableView.scrollToRow(at: ip, at: UITableViewScrollPosition.bottom, animated: true)
            }
            
            
        })

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let record = self.records?[indexPath.row];
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Message");
        cell?.textLabel?.text = record!["message"] as! String?
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let u = self.records
        {
            return u.count
        }
        return 0
    }
    
    func keyboardWillShow(_ notification: NSNotification) {
        if kbVisible
        {
            return
        }
        kbVisible = true
        print("keyboard will show!")
        
        // To obtain the size of the keyboard:
        let keyboardSize:CGSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
        let f = self.view.frame
        self.view.frame = CGRect(x: f.origin.x, y: f.origin.y, width: f.size.width, height: f.size.height - keyboardSize.height )
        
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        if (!kbVisible)
        {
            return
        }
        kbVisible = false
        print("Keyboard will hide!")
        let keyboardSize:CGSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
        let f = self.view.frame
        self.view.frame = CGRect(x: f.origin.x, y: f.origin.y, width: f.size.width,  height:f.size.height + keyboardSize.height )
    }
    func newMessageArrived(userData: NSNotification)
    {
        if let info = userData.userInfo
        {
            if info["from"] as! String? == otherPerson?.userRecordID?.recordName
            {
                DispatchQueue.main.async {
                    self.refreshMessages()
                }
                
            }
        }
    }
}

