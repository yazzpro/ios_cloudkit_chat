//
//  FirstViewController.swift
//  CloudKit_Chat
//
//  Created by Jarosław Pawlak on 13.03.2017.
//  Copyright © 2017 Jarosław Pawlak. All rights reserved.
//

import UIKit
import CloudKit

class ContactsController: UIViewController, UITableViewDataSource, UITableViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var imagePicker: UIImagePickerController?
    
    @IBAction func assignPhoto(_ sender: Any) {
        present(imagePicker!, animated:true, completion:nil)
    }
    @IBOutlet weak var tableView: UITableView!
    var cloud: CloudController?
    var users: [CKUserIdentity]?
    var currentUser: CKRecord?
    
    override func viewDidLoad() {
        super.viewDidLoad()
          NotificationCenter.default.addObserver(self, selector: #selector(self.newMessageArrived(userData:)), name: NSNotification.Name(rawValue: "IncomingMessage"), object: nil)
       if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
       {
        imagePicker = UIImagePickerController()
        imagePicker!.delegate = self
        imagePicker!.sourceType = .camera
        }
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let user = self.users?[indexPath.row];
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as? ContactTableViewCell;
        cell?.TitleLabel.text = String.init(format: "%@ %@", user!.nameComponents!.givenName!, user!.nameComponents!.familyName!)
        cell?.PhotoView.addGestureRecognizer(tapGesture)
        cell?.PhotoView.isUserInteractionEnabled = true
        cloud?.fetchUserPhoto(record: (user?.userRecordID)!, callback: { (image) in
            cell?.PhotoView.image = image
            
        })
        return cell!
        
    }
    var imageToShowBig : UIImage?
    func imageTapped(_ gesture: UIGestureRecognizer)
    {
        if let iView = gesture.view as? UIImageView
        {
          self.imageToShowBig = iView.image
        }
        
        performSegue(withIdentifier: "ShowImage", sender: self)
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
            let d = segue.destination as! ChatController
            d.currentUser = self.currentUser
            d.otherPerson = self.users![ip!.row]
        }
        if (segue.identifier == "ShowImage")
        {
            var d = segue.destination as! ProfileImageController
            d.setImage(image: self.imageToShowBig)
        }
        
    }
    func newMessageArrived(userData: NSNotification)
    {
        if let info = userData.userInfo
        {
            if let from = info["from"] as? String
            {
                if let us = self.users
                {
                    for (index,id) in us.enumerated()
                    {
                        if (id.userRecordID?.recordName == from)
                        {
                            DispatchQueue.main.async {
                                self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.middle)
                            }
                        }
                    }
                }
               
                
            }
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        imagePicker!.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            cloud?.savePhoto(image)
        }
    }


}

