//
//  TopicDetailViewController.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/1.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import Kingfisher
import Async
import UITableView_FDTemplateLayoutCell
import EZSwiftExtensions

class TopicDetailViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate {
    var topicID:Int!
    var topicDetailModel: TopicDetailModel?
    lazy var headerWebView: UIWebView = {
        [unowned self] in
        let webView = UIWebView(frame: CGRectMake(0, 0, self.view.bounds.width, 1))
        webView.delegate = self
        return webView
    }()
    lazy var tableView: UITableView = {
        [unowned self] in
        
        let tableView = UITableView(frame: self.view.bounds, style: .Plain)
        tableView.dataSource = self
        tableView.delegate = self
//        tableView.backgroundColor = UIColor.yellowColor()
//        tableView.fd_debugLogEnabled = true
        return tableView
    }()
    
    let topicDetailContentCellIdentifier = "com.cielpy.v2ex.detailcontent"
    
    var replies = [TopicReplyModel]()
    var cellRowHeightDictionary = [NSIndexPath: CGFloat]()
    
    var cellHeightCeche = [String :CoreTextData]()
    
    var contentWebViewLoaed = false
    
    deinit {
//        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        delegate.cellHeightCeche[self.topicID] = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubview(self.headerWebView)
        self.view.addSubview(self.tableView)
        view.backgroundColor = UIColor.whiteColor()
        
        self.tableView.registerClass(TopicReplyTableViewCell.self, forCellReuseIdentifier: topicDetailContentCellIdentifier)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cellContentHasNewHeight:", name: TopicReplyCellContentHasNewHeightNotification, object: nil)
        
//        self.topicID = 182391
//        self.topicID = 245188
        
        DataManager.loadTopicDetailContent(self.topicID!) { (completion) -> Void in
            self.topicDetailModel = completion.data
            self.title = self.topicDetailModel!.title
            if let content = self.topicDetailModel!.content_rendered {
                
                do {
                    let htmlPath = NSBundle.mainBundle().pathForResource("topic", ofType: "html")
                    let htmlTemplate = try NSString.init(contentsOfFile: htmlPath!, encoding: NSUTF8StringEncoding)
                    let path = NSBundle.mainBundle().bundlePath
                    let baseURL = NSURL(fileURLWithPath: path)
                    let html = htmlTemplate.stringByReplacingOccurrencesOfString("CONTENT_BODY", withString: content)
                    self.headerWebView.loadHTMLString(html as String, baseURL: baseURL)
                }
                catch {
                    
                }
            }
        }
        
        DataManager.loadTopicDetailReplies(self.topicID!) { (completion) -> Void in
            if let arr = completion.data as NSArray! {
                if arr.count > 0 {
                    self.replies = arr as! [TopicReplyModel]
                }
                Async.main(block: { () -> Void in
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(topicDetailContentCellIdentifier, forIndexPath: indexPath) as! TopicReplyTableViewCell
        configurationCell(cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.contentWebViewLoaed == true else {
            return 0
        }
        return replies.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = tableView.fd_heightForCellWithIdentifier(topicDetailContentCellIdentifier, cacheByIndexPath: indexPath) { (cell) -> Void in
            if let c = cell as! TopicReplyTableViewCell? {
                self.configurationCell(c, indexPath: indexPath)
            }
        }
//        print("indexPath \(indexPath.row) height \(height)")
        return height
    }
    
    func cellContentHasNewHeight(notification: NSNotification) {
        let info = notification.object as! NSIndexPath
        self.tableView.fd_indexPathHeightCache.invalidateHeightAtIndexPath(info)
//        self.tableView.reloadRow(UInt(info.row), inSection: UInt(info.section), withRowAnimation: UITableViewRowAnimation.None)
        self.tableView.reloadData()
    }
    
    func configurationCell(cell: TopicReplyTableViewCell, indexPath: NSIndexPath) {
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.fd_enforceFrameLayout = true
        cell.indexPath = indexPath
        cell.topicID = self.topicID
        let reply = replies[indexPath.row] as TopicReplyModel
        cell.replyModel = reply
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        var f: CGRect = webView.frame
        f.size.height = webView.scrollView.contentSize.height
        self.headerWebView.frame = f
        
        self.headerWebView.addBorderBottom(size: 1, color: UIColor.init(hexString: "#e2e2e2"))
        
        self.tableView.tableHeaderView = headerWebView
        
        self.contentWebViewLoaed = true
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
