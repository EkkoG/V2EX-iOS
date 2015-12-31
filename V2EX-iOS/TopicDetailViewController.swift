//
//  TopicDetailViewController.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/1.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import Kingfisher
import Async
import UITableView_FDTemplateLayoutCell
import EZSwiftExtensions
import NYTPhotoViewer
import SafariServices

class TopicDetailViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate, UIScrollViewDelegate {
    var topicID:Int!
    var topicDetailModel: TopicDetailModel?
    lazy var headerWebView: UIWebView = {
        [unowned self] in
        let webView = UIWebView(frame: CGRectMake(0, 0, self.view.bounds.width, 1))
        webView.delegate = self
        webView.scrollView.scrollEnabled = false
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
    
    override func canBecomeFirstResponder() -> Bool {
        
        return true
    }
    
    override func canResignFirstResponder() -> Bool {
        
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        
        return true
    }
    
    override var inputAccessoryView: UIView? {
        
        return accessoryView
    }
    
    let accessoryView = InputAccessoryView()
    
    deinit {
//        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        delegate.cellHeightCeche[self.topicID] = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarController?.tabBar.hidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "chooseMember:", name: kChooseMemberInCellNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "chooseImage:", name: kChooseImageInCellNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "chooseLink:", name: kChooseLinkInCellNOtification, object: nil)
        
        accessoryView.handlers.tapSendButton = { _ in
            guard let text = self.accessoryView.growingTextView!.text else {
                print("内容为空")
                return
            }
            
            DataManager.reply(text, topicID: self.topicID, completeHander: { (dataResponse) -> Void in
                if let _ = dataResponse.data {
                    self.accessoryView.growingTextView?.resignFirstResponder()
                    self.accessoryView.growingTextView?.text = nil
                    print("评论成功")
                }
            })
        }
        
        self.view.addSubview(self.headerWebView)
        self.view.addSubview(self.tableView)
        view.backgroundColor = UIColor.whiteColor()
        
        self.tableView.registerClass(TopicReplyTableViewCell.self, forCellReuseIdentifier: topicDetailContentCellIdentifier)
        //hard code
        self.tableView.height -= 105
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cellContentHasNewHeight:", name: TopicReplyCellContentHasNewHeightNotification, object: nil)
        
//        self.topicID = 182391
//        self.topicID = 245188
        
        DataManager.loadTopicDetailContent(self.topicID!) { (completion) -> Void in
            guard let data = completion.data else {
                return
            }
            
            self.topicDetailModel = data
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let model = self.replies[indexPath.row]
        self.replyMember(model.member!.username!)
    }
    
    func replyMember(memberName: String) {
        self.accessoryView.growingTextView?.text = "@\(memberName) "
        self.accessoryView.growingTextView?.becomeFirstResponder()
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.accessoryView.growingTextView!.resignFirstResponder()
    }
    
    func chooseImage(notification: NSNotification) {
        let image = notification.object as! UIImage
        
        let photo = TopicReplyPhoto(image: image)
        let browser = NYTPhotosViewController(photos: [photo])
        self.presentVC(browser)
    }
    
    func chooseLink(notification: NSNotification) {
        let url = notification.object as! String
        let sf = SFSafariViewController(URL: NSURL(string: url)!)
        self.presentVC(sf)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
