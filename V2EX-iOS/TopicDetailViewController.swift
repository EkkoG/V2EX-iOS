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
import UITableView_FDTemplateLayoutCell

class TopicDetailViewController: BaseViewController, DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate, UITableViewDataSource, UITableViewDelegate {
    var topicID:Int?
    var topicDetailModel: TopicDetailModel?
    var dt: DTAttributedTextView?
    var tableView: UITableView?
    
    let topicDetailContentCellIdentifier = "com.cielpy.v2ex.detailcontent"
    
    var replies = [TopicReplyModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.whiteColor()
        
        tableView = UITableView(frame: self.view.bounds, style: .Plain)
        tableView?.dataSource = self
        tableView?.delegate = self
        self.view.addSubview(tableView!)
        
        tableView?.registerClass(TopicReplyTableViewCell.self, forCellReuseIdentifier: topicDetailContentCellIdentifier)
        
        let dt = DTAttributedTextView(frame: CGRectMake(0, 0, self.view.bounds.width, 1))
        self.dt = dt
        self.view.addSubview(dt)
        
        topicID = 241009
        
        DataManager.loadTopicDetailContent(topicID!) { (completion) -> Void in
            self.topicDetailModel = completion.data
            
            var dic = [String: AnyObject]()
            dic[NSDocumentTypeDocumentAttribute] = NSHTMLTextDocumentType
            dic[NSCharacterEncodingDocumentAttribute] = "\(NSUTF8StringEncoding)"
            
            let options = [DTDefaultFontSize: NSNumber(float: 15),
                DTMaxImageSize: NSValue.init(CGSize: CGSizeMake(self.view.bounds.width - 20, self.view.bounds.height - 60)),
                NSBaseURLDocumentOption: NSURL.fileURLWithPath(V2EX_BASE_URL, isDirectory: true),
                DTDefaultLinkColor: "#778087"
            ]
            
            let att = DTHTMLAttributedStringBuilder(HTML: self.topicDetailModel!.content_rendered?.dataUsingEncoding(NSUTF8StringEncoding), options: options, documentAttributes: nil)
            dt.delegate = self
            dt.attributedTextContentView.delegate = self
            dt.shouldDrawImages = false
//            dt.shouldLayoutCustomSubviews = true
            dt.attributedString = att.generatedAttributedString()
        }
        
        
//        DataManager.loadTopicDetailReplies(topicID!) { (completion) -> Void in
//            if let arr = completion.data as NSArray! {
//                if arr.count > 0 {
//                    self.replies = arr as! [TopicReplyModel]
//                    self.tableView?.reloadData()
//                }
//                
//            }
//        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(topicDetailContentCellIdentifier, forIndexPath: indexPath) as! TopicReplyTableViewCell
        configurationCell(cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replies.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = tableView.fd_heightForCellWithIdentifier(topicDetailContentCellIdentifier, configuration: { (cell) -> Void in
            if let c = cell as! TopicReplyTableViewCell? {
                self.configurationCell(c, indexPath: indexPath)
            }
        })
        print(height)
        return height
    }
    
    func configurationCell(cell: TopicReplyTableViewCell, indexPath: NSIndexPath) {
        cell.fd_enforceFrameLayout = true
        let reply = self.replies[indexPath.row] as TopicReplyModel
        cell.replyModel = reply
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
        
        if let res = self.dt?.attributedTextContentView.layoutFrame.textAttachmentsWithPredicate(pred) {
            for index in 0..<res.count {
                let att = res[index] as! DTTextAttachment
                att.originalSize = size
            }
        }
        
        self.dt?.attributedTextContentView.layouter = nil
        self.dt?.relayoutText()
    }
    
    func attributedTextContentView(attributedTextContentView: DTAttributedTextContentView!, didDrawLayoutFrame layoutFrame: DTCoreTextLayoutFrame!, inContext context: CGContext!) {
        var f:CGRect = self.dt!.frame
        f.size.height = layoutFrame.frame.size.height
        self.dt?.frame = f
        tableView?.tableHeaderView = self.dt!
        
        print(layoutFrame.frame.size.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
