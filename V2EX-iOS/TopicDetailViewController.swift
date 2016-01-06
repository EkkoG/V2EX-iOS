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

class TopicDetailViewController: BaseViewController, UIWebViewDelegate, UIScrollViewDelegate {
    
    let kTopicDetailContentCellIdentifier = "com.cielpy.v2ex.TopicDetailContent.CellIdentifier"
    
    let accessoryView = InputAccessoryView()
    
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
        //        tableView.fd_debugLogEnabled = true
        return tableView
        }()
    
    
    var replies = [TopicReplyModel]()
    
    var cellRowHeightDictionary = [NSIndexPath: CGFloat]()
    
    var contentWebViewLoaed = false
    
    
    deinit {
        //        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //        delegate.cellHeightCeche[self.topicID] = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "chooseImage:", name: kCTTouchImageNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "chooseLink:", name: kCTTouchLinkNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cellContentHasNewHeight:", name: kTopicDetailCellHasNewHeightNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //        self.topicID = 182391
        //        self.topicID = 245188
        self.setupViews()
        self.setupAccessoryView()
        self.loadData()
    }
    
    func setupViews() {
        self.view.addSubview(self.headerWebView)
        self.view.addSubview(self.tableView)
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.tableView.registerClass(TopicReplyTableViewCell.self, forCellReuseIdentifier: kTopicDetailContentCellIdentifier)
        //hard code
        self.tableView.height -= 105
    }
    
    func setupAccessoryView () {
        self.accessoryView.handlers.tapSendButton = { _ in
            guard let text = self.accessoryView.growingTextView!.text else {
                print("内容为空")
                return
            }
            self.replyRequest(text, content: self.topicID)
        }
    }
    
    func replyRequest(text: String, content: Int) {
        DataManager.reply(text, topicID: self.topicID, completeHander: { (dataResponse) -> Void in
            if let _ = dataResponse.data {
                self.accessoryView.growingTextView?.resignFirstResponder()
                self.accessoryView.growingTextView?.text = nil
                print("评论成功")
            }
        })
    }
    
    func loadData() {
        DataManager.loadTopicDetailContent(self.topicID!) { (completion) -> Void in
            guard let data = completion.data else {
                return
            }
            
            self.topicDetailModel = data
            self.title = data.title
            
            let tuple = data.HTMLContentAndBaseURL()
            guard let html = tuple.html where tuple.html?.length > 0 else {
                return
            }
            
            self.headerWebView.loadHTMLString(html, baseURL: tuple.baseURL!)
        }
        
        DataManager.loadTopicDetailReplies(self.topicID!) { (completion) -> Void in
            guard let data = completion.data else {
                return
            }
            
            self.replies = data
            
            Async.main(block: { () -> Void in
                self.tableView.reloadData()
            })
        }
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
        let reply = self.replies[indexPath.row]
        cell.replyModel = reply
        
        cell.tapAvatar = { _ in
            self.gotoMemberProfile(reply.member!.username!)
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.headerWebView.height = webView.scrollView.contentSize.height
        
        self.headerWebView.addBorderBottom(size: 1, color: kListViewHeaderViewBackroundColor)
        
        self.tableView.tableHeaderView = headerWebView
        
        
        self.contentWebViewLoaed = true
        self.tableView.reloadData()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.accessoryView.growingTextView!.resignFirstResponder()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension TopicDetailViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kTopicDetailContentCellIdentifier, forIndexPath: indexPath) as! TopicReplyTableViewCell
        self.configurationCell(cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.contentWebViewLoaed == true else {
            return 0
        }
        return self.replies.count
    }
}

extension TopicDetailViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = tableView.fd_heightForCellWithIdentifier(kTopicDetailContentCellIdentifier, cacheByIndexPath: indexPath) { (cell) -> Void in
            self.configurationCell(cell as! TopicReplyTableViewCell, indexPath: indexPath)
        }
        //        print("indexPath \(indexPath.row) height \(height)")
        return height
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let model = self.replies[indexPath.row]
        self.replyMember(model.member!.username!)
    }
    
}

extension TopicDetailViewController {
    func chooseImage(notification: NSNotification) {
        let image = notification.object as! UIImage
        
        let photo = TopicReplyPhoto(image: image)
        let browser = NYTPhotosViewController(photos: [photo])
        self.presentVC(browser)
    }
    
    func chooseLink(notification: NSNotification) {
        let url = notification.object as! CoreTextLinkData
        if url.isMemberLink == true {
            self.gotoMemberProfile(url.memberName!)
        }
        else {
            let sf = SFSafariViewController(URL: NSURL(string: url.url! as String)!)
            self.presentVC(sf)
        }
    }
    
    func gotoMemberProfile(username: String) {
        let profile = UserProfileViewController()
        profile.username = username
        self.navigationController!.pushViewController(profile, animated: true)
    }
}

extension TopicDetailViewController {
    
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
        
        return self.accessoryView
    }
    
}