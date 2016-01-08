//
//  CoreTextHelper.swift
//  V2EX-iOS
//
//  Created by ciel on 16/1/8.
//  Copyright © 2016年 CL. All rights reserved.
//

import UIKit

class CoreTextHelper: NSObject {
    class func getlinesAndOrigins(frame: CTFrameRef) -> (lines: [CTLineRef], origins: [CGPoint]) {
        let lines = CTFrameGetLines(frame) as NSArray
        let lineCount = lines.count
        
        var lineOrigins = [CGPoint](count: lineCount, repeatedValue: CGPointZero)
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), &lineOrigins)
        return (lines as! [CTLineRef], lineOrigins)
    }

}
