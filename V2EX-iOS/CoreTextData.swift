
//  CoreTextData.swift
//  CoreTextTest
//
//  Created by ciel on 15/12/14.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import Async
import Kingfisher

class CoreTextData: NSObject {
    var ctFrame: CTFrameRef!
    dynamic var height:CGFloat = 0
    var content: NSMutableAttributedString?
    var linkArray: NSMutableArray?
    var imageArray: NSMutableArray! {
        didSet {
            self.fillImagePosition()
            self.downloadImages()
        }
    }
    
    internal func downloadImages() {
        for item in self.imageArray {
            let item = item as! CoreTextImageData
            if !item.webImageDownloaded {
                ImageDownloader.defaultDownloader.downloadImageWithURL(NSURL(string: item.imageURL!)!, progressBlock: { (receivedSize, totalSize) -> () in
                    
                    }, completionHandler: { (image, error, imageURL, originalData) -> () in
                        if let image = image {
                            item.webImageDownloaded = true
                            Async.main(block: { () -> Void in
                                item.image = image
                                let attribute = CoreTextImageRunDelegateHelper.parseImageDataFromNSDictionary(item.image)
                                if let content = self.content {
                                    content.beginEditing()
                                    content.replaceCharactersInRange(NSMakeRange(item.position!, 1), withAttributedString: attribute!)
                                    content.endEditing()
                                    
                                    let width = UIScreen.mainScreen().bounds.size.width - SPACING_BEWTWEEN_COMPONENTS - MARGIN_TO_BOUNDARY * 2 - 50
                                    let config = CTFrameParserConfig.defaultConfig(width)
                                    let data = CTFrameParser.parseAttributedContent(content, config: config)
                                    
                                    self.ctFrame = data.ctFrame
                                    self.fillImagePosition()
                                    self.height = data.height
                                }
                            })
                        }
                })
            }
        }
    }
    
    internal func fillImagePosition() {
        if self.imageArray.count == 0 {
            return
        }
        let lines = CTFrameGetLines(self.ctFrame) as NSArray
        let lineCount = lines.count
        var lineOrigins = [CGPoint](count: lineCount, repeatedValue: CGPointZero)
        CTFrameGetLineOrigins(self.ctFrame, CFRangeMake(0, 0), &lineOrigins)
        
        var imageIndex = 0
        var imageData = self.imageArray.firstObject as? CoreTextImageData
        
        for i in 0..<lineCount {
            let line = lines[i] as! CTLineRef
            let runs = CTLineGetGlyphRuns(line) as NSArray
            for j in 0..<runs.count {
                let runObj = runs[j] as! CTRunRef
                let attributes = CTRunGetAttributes(runObj) as Dictionary
                if let _ = attributes[kCTRunDelegateAttributeName] {
                    var runBounds = CGRectZero
                    var ascent: CGFloat = 0
                    var descent: CGFloat = 0
                    runBounds.size.width = CGFloat(CTRunGetTypographicBounds(runObj, CFRangeMake(0, 0), &ascent, &descent, nil))
                    runBounds.size.height = ascent + descent
                    
                    let xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(runObj).location, nil)
                    runBounds.origin.x = lineOrigins[i].x + xOffset
                    runBounds.origin.y = lineOrigins[i].y
                    runBounds.origin.y -= descent
                    
                    let pathRef = CTFrameGetPath(self.ctFrame)
                    let colRect = CGPathGetBoundingBox(pathRef)
                    
                    let delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y)
                    imageData?.imagePosition = delegateBounds
                    imageIndex++
                    if imageIndex == self.imageArray.count {
                        imageData = nil
                        break
                    }
                    else {
                        imageData = self.imageArray[imageIndex] as? CoreTextImageData
                    }
                    
                }
                else {
                    continue
                }
            }
        }
    }
}
