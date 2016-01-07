//
//  CTFrameParser.swift
//  CoreTextTest
//
//  Created by ciel on 15/12/14.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import Ji

enum TagName: String {
    case A = "a"
    case BR = "br"
    case IMG = "img"
    case NONE = "none"
}

class CTFrameParser: NSObject {
    
    class func parseHTMLString(html: String, width: CGFloat) -> CoreTextData {
        
        let tuple = self.parseHTML(html)
        
        let data = self.parseAttributedContent(tuple.2, width: width)
        
        data.imageArray = tuple.0
        data.linkArray = tuple.1
        data.content = NSMutableAttributedString(attributedString: tuple.2)
        return data
    }
    
    class func parseHTML(html: String) -> ([CoreTextImageData], [CoreTextLinkData], NSAttributedString) {
        let doc = Ji(htmlString: html)
        
        let attributedString = NSMutableAttributedString()
        
        var imageArray = [CoreTextImageData]()
        var linkArray = [CoreTextLinkData]()
        if let allNode = doc?.xPath("//body/*/node()") {
            
            for node in allNode {
                //                print(node.rawContent)
                if node.tag == "a" {
                    let startPosition = attributedString.length
                    
                    let linkData = CoreTextLinkData()
                    linkData.title = node.content
                    linkData.url = node["href"]
                    
                    let attribute = self.attributedStringWithTagName(node.content!, tagName: .A)
                    attributedString.appendAttributedString(attribute)
                    
                    let length = attributedString.length - startPosition
                    let linkRange = NSMakeRange(startPosition, length)
                    linkData.range = linkRange
                    linkArray.append(linkData)
                    continue
                }
                else if node.tag == "br" {
                    let attribute = self.attributedStringWithTagName(node.content!, tagName: .BR)
                    attributedString.appendAttributedString(attribute)
                    continue
                }
                else if node.tag == "img" {
                    let imageData = CoreTextImageData()
                    imageData.imageURL = node["src"]
                    imageData.position = attributedString.length
                    
                    
                    imageData.image = UIImage(named: "ic_launcher144")
                    imageArray.append(imageData)
//                    let attribute = self.attributedStringWithTagName(node.content!, tagName: .IMG)
                    
                    let config = CTFrameParserConfig()
                    let attributes = self.attributesWithConfig(config)
                    let attribute = CoreTextImageRunDelegateHelper.parseAttributedContentFromDictionary(imageData.image!, attributes: attributes)
                    attributedString.appendAttributedString(attribute)
                    continue
                }
                
                let attribute = self.attributedStringWithTagName(node.content!, tagName: .NONE)
                attributedString.appendAttributedString(attribute)
            }
        }
        
        return (imageArray, linkArray, attributedString)
    }
    
    class func attributedStringWithTagName(content: String, tagName: TagName) -> NSAttributedString {
        switch tagName {
        case .A:
            let config = CTFrameParserConfig(textColor:kHTMLATagColor)
            let attributes = self.attributesWithConfig(config)
            return NSAttributedString(string: content, attributes: attributes)
        case .BR:
            let config = CTFrameParserConfig()
            let attributes = self.attributesWithConfig(config)
            return NSAttributedString(string: content, attributes: attributes)
        case .IMG:
            let config = CTFrameParserConfig()
            let image = UIImage(named: "ic_launcher144")
            let attributes = self.attributesWithConfig(config)
            return CoreTextImageRunDelegateHelper.parseAttributedContentFromDictionary(image, attributes: attributes)
        case .NONE:
            let config = CTFrameParserConfig()
            let attributes = self.attributesWithConfig(config)
            return NSAttributedString(string: content, attributes: attributes)
        }
    }
    
    
    class func attributesWithConfig(config: CTFrameParserConfig) -> [String: AnyObject]{
        let fontSize = config.fontSize
        let fontRef = CTFontCreateWithName("ArialMT", fontSize, nil)
        
        var lineSpacing = config.lineSpace
        
        let paragraphSettings = [
            CTParagraphStyleSetting(spec: .MinimumLineSpacing, valueSize: sizeof(CGFloat), value: &lineSpacing),
            CTParagraphStyleSetting(spec: .MaximumLineSpacing, valueSize: sizeof(CGFloat), value: &lineSpacing),
            CTParagraphStyleSetting(spec: .LineSpacingAdjustment, valueSize: sizeof(CGFloat), value: &lineSpacing)
        ]
        
        let paragraphRef = CTParagraphStyleCreate(paragraphSettings, paragraphSettings.count)
        
        let textColor = config.textColor
        
        var attributes = [String: AnyObject]()
        attributes[kCTForegroundColorAttributeName as String] = textColor.CGColor
        attributes[kCTFontAttributeName as String] = fontRef
        attributes[kCTParagraphStyleAttributeName as String] = paragraphRef
        return attributes
    }
    
    class func parseAttributedContent(attributeString: NSAttributedString, width: CGFloat) -> CoreTextData {
        
        let framesetter = CTFramesetterCreateWithAttributedString(attributeString)
        
        let restrictSize = CGSizeMake(width, CGFloat.max)
        let coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attributeString.length), nil, restrictSize, nil)
        let textHeight = coreTextSize.height
        
        let frame = self.createFrameWithFramesetter(framesetter, width: width, height: textHeight)
        
        let coreTextData = CoreTextData()
        coreTextData.ctFrame = frame
        coreTextData.height = textHeight
        coreTextData.content = NSMutableAttributedString(attributedString: attributeString)
        
        return coreTextData
    }
    
    internal class func createFrameWithFramesetter(settter: CTFramesetterRef, width: CGFloat, height: CGFloat) ->  CTFrameRef {
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, CGRectMake(0, 0, width, height))
        
        let frame = CTFramesetterCreateFrame(settter, CFRangeMake(0, 0), path, nil)
        return frame
    }
}
