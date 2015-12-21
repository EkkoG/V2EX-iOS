//
//  CoreTextLinkUtils.swift
//  CoreTextTest
//
//  Created by ciel on 15/12/17.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit

class CoreTextLinkUtils: NSObject {
    class func touchLinkInView(view: UIView, point: CGPoint, data: CoreTextData) -> CoreTextLinkData? {
        let textFrame = data.ctFrame
        let lines = CTFrameGetLines(textFrame) as NSArray
        if lines.count == 0 {
            return nil
        }
        
        var origins = [CGPoint](count: lines.count, repeatedValue: CGPointZero)
        CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), &origins)
        var transform = CGAffineTransformMakeTranslation(0, view.bounds.size.height)
        transform = CGAffineTransformScale(transform, 1.0, -1.0)
        
        for i in 0..<origins.count {
            let linePoint = origins[i]
            let line = lines[i] as! CTLineRef
            
            let  flippedRect =  self.getLineBounds(line, point: linePoint)
            let rect = CGRectApplyAffineTransform(flippedRect, transform)
            
            if CGRectContainsPoint(rect, point) {
                let relativePoint = CGPointMake(point.x - CGRectGetMinX(rect), point.y - CGRectGetMinY(rect))
                
                let idx = CTLineGetStringIndexForPosition(line, relativePoint)
                if let link = self.linkAtIndex(idx, linkArray: data.linkArray!) {
                    return link
                }
            }
        }
        
        return nil
    }
    
    class func getLineBounds(line: CTLineRef, point: CGPoint) -> CGRect {
        var ascent:CGFloat = 0
        var descent:CGFloat = 0
        var leading:CGFloat = 0
        let width = CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, &leading))
        let height = ascent + descent
        return CGRectMake(point.x, point.y, width, height)
    }
    
    class func linkAtIndex(i: CFIndex, linkArray: NSArray) -> CoreTextLinkData? {
        for data in linkArray {
            if data is CoreTextLinkData {
                let d = data as! CoreTextLinkData
                if let range = d.range {
                    if NSLocationInRange(i, range) {
                        return d
                    }
                }
            }
        }
        return nil
    }

}
