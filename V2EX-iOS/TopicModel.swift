//
//  TopicModel.swift
//  V2EX-iOS
//
//  Created by ciel on 15/11/29.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import ObjectMapper

class TopicModel: NSObject, Mappable {
    var topicID: Int?
    var title: String?
    var replies: Int?
    var member: Member?
    var node: Node?
    var last_modified: Double?
    var last_modifiedText: String?
    
    required init?(_ map: Map) {
        
    }
    
    override init() {
        
    }

    func mapping(map: Map) {
        self.topicID <- map["id"]
        self.title <- map["title"]
        self.replies <- map["replies"]
        self.member <- map["member"]
        self.node <- map["node"]
        self.last_modified <- map["last_modified"]
    }
    
    func lastModifiedText() -> String {
        if let last_modified = self.last_modified {
            return V2EXHelper.dateFormat(last_modified)
        }
        
        if let last_modifiedText = self.last_modifiedText {
            return last_modifiedText
        }
        return ""
    }
    
    func avatarURL() -> String {
        if !self.member!.avatar_normal!.hasPrefix("http") {
            return "https:" + self.member!.avatar_normal!
        }
        return self.member!.avatar_normal!
    }
}

class Node: NSObject, Mappable {
    var title: String?
    var name: String?
    var url: String?
    
    required init?(_ map: Map) {
        
    }
    
    override init() {
        
    }
    
    func mapping(map: Map) {
        self.title <- map["title"]
        self.name <- map["name"]
        self.url <- map["url"]
    }
}

class Member: NSObject, Mappable {
    var username: String?
    var avatar_normal: String? {
        didSet {
            guard let url = avatar_normal else {
                return
            }
            
            if !url.hasPrefix("http") {
                avatar_normal =  "https:" + url
            }
        }
    }
    
    required init?(_ map: Map) {
        
    }
    
    override init() {
        
    }
    
    func mapping(map: Map) {
        self.username <- map["username"]
        self.avatar_normal <- map["avatar_normal"]
    }
}