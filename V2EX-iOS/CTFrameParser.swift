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
    
    class func parseHTMLString(html: String, config: CTFrameParserConfig) -> CoreTextData {
        
        let tuple = self.parseHTML(html, config: config)
        
        let data = self.parseAttributedContent(tuple.2, config: config)
        
        data.imageArray = tuple.0
        data.linkArray = tuple.1
        data.content = NSMutableAttributedString(attributedString: tuple.2)
        return data
    }
    
    class func parseHTML(html: String, config: CTFrameParserConfig) -> ([CoreTextImageData], [CoreTextLinkData], NSAttributedString) {
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
                    
                    let attribute = self.attributedStringWithTagName(node.content!, config: config, tagName: .A)
                    attributedString.appendAttributedString(attribute)
                    
                    let length = attributedString.length - startPosition
                    let linkRange = NSMakeRange(startPosition, length)
                    linkData.range = linkRange
                    linkArray.append(linkData)
                    continue
                }
                else if node.tag == "br" {
                    let attribute = self.attributedStringWithTagName(node.content!, config: config, tagName: .BR)
                    attributedString.appendAttributedString(attribute)
                    continue
                }
                else if node.tag == "img" {
                    let imageData = CoreTextImageData()
                    imageData.imageURL = node["src"]
                    imageData.position = attributedString.length
                    
                    
                    imageData.image = UIImage(named: "ic_launcher144")
                    imageArray.append(imageData)
                    let attribute = CoreTextImageRunDelegateHelper.parseAttributedContentFromDictionary(imageData.image!)
                    attributedString.appendAttributedString(attribute)
                    continue
                }
                
                let attribute = self.attributedStringWithTagName(node.content!, config: config, tagName: .NONE)
                attributedString.appendAttributedString(attribute)
            }
        }
        
        return (imageArray, linkArray, attributedString)
    }
    
    class func parseImageDataFromDictionary(image: UIImage) -> NSAttributedString {
        var img = image
        var  imageCallback =  CTRunDelegateCallbacks(version: kCTRunDelegateCurrentVersion, dealloc: { (refCon) -> Void in
            }, getAscent: { ( refCon) -> CGFloat in
                let img = UnsafeMutablePointer<UIImage>(refCon).memory
                return img.size.height
            }, getDescent: { (refCon) -> CGFloat in
                return 0
            }) { (refCon) -> CGFloat in
                let img: UIImage = UnsafeMutablePointer<UIImage>(refCon).memory
                return img.size.width
        }
        
        let delegate = CTRunDelegateCreate(&imageCallback, &img)
        
        var objectReplacementChar:unichar = 0xFFFC
        let content = NSString(characters: &objectReplacementChar, length: 1)
        let space = NSMutableAttributedString(string: content as String)
        CFAttributedStringSetAttribute(space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate)
        return space
    }
    
    class func attributedStringWithTagName(content: String, config: CTFrameParserConfig?, tagName: TagName) -> NSAttributedString {
        var attributes = self.attributesWithConfig(config!)
        
        func tagAttributes(color: UIColor, fontSize: CGFloat) {
            
            attributes[kCTForegroundColorAttributeName as String] = color.CGColor
            
            let fontRef = CTFontCreateWithName("ArialMT", fontSize, nil)
            attributes[kCTFontAttributeName as String] = fontRef
        }
        
        switch tagName {
        case .A:
            tagAttributes(kHTMLATagColor, fontSize: 15)
            return NSAttributedString(string: content, attributes: attributes)
        case .BR:
            tagAttributes(kHTMLATagColor, fontSize: 15)
            return NSAttributedString(string: content, attributes: attributes)
        case .IMG:
            tagAttributes(kHTMLATagColor, fontSize: 15)
            return NSAttributedString(string: content, attributes: attributes)
        case .NONE:
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
    
    class func parseContent(content: String, config: CTFrameParserConfig) -> CoreTextData {
        let attributes = self.attributesWithConfig(config)
        let contentString = NSMutableAttributedString(string: content, attributes: attributes)
        
        return self.parseAttributedContent(contentString, config: config)
    }
    
    class func parseAttributedContent(attributeString: NSAttributedString, config: CTFrameParserConfig) -> CoreTextData {
        
        let framesetter = CTFramesetterCreateWithAttributedString(attributeString)
        
        let restrictSize = CGSizeMake(config.width, CGFloat.max)
        let coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attributeString.length), nil, restrictSize, nil)
        let textHeight = coreTextSize.height
        
        let frame = self.createFrameWithFramesetter(framesetter, config: config, height: textHeight)
        
        let coreTextData = CoreTextData()
        coreTextData.ctFrame = frame
        coreTextData.height = textHeight
        coreTextData.content = NSMutableAttributedString(attributedString: attributeString)
        
        return coreTextData
    }
    
    internal class func createFrameWithFramesetter(settter: CTFramesetterRef, config: CTFrameParserConfig, height: CGFloat) ->  CTFrameRef {
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, CGRectMake(0, 0, config.width, height))
        
        let frame = CTFramesetterCreateFrame(settter, CFRangeMake(0, 0), path, nil)
        return frame
    }
}
