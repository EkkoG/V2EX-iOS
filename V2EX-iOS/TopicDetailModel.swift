//
//  TopicDetailModel.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/2.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import ObjectMapper

class TopicDetailModel: NSObject, Mappable {
    let kHTMLContentBodyPlaceholderKey = "CONTENT_BODY"
    
    var topicID: Int?
    var title: String?
    var url: String?
    var content: String?
    var content_rendered: String? {
        didSet {
           content_rendered = content_rendered?.stringByReplacingOccurrencesOfString("//i.v2ex", withString: "https://i.v2ex")
        }
    }
    var replies: Int?
    var member: Member?
    var node: Node?
    var created: Double?
    var last_modified: Double?
    var last_touched: Double?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.topicID <- map["id"]
        self.title <- map["title"]
        self.url <- map["url"]
        self.content <- map["content"]
        self.content_rendered <- map["content_rendered"]
        self.replies <- map["replies"]
        self.member <- map["member"]
        self.node <- map["node"]
        self.created <- map["created"]
        self.last_modified <- map["last_modified"]
        self.last_touched <- map["last_touched"]
    }
    
    func HTMLContentAndBaseURL() -> (html: String?, baseURL: NSURL?)  {
        guard let htmlTemplate = V2EXHelper.loadLocalFile("topic", type: "html") else {
            return (nil, nil)
        }
        
        guard let rendered = self.content_rendered else {
            return (nil, nil)
        }
        
        let path = NSBundle.mainBundle().bundlePath
        let baseURL = NSURL(fileURLWithPath: path)
        let html = htmlTemplate.stringByReplacingOccurrencesOfString(kHTMLContentBodyPlaceholderKey, withString: rendered)
        return (html, baseURL)
    }
}
