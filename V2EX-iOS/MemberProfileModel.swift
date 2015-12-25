//
//  MemberProfileModel.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/25.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import ObjectMapper

class MemberProfileModel: NSObject,Mappable {
    var status: String?
    var id: Int?
    var username: String?
    var website: String?
    var twitter: String?
    var psn: String?
    var github: String?
    var btc: String?
    var location: String?
    var tagline: String?
    var bio: String?
    var avatar_mini: String?
    var avatar_normal: String?
    var avatar_large: String? {
        didSet {
            avatar_large = "https:" + avatar_large!
        }
    }
    var created: Double?

    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        status <- map["status"]
        id <- map["id"]
        username <- map["username"]
        website <- map["website"]
        twitter <- map["twitter"]
        psn <- map["psn"]
        github <- map["github"]
        btc <- map["btc"]
        location <- map["localtion"]
        tagline <- map["tagline"]
        bio <- map["bio"]
        avatar_mini <- map["avatar_mini"]
        avatar_normal <- map["avatar_normal"]
        avatar_large <- map["avatar_large"]
        created <- map["created"]
    }
}
