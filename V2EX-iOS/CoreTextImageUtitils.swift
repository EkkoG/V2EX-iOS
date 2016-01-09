//
//  CoreTextImageUtitils.swift
//  V2EX-iOS
//
//  Created by ciel on 16/1/7.
//  Copyright © 2016年 CL. All rights reserved.
//

import UIKit

class CoreTextImageUtitils: NSObject {

    class func touchImageInView(imageDatas: [CoreTextImageData], touchPoint: CGPoint, view: UIView) -> CoreTextImageData? {
        for imageData in imageDatas {
            let imagePosition = self.flipImageOriginY(imageData.imagePosition!, inView: view)
            
            if CGRectContainsPoint(imagePosition, touchPoint) {
                return imageData
            }
        }
        
        return nil
    }
    
    class func flipImageOriginY(rect: CGRect, inView: UIView) -> CGRect {
        let y = inView.bounds.size.height - rect.origin.y - rect.size.height
        var newRect = rect
        newRect.origin.y = y
        return newRect
    }
}
