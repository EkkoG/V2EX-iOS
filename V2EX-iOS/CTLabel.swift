//
//  CTLabel.swift
//  CoreTextTest
//
//  Created by ciel on 15/12/10.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import Async
import Kingfisher

let kCTTouchLinkNotification = "com.cielpy.v2ex.CTTouchLinkNotification"
let kCTTouchImageNotification = "com.cielpy.v2ex.CTTouchImageNotification"

class CTLabel: UIView, UIGestureRecognizerDelegate {
    
    var htmlString: String? {
        didSet {
            let width = UIScreen.mainScreen().bounds.size.width - SPACING_BEWTWEEN_COMPONENTS - MARGIN_TO_BOUNDARY * 2 - 50
            self.data = CTFrameCache.shareInstance.getData(htmlString!, width: width)
//            self.textHeight = data!.height
        }
    }
    
    var linkStyle: CTFrameParserConfig?
    var contentStyle: CTFrameParserConfig?
    
    dynamic var data: CoreTextData? {
        willSet(newValue) {
            self.addDataObserver(newValue)
        }
        
        didSet {
            self.removeDataObserver(oldValue)
        }
    }
    
    dynamic var textHeight: CGFloat = 0
    
    deinit {
        self.removeDataObserver(self.data)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupEvents()
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            let point = gestureRecognizer.locationInView(self)
            guard let data = self.data else {
                return false
            }
            
            if let imageData = CoreTextImageUtitils.touchImageInView(data.imageArray, touchPoint: point, view: self) {
                NSNotificationCenter.defaultCenter().postNotificationName(kCTTouchImageNotification, object: imageData.image!)
                return true
            }
            
            if let link = CoreTextLinkUtils.touchLinkInView(self, point: point, data: self.data!) {
                NSNotificationCenter.defaultCenter().postNotificationName(kCTTouchLinkNotification, object: link)
                return true
            }
            
            return false
        }
        
        return true
    }
    
    func userTapGestureDetected(recognizer: UIGestureRecognizer) {
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let change = change {
            let obj = change[NSKeyValueChangeNewKey] as! CGFloat
            //            print("========>>> \(obj)")
            self.textHeight = obj
        }
    }
    
    func setupEvents() {
        let tap = UITapGestureRecognizer(target: self, action: "userTapGestureDetected:")
        tap.delegate = self
        self.addGestureRecognizer(tap)
        self.userInteractionEnabled = true
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let context = UIGraphicsGetCurrentContext()!
        
        self.flipCoordinate(context)
        
        if let data = self.data {
            CTFrameDraw(data.ctFrame, context)
            
            for imageData in data.imageArray {
                if let image = imageData.image {
                    CGContextDrawImage(context, imageData.imagePosition!, image.CGImage)
                }
            }
        }
    }
    
    func flipCoordinate(context: CGContextRef) {
        CGContextSetTextMatrix(context, CGAffineTransformIdentity)
        CGContextTranslateCTM(context, 0, self.bounds.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
    }
    
    func removeDataObserver(data: CoreTextData?) {
        guard let data = data else {
            return
        }
        
        data.removeObserver(self, forKeyPath: "height")
    }
    
    func addDataObserver(data: CoreTextData?) {
        guard let data = data else {
            return
        }
        data.addObserver(self, forKeyPath: "height", options: .New, context: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
