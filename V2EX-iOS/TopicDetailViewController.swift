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
//import UITableView_FDTemplateLayoutCell

class TopicDetailViewController: BaseViewController, DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate, UITableViewDataSource, UITableViewDelegate {
    var topicID:Int?
    var topicDetailModel: TopicDetailModel?
    lazy var headerView: DTAttributedTextView = {
        [unowned self] in
        
        let dt = DTAttributedTextView(frame: CGRectMake(0, 0, self.view.bounds.width, 1))
        dt.delegate = self
        dt.attributedTextContentView.delegate = self
        dt.shouldDrawImages = false
        dt.attributedTextContentView.shouldLayoutCustomSubviews = true
        self.view.addSubview(dt)
        return dt
    }()
    lazy var tableView: UITableView = {
        [unowned self] in
        
        let tableView = UITableView(frame: self.view.bounds, style: .Plain)
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
        return tableView
    }()
    
    let topicDetailContentCellIdentifier = "com.cielpy.v2ex.detailcontent"
    
    var replies = [TopicReplyModel]()
    var cellRowHeightDictionary = [NSIndexPath: CGFloat]()

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cellContentHasNewHeight:", name: TopicReplyCellContentHasNewHeightNotification, object: nil)

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.whiteColor()
        
        tableView.registerClass(TopicReplyTableViewCell.self, forCellReuseIdentifier: topicDetailContentCellIdentifier)
        
//        topicID = 182391
        
        DataManager.loadTopicDetailContent(topicID!) { (completion) -> Void in
            self.topicDetailModel = completion.data
            self.title = self.topicDetailModel!.title
            
            let options = [DTDefaultFontSize: NSNumber(float: 15),
                DTMaxImageSize: NSValue.init(CGSize: CGSizeMake(self.view.bounds.width - 20, 10000)),
                NSBaseURLDocumentOption: NSURL.fileURLWithPath(V2EX_BASE_URL, isDirectory: true),
                DTDefaultLinkColor: "#778087"
            ]
            
            let att = DTHTMLAttributedStringBuilder(HTML: self.topicDetailModel!.content_rendered?.dataUsingEncoding(NSUTF8StringEncoding), options: options, documentAttributes: nil)
            self.headerView.attributedString = att.generatedAttributedString()
        }
        
        DataManager.loadTopicDetailReplies(topicID!) { (completion) -> Void in
            if let arr = completion.data as NSArray! {
                if arr.count > 0 {
                    self.replies = arr as! [TopicReplyModel]
//                    let a = arr as! [TopicReplyModel]
//                    self.replies.append(a.first!)
                    while self.replies.count > 2 {
                        self.replies.removeLast()
                    }
                    self.tableView.reloadData()
                }
            }
        }
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
//        let height = tableView.fd_heightForCellWithIdentifier(topicDetailContentCellIdentifier, configuration: { (cell) -> Void in
//            if let c = cell as! TopicReplyTableViewCell? {
//                self.configurationCell(c, indexPath: indexPath)
//            }
//        })
//        print(height)
        if let height = cellRowHeightDictionary[indexPath] {
            let returnHeight = height + SPACING_BEWTWEEN_COMPONENTS + MARGIN_TO_BOUNDARY
            print("\(indexPath.row)   return height \(returnHeight)")
            return returnHeight
        }
        else {
            return 0
        }
    }
    
    func cellContentHasNewHeight(notification: NSNotification) {
        let info = notification.userInfo as! [NSIndexPath: CGFloat]
        let indexPath = info.keys.first!
        print("----->> \(indexPath.row)")
        print("----->> \(info[indexPath])")
        if cellRowHeightDictionary[indexPath] == nil{
            let newHeight = info[indexPath]
            cellRowHeightDictionary[indexPath] = newHeight
            tableView.reloadData()
//            tableView.reloadRowAtIndexPath(indexPath, withRowAnimation: UITableViewRowAnimation.None)
        }
        else {
            let oldHeight = cellRowHeightDictionary[indexPath]
            let newHeight = info[indexPath]
            if oldHeight == newHeight {
                print("same height, nothin to do")
            }
            else {
                cellRowHeightDictionary[indexPath] = newHeight
                tableView.reloadData()
//                tableView.reloadRowAtIndexPath(indexPath, withRowAnimation: UITableViewRowAnimation.None)
            }
        }
    }
    
    func configurationCell(cell: TopicReplyTableViewCell, indexPath: NSIndexPath) {
        cell.indexPath = indexPath
        let reply = replies[indexPath.row] as TopicReplyModel
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
        
        var didUpdate = false
        if let res = headerView.attributedTextContentView.layoutFrame.textAttachmentsWithPredicate(pred) {
            for index in 0..<res.count {
                let att = res[index] as! DTTextAttachment
                att.originalSize = size
                didUpdate = true
            }
        }
        
        if didUpdate {
            headerView.attributedTextContentView.layouter = nil
            headerView.relayoutText()
        }
    }
    
    func attributedTextContentView(attributedTextContentView: DTAttributedTextContentView!, didDrawLayoutFrame layoutFrame: DTCoreTextLayoutFrame!, inContext context: CGContext!) {
        var f:CGRect = headerView.frame
        f.size.height = layoutFrame.frame.size.height
        headerView.frame = f
        tableView.tableHeaderView = headerView
        
        print(layoutFrame.frame.size.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
