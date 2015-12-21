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

class CTLabel: UIView, UIGestureRecognizerDelegate {
    dynamic var data: CoreTextData? {
        willSet(newValue) {
            self.data?.removeObserver(self, forKeyPath: "height")
            newValue!.addObserver(self, forKeyPath: "height", options: .New, context: nil)
        }
    }
    
    dynamic var textHeight: CGFloat = 0
    
    deinit {
        self.data?.removeObserver(self, forKeyPath: "height")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupEvents()
    }
    
    func userTapGestureDetected(recognizer: UIGestureRecognizer) {
        let point = recognizer.locationInView(self)
        if let data = self.data {
            if let imageArray = data.imageArray {
                for imageData in imageArray {
                    if imageData is CoreTextImageData {
                        let imageData = imageData as! CoreTextImageData
                        let imageRect = imageData.imagePosition!
                        var imagePosition:CGPoint = imageRect.origin
                        imagePosition.y = self.bounds.size.height - imageRect.origin.y - imageRect.size.height
                        let rect = CGRectMake(imagePosition.x, imagePosition.y, imageRect.size.width, imageRect.size.height)
                        if CGRectContainsPoint(rect, point) {
                            print("点击了图片\(imageData.imageURL)")
                        }
                    }
                }
            }
        }
        
        if let link = CoreTextLinkUtils.touchLinkInView(self, point: point, data: self.data!) {
            print("touch link \(link.url)")
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let change = change {
            let obj = change[NSKeyValueChangeNewKey] as! CGFloat
            print("========>>> \(obj)")
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
        
        CGContextSetTextMatrix(context, CGAffineTransformIdentity)
        CGContextTranslateCTM(context, 0, self.bounds.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        
        if let data = self.data {
            CTFrameDraw(data.ctFrame, context)
            
            if let _ = data.imageArray {
                for imageData in data.imageArray {
                    if imageData is CoreTextImageData {
                        let img = imageData as! CoreTextImageData
                        if let image = img.image {
                            CGContextDrawImage(context, img.imagePosition!, image.CGImage)
                        }
                    }
                }
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}