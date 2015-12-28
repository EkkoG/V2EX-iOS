//
//  V2EXShareDataManager.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/25.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit

let signinedMemberNameKey = "com.cilepy.v2ex.signedUserNameKey"

class V2EXShareDataManager: NSObject {
    static let shareInstance = V2EXShareDataManager()
    
    var cellHeightCeche = [Int: [String :CoreTextData]]()
    
    var memberProfile: MemberProfileModel?
    
    func updateData() {
        if let username = NSUserDefaults.standardUserDefaults().objectForKey(signinedMemberNameKey) {
            DataManager.loadUserProfileInfo(username as! String, completion: { (dataResponse) -> Void in
                guard let profile = dataResponse.data else {
                    return
                }
                self.memberProfile = profile
            })
        }
    }
}
