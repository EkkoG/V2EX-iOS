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
        topicID <- map["id"]
        title <- map["title"]
        url <- map["url"]
        content <- map["content"]
        content_rendered <- map["content_rendered"]
        replies <- map["replies"]
        member <- map["member"]
        node <- map["node"]
        created <- map["created"]
        last_modified <- map["last_modified"]
        last_touched <- map["last_touched"]
    }
}
