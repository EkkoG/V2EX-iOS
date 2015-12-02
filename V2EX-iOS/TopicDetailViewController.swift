//
//  TopicDetailViewController.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/1.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import DTCoreText
import Kingfisher

class TopicDetailViewController: BaseViewController, DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate {
    var topicID:Int?
    var topicDetailModel: TopicDetailModel?
    var dt: DTAttributedLabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.whiteColor()
//        DataManager.loadStringDataFromURL("http://news.163.com/") { (completion) -> Void in
//            do {
//                var dic = [String: AnyObject]()
//                dic[NSDocumentTypeDocumentAttribute] = NSHTMLTextDocumentType
//                dic[NSCharacterEncodingDocumentAttribute] = "\(NSUTF8StringEncoding)"
//                
//                let attributedString = try NSAttributedString(data: (completion.data!.dataUsingEncoding(NSUTF8StringEncoding))!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: "\(NSUTF8StringEncoding)"], documentAttributes: nil)
//                
//                let dt = DTAttributedLabel(frame: self.view.bounds)
//                dt.delegate = self
//                dt.shouldDrawImages = false
//                dt.attributedString = attributedString
//                dt.shouldLayoutCustomSubviews = true
//                self.view.addSubview(dt)
//            }
//            catch {
//                
//                }
//            
//        }
        
        DataManager.loadTopicDetailContent(240498) { (completion) -> Void in
            self.topicDetailModel = completion.data
            
            var dic = [String: AnyObject]()
            dic[NSDocumentTypeDocumentAttribute] = NSHTMLTextDocumentType
            dic[NSCharacterEncodingDocumentAttribute] = "\(NSUTF8StringEncoding)"
            
//                let attributedString = try NSAttributedString(data: (self.topicDetailModel?.content_rendered?.dataUsingEncoding(NSUTF8StringEncoding))!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: "\(NSUTF8StringEncoding)"], documentAttributes: nil)
            
            let att = DTHTMLAttributedStringBuilder(HTML: self.topicDetailModel!.content_rendered?.dataUsingEncoding(NSUTF8StringEncoding), options: [NSBaseURLDocumentOption: [NSURL .fileURLWithPath("https://www.v2ex.com", isDirectory: true)], DTMaxImageSize: NSValue.init(CGSize: CGSizeMake(300, 200))], documentAttributes: nil)
            let dt = DTAttributedLabel(frame: self.view.bounds)
            dt.delegate = self
            dt.shouldDrawImages = false
            dt.shouldLayoutCustomSubviews = true
            dt.attributedString = att.generatedAttributedString()
            self.dt = dt
            self.view.addSubview(dt)
        }
        
    }
    
    func attributedTextContentView(attributedTextContentView: DTAttributedTextContentView!, viewForAttachment attachment: DTTextAttachment!, frame: CGRect) -> UIView! {
        if attachment.isKindOfClass(DTImageTextAttachment){
            let imageView = DTLazyImageView(frame: frame)
            imageView.delegate = self
            imageView.url = attachment.contentURL
            return imageView
            
        }
        return nil
    }
    
    func lazyImageView(lazyImageView: DTLazyImageView!, didChangeImageSize size: CGSize) {
        let url = lazyImageView.url
        let pred = NSPredicate(format: "contentURL == %@", url)
        
        if let res = self.dt?.layoutFrame.textAttachmentsWithPredicate(pred) {
            for index in 0...res.count-1 {
                var att = res[index] as! DTTextAttachment
                att.originalSize = size
            }
        }
        
        self.dt?.layouter = nil
        self.dt?.relayoutText()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
