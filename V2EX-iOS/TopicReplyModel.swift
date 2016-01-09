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
    var content_rendered: String? {
        didSet {
            guard let content = content_rendered else {
                return
            }
            if !content.hasPrefix("<p>") {
                content_rendered = "<p>\(content)</p>"
            }
        }
    }
    var created: Double?
    var createdText: String {
        get {
            return V2EXHelper.dateFormat(self.created!)
        }
    }
    var last_modified: Double?
    var member: Member?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.replyID <- map["id"]
        self.thanks <- map["thanks"]
        self.content <- map["content"]
        self.content_rendered <- map["content_rendered"]
        self.created <- map["created"]
        self.last_modified <- map["last_modified"]
        self.member <- map["member"]
    }
}
