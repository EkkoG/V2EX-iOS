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
            self.memberSocialInfo()
            if let str = avatar_large {
                avatar_large = "https:" + str
            }
        }
    }
    var created: Double?
    
    var memberSoicalInfo = [MemberSocialInfo]()
    
    var createDateString: String? {
        get {
            let date = NSDate(timeIntervalSince1970: NSTimeInterval(self.created!))
            let string = date.stringWithFormat("yyyy-MM-dd HH-mm-ss Z")
            
            return "加入于 " + string
        }
    }

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
    
    func memberSocialInfo() {
        var socialArray = [MemberSocialInfo]()
        
        if let str = self.website where self.website?.length > 0 {
           let social = MemberSocialInfo(type: .WebSite, URL: str)
            social.title = str
            socialArray.append(social)
        }
        
        if let str = self.twitter where self.twitter?.length > 0 {
            let url = "https://twitter.com/" + str
            let social = MemberSocialInfo(type: .Twitter, URL: url)
            social.title = str
            socialArray.append(social)
        }
        
        if let str = self.github where self.github?.length > 0 {
            let url = "https:/github.com/" + str
            let social = MemberSocialInfo(type: .GitHub, URL: url)
            social.title = str
            socialArray.append(social)
        }
        self.memberSoicalInfo = socialArray
    }
}

class MemberSocialInfo {
    enum SocialType {
        case WebSite
        case Twitter
        case GitHub
    }
    
    var type: SocialType?
    var URL: String?
    var title: String?
    var iconImage: UIImage?
    
    convenience init(type: SocialType, URL: String) {
        self.init()
        self.type = type
        self.URL = URL
        self.iconImage = self.iconImage(type)
    }
    
    func iconImage(type: SocialType) -> UIImage {
        switch type {
        case .WebSite:
            return UIImage(named: "social_home")!
        case .Twitter:
            return UIImage(named: "social_twitter")!
        case .GitHub:
            return UIImage(named: "social_github")!
        }
    }
}
