//
//  TopicReplyModel.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/2.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import ObjectMapper

class TopicReplyModel: NSObject, Mappable {
    var replyID: Int?
    var thanks: String?
    var content: String?
    var content_rendered: String?
    var created: Double?
    var last_modified: Double?
    var member: Member?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        replyID <- map["id"]
        thanks <- map["thanks"]
        content <- map["content"]
        content_rendered <- map["content_rendered"]
        created <- map["created"]
        last_modified <- map["last_modified"]
        member <- map["member"]
    }
    
    func avatarURL() -> String {
        if !member!.avatar_normal!.hasPrefix("http") {
            return "https:" + member!.avatar_normal!
        }
        return member!.avatar_normal!
    }
}
