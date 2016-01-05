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
import Async

struct V2EXAPI {
    static let LATEST_PATH = "/topics/latest.json"
    static let HTTP_PREFIX = "https"

    static let V2EX_API_BASE_URL = HTTP_PREFIX + "://www.v2ex.com/api"
    static let V2EX_BASE_URL = HTTP_PREFIX + "://www.v2ex.com/"
    
    static let V2EX_TOPIC_URL_PREFIX = V2EX_BASE_URL + "t/"
    
    static let TopicDetailContent = V2EX_API_BASE_URL + "/topics/show.json?id="
    
    static let TopicReplesContent = V2EX_API_BASE_URL + "/replies/show.json?topic_id="
    
    static let MemberProfileURL = V2EX_API_BASE_URL + "/members/show.json?username="
    
    static let MemberLatestTopicsURL = V2EX_API_BASE_URL + "/topics/show.json?username="
    
    static let NodeTopicsURL = V2EX_API_BASE_URL + "/topics/show.json?node_name="
    
    static let AllNodeURL = V2EX_API_BASE_URL + "/nodes/all.json"
    
    static let LatestTopicsURL = V2EX_API_BASE_URL + LATEST_PATH
    
    
    static let SignInURL = V2EX_BASE_URL + "signin"
    
    static let TabTopicsURL = V2EX_BASE_URL + "?tab="
    
    static let UserAgent = DataManager.getWebViewUserAgent()
}

public struct DataResponse <T> {
    var data: T?
    var error: NSError?
    
    typealias dataResponse = (dataResponse: DataResponse<T>) -> Void
    
    public init(data: T?, error:NSError?) {
        self.data = data
        self.error = error
    }
}

public enum RequestMethod {
    case GET
    case POST
}

public struct HTTPHeaderKey {
    static let Referer = "Referer"
    static let UserAgent = "User-Agent"
}

struct ParameterKey {
    static let Once = "once"
    static let Next = "next"
}


class DataManager: NSObject {
    
    class func request(method: RequestMethod, url: String, parameters: [String: AnyObject]? = nil, customHeaders: [String: String]? = nil, completeHandler: DataResponse<String>.dataResponse) {
        var requestMethod: Alamofire.Method = .GET
        if method == .POST {
            requestMethod = .POST
        }
        
        let request = self.getRequest(requestMethod, url: url, parameters: parameters, customHeaders: customHeaders)
        
        request.responseString { (response) -> Void in
            if response.result.isSuccess {
                let tmp = DataResponse<String>(data: response.result.value, error: nil)
                Async.main(block: { () -> Void in
                    completeHandler(dataResponse: tmp)
                })
            }
            else {
                let tmp = DataResponse<String>(data: nil, error: response.result.error)
                Async.main(block: { () -> Void in
                    completeHandler(dataResponse: tmp)
                })
            }
        }
    }
    
    class func requestData(method: RequestMethod, url: String, parameters: [String: AnyObject]? = nil, customHeaders: [String: String]? = nil, completeHandler: DataResponse<NSData>.dataResponse) {
        var requestMethod: Alamofire.Method = .GET
        if method == .POST {
            requestMethod = .POST
        }
        
        let request = self.getRequest(requestMethod, url: url, parameters: parameters, customHeaders: customHeaders)
        
        request.responseData{ (response) -> Void in
            if response.result.isSuccess {
                let tmp = DataResponse<NSData>(data: response.result.value, error: nil)
                Async.main(block: { () -> Void in
                    completeHandler(dataResponse: tmp)
                })
            }
            else {
                let tmp = DataResponse<NSData>(data: nil, error: response.result.error)
                Async.main(block: { () -> Void in
                    completeHandler(dataResponse: tmp)
                })
            }
        }
    }
    
    class func getRequest(method: Alamofire.Method, url: String, parameters: [String: AnyObject]? = nil, customHeaders: [String: String]? = nil) -> Request {
       return Alamofire.request(method, url, parameters: parameters, encoding: .URL, headers: customHeaders)
    }
    
    class func loadStringDataFromURL(URL: String, dataResponse: DataResponse<String>.dataResponse) {
        let headers = [HTTPHeaderKey.UserAgent: V2EXAPI.UserAgent]
        self.request(.GET, url: URL, parameters: nil, customHeaders: headers, completeHandler: dataResponse)
    }
    
    class func loadDataFromURL(URL: String, parameters:[String: AnyObject]? = nil, dataResponse: DataResponse<NSData>.dataResponse) {
        self.requestData(.GET, url: URL, parameters: parameters, customHeaders: nil, completeHandler: dataResponse)
    }
    
    class func getWebViewUserAgent() -> String {
        let webView = UIWebView(frame: CGRectZero)
        return webView.stringByEvaluatingJavaScriptFromString("navigator.userAgent")!
    }
}

extension DataManager {
    
    class func loadTabsTopicsDataWithTabsPath(path: String, dataResponse: DataResponse<[TopicModel]>.dataResponse) {
        if path == HomeTabs.latest.path {
            self.loadLatestTopics(dataResponse)
        }
        else {
            self.loadStringDataFromURL(V2EXAPI.TabTopicsURL + path, dataResponse: { (response) -> Void in
                self.parseHTMLFromString(response.data!, dataResponse: dataResponse)
            })
        }
    }
    
    class func loadLatestTopics(dataResponse: DataResponse<[TopicModel]>.dataResponse) {
        self.loadDataFromURL(V2EXAPI.LatestTopicsURL) { (response) -> Void in
            guard let data = response.data else {
                let tmp = DataResponse<[TopicModel]>(data: nil, error: response.error!)
                dataResponse(dataResponse: tmp)
                return
            }
            
            let json = JSON(data: data)
            
            var list = [TopicModel]()
            
            for (_, value) in (json.arrayObject?.enumerate())! {
                
                guard let topic = Mapper<TopicModel>().map(value) else {
                    continue
                }
                
                list.append(topic)
            }
            
            guard list.count > 0 else {
                dataResponse(dataResponse: DataResponse(data: nil, error: nil))
                return
            }
            
            dataResponse(dataResponse: DataResponse(data: list, error: nil))
        }
    }
    
    class func parseHTMLFromString(html: String, dataResponse: DataResponse<[TopicModel]>.dataResponse) {
        let jiDoc = Ji(htmlString: html)
        //        let body = jiDoc?.rootNode?.firstChildWithName("body")
        guard let items = jiDoc?.xPath("//div[@class='cell item']") else {
            dataResponse(dataResponse: DataResponse(data: nil, error: nil))
            return
        }
        
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
            //                print(t.last_modifiedText)
            
            list.append(t)
        }
        
        guard list.count > 0 else {
            dataResponse(dataResponse: DataResponse(data: nil, error: nil))
            return
        }
    
        dataResponse(dataResponse: DataResponse(data: list, error: nil))
    }
}

extension DataManager {
    class func loadTopicDetailContent(topicID: Int, completionHander: DataResponse<TopicDetailModel>.dataResponse) {
        self.loadDataFromURL(V2EXAPI.TopicDetailContent + "\(topicID)") { (response) -> Void in
            if let data = response.data {
                let json = JSON(data: data)
                if let model = Mapper<TopicDetailModel>().map(json.arrayObject?.first) {
                    model.content_rendered = model.content_rendered?.stringByReplacingOccurrencesOfString("//i.v2ex", withString: "https://i.v2ex")
                    let tmp = DataResponse<TopicDetailModel>(data: model, error: nil)
                    completionHander(dataResponse: tmp)
                }
                else {
                    let tmp = DataResponse<TopicDetailModel>(data: nil, error: nil)
                    completionHander(dataResponse: tmp)
                }
            }
        }
    }
    
    class func loadTopicDetailReplies(topicID: Int, completionHandler: DataResponse<NSArray>.dataResponse) {
        self.loadDataFromURL(V2EXAPI.TopicReplesContent + "\(topicID)") { (completion) -> Void in
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
                    completionHandler(dataResponse: tmp)
                }
                else {
                    let tmp = DataResponse<NSArray>(data: nil, error: nil)
                    completionHandler(dataResponse: tmp)
                }
            }
        }
    }
}

extension DataManager {
    class func getOnceString(url: String, completeionHandler: DataResponse<String>.dataResponse) {
        self.loadStringDataFromURL(url) { (completion) -> Void in
            if let data = completion.data {
                let doc = Ji(htmlString: data)
                let allNode = doc?.xPath("//input[@name='once']")
                if allNode?.count > 0 {
                    let tmp = DataResponse<String>(data: allNode?.first?["value"], error: nil)
                    completeionHandler(dataResponse: tmp)
                }
                else {
                    let tmp = DataResponse<String>(data: nil, error: nil)
                    completeionHandler(dataResponse: tmp)
                }
            }
        }
    }
}

extension DataManager {
    class func signIn(username: String, password: String, completion: DataResponse<Bool>.dataResponse) {
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = storage.cookies {
            for cookie in cookies {
                storage.deleteCookie(cookie)
            }
        }
        
        let para = [
            ParameterKey.Next: "/",
            "p": password,
            "u": username,
        ]
        
        self.submitForm(V2EXAPI.SignInURL, parameters: para) { (dataResponse) -> Void in
            guard let data = dataResponse.data else {
                completion(dataResponse: DataResponse(data: false, error: nil))
                return
            }
            
            guard data.containsString("/notifications") else {
                completion(dataResponse: DataResponse(data: false, error: nil))
                return
            }
            
            completion(dataResponse: DataResponse(data: true, error: nil))
        }
    }
}

extension DataManager {
    class func loadUserProfileInfo(username: String, completion: DataResponse<MemberProfileModel>.dataResponse) {
        self.requestData(.GET, url: V2EXAPI.MemberProfileURL + username) { (dataResponse) -> Void in
            guard let data = dataResponse.data else {
                completion(dataResponse: DataResponse<MemberProfileModel>(data: nil, error: nil))
                return
            }
            
            let json = JSON(data: data)
            guard let model = Mapper<MemberProfileModel>().map(json.dictionaryObject) else {
                completion(dataResponse: DataResponse<MemberProfileModel>(data: nil, error: nil))
                return
            }
            
            guard model.status != "notfound" else {
                completion(dataResponse: DataResponse<MemberProfileModel>(data: nil, error: nil))
                return
            }
            
            completion(dataResponse: DataResponse<MemberProfileModel>(data: model, error: nil))
        }
    }
}

extension DataManager {
    class func loadMemberLatestTopics(username: String, completion: DataResponse<Array<TopicModel>>.dataResponse) {
        self.requestData(.GET, url: V2EXAPI.MemberLatestTopicsURL + username) { (dataResponse) -> Void in
            guard let data = dataResponse.data else {
                completion(dataResponse: DataResponse<Array<TopicModel>>(data: nil, error: nil))
                return
            }
            
            let json = JSON(data: data)
            var list = [TopicModel]()
            for (_, value) in (json.arrayObject?.enumerate())! {
                if let topic = Mapper<TopicModel>().map(value) {
                    list.append(topic)
                }
            }
            
            guard list.count != 0 else {
                completion(dataResponse: DataResponse<Array<TopicModel>>(data: nil, error: nil))
                return
            }
            
            let tmp = DataResponse<Array<TopicModel>>(data: list, error: nil)
            completion(dataResponse: tmp)
        }
    }
}

extension DataManager {
    class func defaultHeader(URL: String) -> [String: String] {
        let header = [
            HTTPHeaderKey.Referer: URL,
            HTTPHeaderKey.UserAgent: V2EXAPI.UserAgent,
            "accept-encoding": "gzip, deflate",
            "accept-language": "en-US,en;q=0.8,zh-CN;q=0.6,zh;q=0.4,zh-TW;q=0.2",
            "content-type": "application/x-www-form-urlencoded"
        ]
        
        return header
    }
    
    class func submitForm(URL: String, parameters: [String: AnyObject], completeHander: DataResponse<String>.dataResponse) {
        self.getOnceString(URL) { (dataResponse) -> Void in
            guard let once = dataResponse.data else {
                return
            }
            
            var para = parameters
            para[ParameterKey.Once] = once
            
            let header = self.defaultHeader(URL)
            
            self.request(.POST, url: URL, parameters: para, customHeaders: header, completeHandler: completeHander)
        }
    }
}

extension DataManager {
    class func reply(content: String, topicID: Int, completeHander: DataResponse<Bool>.dataResponse) {
        let URL = V2EXAPI.V2EX_TOPIC_URL_PREFIX + String(topicID)
        let para = ["content": content]
        self.submitForm(URL, parameters: para) { (dataResponse) -> Void in
            guard let _ = dataResponse.data else {
                completeHander(dataResponse: DataResponse(data: false, error: nil))
                return
            }
            
            completeHander(dataResponse: DataResponse(data: true, error: nil))
        }
    }
}

extension DataManager {
    class func getAllNode(completeHandler: DataResponse<[Node]>.dataResponse) {
        self.requestData(.GET, url: V2EXAPI.AllNodeURL) { (dataResponse) -> Void in
            guard let data = dataResponse.data else {
                completeHandler(dataResponse: DataResponse(data: nil, error: nil))
                return
            }
            
            let json = JSON(data: data)
            var list = [Node]()
            for (_, value) in (json.arrayObject?.enumerate())! {
                if let node = Mapper<Node>().map(value) {
                    list.append(node)
                }
            }
            
            guard list.count != 0 else {
                completeHandler(dataResponse: DataResponse(data: nil, error: nil))
                return
            }
            
            let tmp = DataResponse<[Node]>(data: list, error: nil)
            completeHandler(dataResponse: tmp)
        }
    }
}

extension DataManager {
    class func getNodeTopics(nodeName:String, completeHandler: DataResponse<[TopicModel]>.dataResponse) {
        self.requestData(.GET, url: V2EXAPI.NodeTopicsURL + nodeName) { (dataResponse) -> Void in
            guard let data = dataResponse.data else {
                completeHandler(dataResponse: DataResponse(data: nil, error: nil))
                return
            }
            
            let json = JSON(data: data)
            var list = [TopicModel]()
            for (_, value) in (json.arrayObject?.enumerate())! {
                if let topic = Mapper<TopicModel>().map(value) {
                    list.append(topic)
                }
            }
            
            guard list.count != 0 else {
                completeHandler(dataResponse: DataResponse(data: nil, error: nil))
                return
            }
            
            let tmp = DataResponse<[TopicModel]>(data: list, error: nil)
            completeHandler(dataResponse: tmp)
            
        }
    }
}