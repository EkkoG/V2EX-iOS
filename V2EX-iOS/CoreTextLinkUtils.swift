//
//  CoreTextLinkUtils.swift
//  CoreTextTest
//
//  Created by ciel on 15/12/17.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit

class CoreTextLinkUtils: NSObject {
    
    class func flipCoordinate(view: UIView) -> CGAffineTransform {
        var transform = CGAffineTransformMakeTranslation(0, view.bounds.size.height)
        transform = CGAffineTransformScale(transform, 1.0, -1.0)
        return transform
    }
    
    class func getLineRect(point: CGPoint,line: CTLineRef, transform: CGAffineTransform) -> CGRect {
        //get line's origin rect
        let  flippedRect =  self.getLineBounds(line, point: point)
        //flip the rect
        let rect = CGRectApplyAffineTransform(flippedRect, transform)
        return rect
    }
    
    class func convertToCurrentCoordinate(rect: CGRect, point: CGPoint) -> CGPoint {
        let relativePoint = CGPointMake(point.x - CGRectGetMinX(rect), point.y - CGRectGetMinY(rect))
        return relativePoint
    }
    
    class func linkHitTest(point: CGPoint, lines: [CTLineRef], origins: [CGPoint], transform: CGAffineTransform, data: CoreTextData) -> CoreTextLinkData? {
        for i in 0..<origins.count {
            let linePoint = origins[i]
            let line = lines[i]
            
            let rect = self.getLineRect(linePoint, line: line, transform: transform)
            
            if CGRectContainsPoint(rect, point) {
                let relativePoint = self.convertToCurrentCoordinate(rect, point: point)
                
                let idx = CTLineGetStringIndexForPosition(line, relativePoint)
                if let link = self.linkAtIndex(idx, links: data.linkArray) {
                    return link
                }
            }
        }
        
        return nil
    }
    
    //http://blog.devtang.com/blog/2015/06/27/using-coretext-2/
    class func touchLinkInView(view: UIView, point: CGPoint, data: CoreTextData) -> CoreTextLinkData? {
        //flip coordinate
        let transform = self.flipCoordinate(view)
        
        //get rect of each line
        let lines = CoreTextHelper.getlinesAndOrigins(data.ctFrame).lines
        let lineOrigins = CoreTextHelper.getlinesAndOrigins(data.ctFrame).origins
        
        return self.linkHitTest(point, lines: lines, origins: lineOrigins, transform: transform, data: data)
    }
    
    class func getLineBounds(line: CTLineRef, point: CGPoint) -> CGRect {
        var ascent:CGFloat = 0
        var descent:CGFloat = 0
        var leading:CGFloat = 0
        let width = CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, &leading))
        let height = ascent + descent
        return CGRectMake(point.x, point.y, width, height)
    }
    
    class func linkAtIndex(i: CFIndex, links: [CoreTextLinkData]) -> CoreTextLinkData? {
        for data in links {
            if let range = data.range {
                if NSLocationInRange(i, range) {
                    return data
                }
            }
        }
        return nil
    }
}
