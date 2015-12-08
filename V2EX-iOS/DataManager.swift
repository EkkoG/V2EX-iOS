//
//  DataManager.swift
//  V2EX-iOS
//
//  Created by ciel on 15/11/26.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Ji
import ObjectMapper

let V2EX_API_BASE_URL = "https://www.v2ex.com/api"
let V2EX_BASE_URL = "https://www.v2ex.com/"
let LATEST_PATH = "/topics/latest.json"
let HTTP_PREFIX = "https"

struct V2EXAPI {
    static let V2EXAPIBaseURL = "https://www.v2ex.com/api"
    
    static var TopicDetailContent: String {
        return V2EXAPIBaseURL + "/topics/show.json?id="
    }
    
    static var TopicReplesContent: String {
        return V2EXAPIBaseURL + "/replies/show.json?topic_id="
    }
}

public struct DataResponse <T> {
    var data: T?
    var error: NSError?
    
    typealias completion = (completion: DataResponse<T>) -> Void
    
    public init(data: T?, error:NSError?) {
        self.data = data
        self.error = error
    }
}


class DataManager: NSObject {
    
    class func loadTabsTopicsDataWithTabsPath(path: String, completion: DataResponse<NSArray>.completion) {
        if path == HomeTabs.latest.path {
            loadLatestTopics(completion)
        }
        else {
            loadStringDataFromURL(V2EX_BASE_URL + "?tab=\(path)", completion: { (response) -> Void in
                parseHTMLFromString(response.data!, completion: completion)
            })
        }
    }
    
    class func loadLatestTopics(completion: DataResponse<NSArray>.completion) {
        loadDataFromURL(V2EX_API_BASE_URL + LATEST_PATH) { (response) -> Void in
            if let data = response.data {
                let json = JSON(data: data)
                var list = [TopicModel]()
                for (_, value) in (json.arrayObject?.enumerate())! {
                    if let topic = Mapper<TopicModel>().map(value) {
                        list.append(topic)
                    }
                }
                let tmp = DataResponse<NSArray>(data: list, error: nil)
                completion(completion: tmp)
            }
            else {
                let tmp = DataResponse<NSArray>(data: nil, error: response.error!)
                completion(completion: tmp)
            }
            
        }
    }
    
    class func parseHTMLFromString(html: String, completion: DataResponse<NSArray>.completion) {
        let jiDoc = Ji(htmlString: html)
        //        let body = jiDoc?.rootNode?.firstChildWithName("body")
        if let items = jiDoc?.xPath("//div[@class='cell item']") {
            var list = [TopicModel]()
            for item in items {
                let avatar = item.xPath(".//img[@class='avatar']")
                
                let titles = item.xPath(".//span[@class='item_title']")
                let title = titles.first?.content!
                
                let url = titles.first!.xPath("./a").first!["href"]
                let components = url?.componentsSeparatedByString("/")
                let topicID = components![2].componentsSeparatedByString("#").first
                
                let fade = item.xPath(".//span[@class='small fade']")
                let node = fade[0].xPath(".//a[@class='node']")
                let nodeTitle = node.first?.content
                let nodeName = node.first?["href"]?.stringByReplacingOccurrencesOfString("/go/", withString: "")
                
                let authors = fade[0].xPath(".//strong/a")
                let author = authors.first?.content
                
//                let lastComments = fade[1].xPath(".//strong/a")
//                let last = lastComments.first?.content
                
                let fadeContent = fade[1].content
                let lastModify = fadeContent?.componentsSeparatedByString("  •  ")
                let lastModifiedText = lastModify?.first
                
                let commentCount = item.xPath(".//a[@class='count_livid']")
                let count = commentCount.first?.content
                
                let t = TopicModel()
                t.title = title
                t.topicID = Int(topicID!)
                let nodeModel = Node()
                nodeModel.title = nodeTitle
                nodeModel.name = nodeName
                nodeModel.url = node.first!["href"]
                t.node = nodeModel
                if let count = count {
                    t.replies = Int(count)
                }
                let memberModel = Member()
                memberModel.username = author
                memberModel.avatar_normal = avatar.first!["src"]
                t.member = memberModel
                
                t.last_modifiedText = lastModifiedText
                print(t.last_modifiedText)
                
                list.append(t)
            }
            if list.count > 0 {
                let tmp = DataResponse<NSArray>(data: list, error: nil)
                completion(completion: tmp)
            }
            else {
                let tmp = DataResponse<NSArray>(data: nil, error: nil)
                completion(completion: tmp)
            }
        }
        
    }
    
    class func loadStringDataFromURL(URL: String, completion: DataResponse<String>.completion) {
        let headers = ["User-Agent" : "Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13B143"]
        Alamofire.request(.GET, URL, headers: headers).responseString { (response) -> Void in
            if response.result.isSuccess {
                let tmp = DataResponse<String>(data: response.result.value, error: nil)
                completion(completion: tmp)
            }
            else {
                let tmp = DataResponse<String>(data: nil, error: response.result.error)
                completion(completion: tmp)
            }
        }
        
    }
    
    class func loadDataFromURL(URL: String, completion: DataResponse<NSData>.completion) {
        Alamofire.request(.GET, URL).responseData { (response) -> Void in
            if response.result.isSuccess {
                let tmp = DataResponse<NSData>(data: response.data, error: nil)
                completion(completion: tmp)
            }
            else {
                let tmp = DataResponse<NSData>(data: nil, error: response.result.error!)
                completion(completion: tmp)
            }
        }
        
    }
    
}

extension DataManager {
    class func loadTopicDetailContent(topicID: Int, completionHander: DataResponse<TopicDetailModel>.completion) {
        loadDataFromURL(V2EXAPI.TopicDetailContent + "\(topicID)") { (response) -> Void in
            if let data = response.data {
                let json = JSON(data: data)
                if let model = Mapper<TopicDetailModel>().map(json.arrayObject?.first) {
                    model.content_rendered = model.content_rendered?.stringByReplacingOccurrencesOfString("//i.v2ex", withString: "https://i.v2ex")
                    let tmp = DataResponse<TopicDetailModel>(data: model, error: nil)
                    completionHander(completion: tmp)
                }
                else {
                    let tmp = DataResponse<TopicDetailModel>(data: nil, error: nil)
                    completionHander(completion: tmp)
                }
            }
        }
    }
    
    class func loadTopicDetailReplies(topicID: Int, completionHandler: DataResponse<NSArray>.completion) {
        loadDataFromURL(V2EXAPI.TopicReplesContent + "\(topicID)") { (completion) -> Void in
            if let data = completion.data {
                let json = JSON(data: data)
                var list = [TopicReplyModel]()
                if json.arrayObject?.count > 0 {
                    for (_, value) in json.arrayObject!.enumerate() {
                        if let model = Mapper<TopicReplyModel>().map(value) {
                            list.append(model)
                        }
                    }
                }
                if list.count > 0 {
                    let tmp = DataResponse<NSArray>(data: list, error: nil)
                    completionHandler(completion: tmp)
                }
                else {
                    let tmp = DataResponse<NSArray>(data: nil, error: nil)
                    completionHandler(completion: tmp)
                }
            }
        }
    }
}
