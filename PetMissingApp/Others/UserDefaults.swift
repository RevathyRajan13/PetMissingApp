//
//  UserDefaults.swift
//  Second Opinion Doctors Form
//
//  Created by Revathy - iOS Dev on 07/12/24.
//

import Foundation

let userDefaults = UserDefaults.standard

class userDefaultModule {
    
    //MARK: - Singleton Instance
    static let shared = userDefaultModule()
    
    // Prevent outside initialization
    private init() {}
    
    
    //MARK: SET GLOBAL Variables
    
    func setName(name:String) {
        userDefaults.set(name, forKey: "name")
    }
    
    func setMobileNo(mobileNo:String) {
        userDefaults.set(mobileNo, forKey: "mobileNo")
    }
    
    func setEmailID(emailId:String) {
        userDefaults.set(emailId, forKey: "emailId")
    }
    
    //MARK: GET GLOBAL Variables
    
    func getName() -> String {
        let name = userDefaults.string(forKey: "name")
        return name ?? "Revathy"
    }
    
    func getMobileNo() -> String {
        let mobileNo = userDefaults.string(forKey: "mobileNo")
        return mobileNo ?? ""
    }
    
    func getEmailID() -> String {
        let emailId = userDefaults.string(forKey: "emailId")
        return emailId ?? ""
    }
    
}
