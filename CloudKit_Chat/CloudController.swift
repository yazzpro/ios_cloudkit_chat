//
//  MessageHandler.swift
//  CloudKit_Chat
//
//  Created by Jarosław Pawlak on 14.03.2017.
//  Copyright © 2017 Jarosław Pawlak. All rights reserved.
//

import Foundation
import CloudKit

class CloudController
{
    func fetchCurrentUser(callback: @escaping (CKRecord)-> Void)
    {
        let container = CKContainer.default()
        container.fetchUserRecordID { (record, error) in
            if let responseError = error {
                print (responseError)
            }
            else if let userRecordId =  record
            {
                DispatchQueue.main.async(execute: { ()->Void in
                    self.fetchUserRecord(recordId: userRecordId, callback: callback)
                })
            }
        }
    
    }
    
    func fetchUserRecord(recordId : CKRecordID, callback: @escaping (CKRecord)-> Void)
    {
        let defaultContainer = CKContainer.default()
        let privateDatabase = defaultContainer.privateCloudDatabase
        
        privateDatabase.fetch(withRecordID: recordId) { (record, error) in
            if let err = error
            {
                print (err)
            }
            if let r = record
            {
                DispatchQueue.main.async(execute: { ()->Void in
                    callback(r)
                })
            }
        }
    }
    func fetchPublicUserRecord(recordId : CKRecordID, callback: @escaping (CKUserIdentity)-> Void)
    {
        let defaultContainer = CKContainer.default()
        //let db = defaultContainer.publicCloudDatabase
        
        defaultContainer.discoverUserIdentity(withUserRecordID: recordId) { (user, error) in
            DispatchQueue.main.async(execute: { ()->Void in
                callback(user!)
            })
        }
    }
    func discoverAppUsers(callback:  @escaping ([CKUserIdentity]?) -> Void)
    {
        let container = CKContainer.default()
        
        
        
        container.discoverAllIdentities{  (userIdentity, error) -> Void in
            callback(userIdentity)
        }
        
    }
    
    func requestDiscoverability(callback: @escaping ()-> Void)
    {
        let container = CKContainer.default()
        var permissions = CKApplicationPermissions()
        
        container.requestApplicationPermission(CKApplicationPermissions.userDiscoverability) { (status, error) in
            if let e = error
            {
                print(e)
            }
            print (status)
            callback();
            
        }
    }
    
    func sendMessage( from : CKRecordID, to: CKRecordID, message: String, callback: @escaping (CKRecord) -> Void)
    {
         let container = CKContainer.default()
         let db = container.publicCloudDatabase
        let record = CKRecord(recordType: "Message")
        record["from"] = CKReference(recordID: from, action: CKReferenceAction.deleteSelf)
        record["to"] = CKReference(recordID: to, action: CKReferenceAction.deleteSelf)
        record["message"] = message as NSString
        record["timestamp"] = NSDate()
        db.save(record) { (record, error) in
            if let e = error
            {
                print (e)
            }
            DispatchQueue.main.async {
                callback(record!)
            }
        }
        

    }
    
    func getMessages ( user1: CKRecordID, user2:CKRecordID, callback: @escaping ([CKRecord]?) -> Void)
    {
         let container = CKContainer.default()
         let db = container.publicCloudDatabase
         var predicate = NSPredicate(format: "(from == %@) AND (to == %@)", user1, user2)
         var query = CKQuery(recordType: "Message", predicate: predicate)
        
        db.perform(query, inZoneWith: nil) { (records, error) in
            if let e = error
            {
                print (e)
            }
            predicate = NSPredicate(format: "(to == %@) AND (from == %@)", user1, user2)
            query = CKQuery(recordType: "Message", predicate: predicate)
            db.perform(query, inZoneWith: nil) { (records1, error) in
                if let e = error
                {
                    print (e)
                }

                let allRecords = records! + records1!
                DispatchQueue.main.async(execute: { ()->Void in
                     callback(allRecords.sorted{ ($0["timestamp"] as! Date).compare($1["timestamp"] as! Date) == .orderedAscending})
                })

           
            }
        }
    }
    
    func subscribeToMessages( user: CKRecordID)
    {
         let predicate = NSPredicate(format: "to == %@", user)
        var subscr = CKQuerySubscription(recordType: "message", predicate: predicate, options: CKQuerySubscriptionOptions.firesOnRecordCreation)
        let notification = CKNotificationInfo()
        notification.soundName = "default"
        notification.alertLocalizationKey = "New Message! %@"
        notification.alertLocalizationArgs = ["message"]
        notification.desiredKeys = ["message", "from"]
        subscr.notificationInfo = notification
       
        let container = CKContainer.default()
        let db = container.privateCloudDatabase // gdzie subskrypcje?
        db.fetchAllSubscriptions { (subs, err) in
            for sub in subs!
            {
            db.delete(withSubscriptionID: sub.subscriptionID, completionHandler: { (text, err) in
                if let t = text
                {   print(t)}
                if let e = err
                {print (e)}
            })
            }
        
            db.save(subscr) { (subs, err) in
            if let e = err
            {
                print(e)
            }
            
            }
        }
        
        
    }
}
