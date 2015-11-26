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

class DataManager: NSObject {
    
    class func loadTabsDataWithTabsPath(path: String, completion:(data: String?, error:NSError?) -> Void) {
        if path == HomeTabs.latest.path {
            loadDataFromURL(V2EX_API_BASE_URL + LATEST_PATH, completion: { (data, error) -> Void in
                if let data = data {
                    let string = String.init(data: data, encoding: NSUTF8StringEncoding)
                    completion(data: string, error: nil)
                }
                else {
                    completion(data: nil, error: error)
                }
            })
        }
    }
    
    class func loadDataFromURL(URL: String, completion:(data: NSData?, error: NSError?) -> Void) {
        Alamofire.request(.GET, URL).responseData { (response) -> Void in
            if response.result.isSuccess {
                completion(data: response.data, error: nil)
            }
            else {
                completion(data: nil, error: response.result.error)
            }
        }
        
    }

}
