//
//  CoreTextLinkData.swift
//  CoreTextTest
//
//  Created by ciel on 15/12/17.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit

class CoreTextLinkData: NSObject {
    var title: String?
    var url: String?
    var range: NSRange?
    
    var isMemberLink: Bool {
        get {
            guard let url = self.url else {
                return false
            }
            return url.hasPrefix("/member/")
        }
    }

    var memberName: String? {
        get {
            if self.isMemberLink == true {
                let memberIdentifier = "/member/"
                return self.url!.stringByReplacingOccurrencesOfString(memberIdentifier, withString: "")
            }
            return nil
        }
    }
}
