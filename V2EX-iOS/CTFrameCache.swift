//
//  CTFrameCache.swift
//  V2EX-iOS
//
//  Created by ciel on 16/1/8.
//  Copyright © 2016年 CL. All rights reserved.
//

import UIKit
import CryptoSwift

class CTFrameCache: NSObject {
    static let shareInstance = CTFrameCache()
    
    let dataCache = NSCache()

    func getData(content: String, width: CGFloat) -> CoreTextData {
        let key = content.md5()
        if let data = dataCache.objectForKey(key) {
            return data as! CoreTextData
        }
        else {
            let data = CTFrameParser.parseHTMLString(content, width: width)
            self.dataCache.setObject(data, forKey: key)
            return data
        }
    }
}
