//
//  CTFrameParser.swift
//  CoreTextTest
//
//  Created by ciel on 15/12/14.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import Ji

let ImageHasDownloadedNotification = "com.cielpy.coretext.imagehasdownloaded"

class CTFrameParser: NSObject {
    
    class func parseHTMLString(html: String, config: CTFrameParserConfig) -> CoreTextData {
        let imageArray = NSMutableArray()
        let linkArray = NSMutableArray()
        
        let attributedString = self.parseHTMLString(html, imageArray: imageArray, linkArray: linkArray, config: config)
        
        let data = self.parseAttributedContent(attributedString, config: config)
        
        data.imageArray = imageArray
        data.linkArray = linkArray
        data.content = NSMutableAttributedString(attributedString: attributedString)
        
        return data
    }
    
    class func parseHTMLString(html: String, imageArray: NSMutableArray, linkArray: NSMutableArray, config: CTFrameParserConfig) -> NSAttributedString {
        let doc = Ji(htmlString: html)
        
        let attributedString = NSMutableAttributedString()
        
        if let allNode = doc?.xPath("//body/*/node()") {
            
            for node in allNode {
//                print(node.rawContent)
                if node.tag == "a" {
                    let startPosition = attributedString.length
                    
                    let linkData = CoreTextLinkData()
                    linkData.title = node.content
                    linkData.url = node["href"]
                    
                    let dic = NSDictionary(objects: ["blue", NSNumber(float: 16) , node.content!], forKeys: ["color", "size", "content"])
                    let attribute = self.parseAttributedContentFromDictionary(dic, config: config)
                    attributedString.appendAttributedString(attribute)
                    
                    let length = attributedString.length - startPosition
                    let linkRange = NSMakeRange(startPosition, length)
                    linkData.range = linkRange
                    linkArray.addObject(linkData)
                    continue
                }
                else if node.tag == "br" {
                    let dic = NSDictionary(objects: ["", NSNumber(float: 15) , "\n"], forKeys: ["color", "size", "content"])
                    let attribute = self.parseAttributedContentFromDictionary(dic, config: config)
                attributedString.appendAttributedString(attribute)
                    continue
                }
                else if node.tag == "img" {
                    let imageData = CoreTextImageData()
                    imageData.imageURL = node["src"]
                    imageData.position = attributedString.length
                    
                    
                    imageData.image = UIImage(named: "ic_launcher144")
                    imageArray.addObject(imageData)
                    let attribute = CoreTextImageRunDelegateHelper.parseImageDataFromNSDictionary(imageData.image)
                    attributedString.appendAttributedString(attribute)
                    continue
                }
                
                let dic = NSDictionary(objects: ["", NSNumber(float: 15) , node.content!], forKeys: ["color", "size", "content"])
                let attribute = self.parseAttributedContentFromDictionary(dic, config: config)
                attributedString.appendAttributedString(attribute)
            }
        }
        
        return attributedString
    }
    
    
    class func parseTemplateFile(path: String, config: CTFrameParserConfig) -> CoreTextData {
        let imageArray = NSMutableArray()
        let linkArray = NSMutableArray()
        
        let content = self.loadTemplateFile(path, imageArray: imageArray,linkArray: linkArray, config: config)
        let imageData = self.parseAttributedContent(content, config: config)
        imageData.imageArray = imageArray
        imageData.linkArray = linkArray
        return imageData
    }
    
    class func loadTemplateFile(path: String, imageArray:NSMutableArray, linkArray: NSMutableArray, config: CTFrameParserConfig) -> NSAttributedString {
        let data = NSData(contentsOfFile: path)
        let result = NSMutableAttributedString()
        if let d = data {
            do {
                let array = try NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions.AllowFragments)
                if array is NSArray {
                    for dict in array as! NSArray {
                        if dict is NSDictionary {
                            let dic = dict as! NSDictionary
                            let type = dic["type"] as! String
                            if type == "txt" {
                                let attributeString = self.parseAttributedContentFromDictionary(dic, config: config)
                                result.appendAttributedString(attributeString)
                            }
                            else if type == "img" {
                                let imageData = CoreTextImageData()
                                imageData.name = dic["name"] as? String
                                imageData.position = result.length
                                if let image = UIImage(named: dic["name"] as! String) {
                                    imageData.image = image
                                }
                                else {
                                    imageData.image = UIImage(named: "ic_launcher144")
                                }
                                imageArray.addObject(imageData)
                                let attribute = CoreTextImageRunDelegateHelper.parseImageDataFromNSDictionary(imageData.image)
                                result.appendAttributedString(attribute)
                            }
                            else if type == "link" {
                                let startPosition = result.length
                                let attribute = self.parseAttributedContentFromDictionary(dic, config: config)
                                result.appendAttributedString(attribute)
                                let length = result.length - startPosition
                                let linkRange = NSMakeRange(startPosition, length)
                                let linkData = CoreTextLinkData()
                                linkData.title = dic["content"] as? String
                                linkData.url = dic["url"] as? String
                                linkData.range = linkRange
                                linkArray.addObject(linkData)
                            }
                        }
                    }
                }
            }
            catch {
                
            }
        }
        return result
    }
    
    class func parseImageDataFromDictionary(image: UIImage, config:CTFrameParserConfig) -> NSAttributedString {
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
        let attribute = self.attributesWithConfig(config)
        let space = NSMutableAttributedString(string: content as String, attributes: attribute)
        CFAttributedStringSetAttribute(space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate)
        return space
    }
    
    class func parseAttributedContentFromDictionary(dict: NSDictionary, config: CTFrameParserConfig) -> NSAttributedString {
        var attributes = self.attributesWithConfig(config)
        
        if let colorString = dict["color"] {
            let color = self.colorFromTemplate(colorString as! String)
            attributes[kCTForegroundColorAttributeName as String] = color.CGColor
        }
        
        if let fontSize = dict["size"] {
            let fontRef = CTFontCreateWithName("ArialMT", fontSize as! CGFloat, nil)
            attributes[kCTFontAttributeName as String] = fontRef
        }
        
        let content = dict["content"] as! String
        return NSAttributedString(string: content, attributes: attributes)
    }
    
    internal class func colorFromTemplate(name: String) -> UIColor {
        if name == "blue" {
            return UIColor.blueColor()
        }
        else if name == "red" {
            return UIColor.redColor()
        }
        else {
            return UIColor.blackColor()
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
    
//    class func createCoreTextData
    
    internal class func createFrameWithFramesetter(settter: CTFramesetterRef, config: CTFrameParserConfig, height: CGFloat) ->  CTFrameRef {
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, CGRectMake(0, 0, config.width, height))
        
        let frame = CTFramesetterCreateFrame(settter, CFRangeMake(0, 0), path, nil)
        return frame
    }
}
