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
    
    func sendMessage( from : CKRecordID, to: CKRecordID, message: String)
    {
         let container = CKContainer.default()
        
    }
    
    func getMessages ( user: CKRecordID)
    {
        
    }
}
