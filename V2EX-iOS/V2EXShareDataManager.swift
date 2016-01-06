//
//  V2EXShareDataManager.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/25.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit

public let kSigninedMemberNameKey = "com.cielpy.v2ex.SignedMemberNameKey"
public let kMemberSignInSuccessfulNotification = "com.cielpy.v2ex.MemberSignInSuccessful"

class V2EXShareDataManager: NSObject {
    static let shareInstance = V2EXShareDataManager()
    
    var cellHeightCeche = NSCache()
    
    var memberProfile: MemberProfileModel?
    
    func updateData() {
        if let username = NSUserDefaults.standardUserDefaults().objectForKey(kSigninedMemberNameKey) {
            DataManager.loadUserProfileInfo(username as! String, completion: { (dataResponse) -> Void in
                guard let profile = dataResponse.data else {
                    return
                }
                self.memberProfile = profile
                NSNotificationCenter.defaultCenter().postNotificationOnMainThreadWithName(kMemberSignInSuccessfulNotification, object: nil)
            })
        }
    }
    
    func signInStatus() -> (status: Bool, memberName: String?) {
        if let memberName = NSUserDefaults.standardUserDefaults().objectForKey(kSigninedMemberNameKey) {
            return (true, memberName as? String)
        }
        else {
            return (false, nil)
        }
    }
}

extension V2EXShareDataManager {
    func getCacheByKey(key: AnyObject) -> [String: CoreTextData] {
        if let obj = self.cellHeightCeche.objectForKey(key) {
            return obj as! [String: CoreTextData]
            
        }
        else {
            return [String: CoreTextData]()
        }
    }
    
    func updateObjectByKey(key: AnyObject, object: [String: CoreTextData]) {
        self.cellHeightCeche.setObject(object, forKey: key)
    }
}
