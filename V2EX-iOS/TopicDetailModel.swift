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
    var topicID: Int?
    var title: String?
    var url: String?
    var content: String?
    var content_rendered: String?
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
}
