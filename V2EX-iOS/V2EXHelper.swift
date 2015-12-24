//
//  V2EXHelper.swift
//  V2EX-iOS
//
//  Created by ciel on 15/11/29.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit

class V2EXHelper: NSObject {
    class func dateFormat(timeStamp: Double) -> String {
        let nowDate = NSDate()
        let nowTimeStamp = Int(nowDate.timeIntervalSince1970)
        let timeStamp = Int(timeStamp)
        let diff = nowTimeStamp - timeStamp
        
        let minOfSecond = 60
        let hourOfSecond = minOfSecond * 60
        let dayOfSecond = hourOfSecond * 24
        let yearOfSecond = dayOfSecond * 365
        
        if diff < minOfSecond {
            return "几秒前"
        }
        
        if diff < hourOfSecond {
            let min = diff / minOfSecond
            return "\(min)分钟前"
        }
        
        if diff < dayOfSecond {
            let hours = diff / hourOfSecond
//            let min = (diff % hourOfSecond) / minOfSecond
//            return "\(hours)小时 \(min) 分钟前"
            return "\(hours)小时前"
        }
        
        if diff < yearOfSecond {
            let day = diff / dayOfSecond
            return "\(day)天前"
        }
        
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(timeStamp))
        let string = date.stringWithFormat("yyyy-MM-dd HH-mm-ss Z")
        return string
    }
    
}
