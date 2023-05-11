//
//  UserModel.swift
//  AnyTimeHealthCare
//
//  Created by Emed_Imac on 10/5/17.
//

import Foundation
final class User {
    // Declare our 'sharedInstance' property
    static let sharedInstance = User()
    
    var userID : String = ""
    var accountNumber: String = ""
    var AccountNumber: String = ""
    var Token: String = ""
    var deviceId: String = ""
    var refurl: String = ""
    var name: String = ""
    var Password: String = ""
    var balance: String = ""
    var email: String = ""
    var referral_points: String = ""
    var FullName: String = ""
    var Secret: String = ""
    var AccountID = ""
    
    private init() {
        userID = ""
        accountNumber = ""
        AccountNumber = ""
        Token = ""
        deviceId = ""
        refurl = ""
        AccountID = ""
        
        let isUser : Bool = userAlreadyExist(kUsernameKey: "UserData")
        
        if(isUser) {
            self.fillData()
        }
    }
    
    func storeUserDetails(userData : [String : Any]) {
        UserDefaults.standard.setValue(userData, forKey: "UserData")
        UserDefaults.standard.synchronize()
        self.fillData()
    }
    
    func fillData() {
        let rawData = UserDefaults.standard.value(forKey: "UserData") as! [String : Any]
//        self.setAccountNumber(accountNumber: rawData["AccountNumber"] as! String)
    }
    
    func setAccountNumber(accountNumber : String) {
        UserDefaults.standard.setValue(accountNumber, forKey: "AccountNumber")
        self.accountNumber = UserDefaults.standard.value(forKey: "AccountNumber") as! String
    }
    
    func getContactNumber() -> String {
        if UserDefaults.standard.object(forKey: "UserData") != nil {
            let rawData = UserDefaults.standard.object(forKey: "UserData") as! [String : Any]
            return (rawData["AccountNumber"] as? String ?? "")
        }
        return ""
    }
    
    
    func getUser_token() -> String {
        if UserDefaults.standard.object(forKey: "UserData") != nil {
            let rawData = UserDefaults.standard.object(forKey: "UserData") as! [String : Any]
            print((rawData["Token"] as? String ?? ""))
            return (rawData["Token"] as? String ?? "")
        }
        return ""
    }
    
    func removeUserDetail() {
        UserDefaults.standard.removeObject(forKey: "UserData")
        UserDefaults.standard.removeObject(forKey: "isAlreadyMember")
    }
    
    func getrefurlUrl() -> String{
        if UserDefaults.standard.object(forKey: "UserData") != nil {
            let rawData = UserDefaults.standard.object(forKey: "UserData") as! [String : Any]
            return (rawData["refurl"] as? String ?? "")
        }
        return ""
    }
    
    func getFullName()  -> String{
        if UserDefaults.standard.object(forKey: "UserData") != nil {
            let rawData = UserDefaults.standard.object(forKey: "UserData") as! [String : Any]
            return (rawData["FullName"] as? String ?? "")
        }
        return ""
    }
    
    func getBalance() -> String {
        if UserDefaults.standard.object(forKey: "UserData") != nil {
            let rawData = UserDefaults.standard.object(forKey: "UserData") as! [String : Any]
            return (rawData["balance"] as? String ?? "")
        }
        return ""
    }
    
    func  getsipPassWord() -> String {
        if UserDefaults.standard.object(forKey: "UserData") != nil {
            let rawData = UserDefaults.standard.object(forKey: "UserData") as! [String : Any]
            return (rawData["Secret"] as? String ?? "")
        }
        return ""
    }
    
    func  getAccountID() -> String {
        if UserDefaults.standard.object(forKey: "UserData") != nil {
            let rawData = UserDefaults.standard.object(forKey: "UserData") as! [String : Any]
            return (rawData["AccountID"] as? String ?? "")
        }
        return ""
    }
    
}


