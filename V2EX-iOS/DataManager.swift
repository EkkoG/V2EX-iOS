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

let V2EX_API_BASE_URL = "https://www.v2ex.com/api"
let LATEST_PATH = "/topics/latest.json"

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
    }
    
    class func loadLatestTopics(completion: DataResponse<NSArray>.completion) {
        loadDataFromURL(V2EX_API_BASE_URL + LATEST_PATH) { (response) -> Void in
                if let data = response.data {
                    let json = JSON(data: data)
                    let tmp = DataResponse<NSArray>(data: json.arrayObject, error: nil)
                    completion(completion: tmp)
                }
                else {
                    let tmp = DataResponse<NSArray>(data: nil, error: response.error!)
                    completion(completion: tmp)
                }
            
        }
    }
    
    class func loadStringDataFromURL(URL: String, completion: DataResponse<String>.completion) {
        Alamofire.request(.GET, URL).responseString { (response) -> Void in
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
