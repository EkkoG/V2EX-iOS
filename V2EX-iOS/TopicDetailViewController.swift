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
//import UITableView_FDTemplateLayoutCell

class TopicDetailViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate {
    var topicID:Int?
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
        return tableView
    }()
    
    let topicDetailContentCellIdentifier = "com.cielpy.v2ex.detailcontent"
    
    var replies = [TopicReplyModel]()
    var cellRowHeightDictionary = [NSIndexPath: CGFloat]()

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cellContentHasNewHeight:", name: TopicReplyCellContentHasNewHeightNotification, object: nil)

        // Do any additional setup after loading the view.
        self.view.addSubview(self.headerWebView)
        self.view.addSubview(tableView)
        view.backgroundColor = UIColor.whiteColor()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: topicDetailContentCellIdentifier)
        
//        topicID = 85402
        
        DataManager.loadTopicDetailContent(topicID!) { (completion) -> Void in
            self.topicDetailModel = completion.data
            self.title = self.topicDetailModel!.title
            if let content = self.topicDetailModel?.content_rendered {
                
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
//
        DataManager.loadTopicDetailReplies(topicID!) { (completion) -> Void in
            if let arr = completion.data as NSArray! {
                if arr.count > 0 {
                    self.replies = arr as! [TopicReplyModel]
//                    let a = arr as! [TopicReplyModel]
//                    self.replies.append(a.first!)
//                    while self.replies.count > 2 {
//                        self.replies.removeLast()
//                    }
                }
                Async.main(block: { () -> Void in
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(topicDetailContentCellIdentifier, forIndexPath: indexPath) 
//        configurationCell(cell, indexPath: indexPath)
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
        return 100
    }
    
//    func cellContentHasNewHeight(notification: NSNotification) {
//        let info = notification.userInfo as! [NSIndexPath: CGFloat]
//        let indexPath = info.keys.first!
//        print("----->> \(indexPath.row)")
//        print("----->> \(info[indexPath])")
//        if cellRowHeightDictionary[indexPath] == nil{
//            let newHeight = info[indexPath]
//            cellRowHeightDictionary[indexPath] = newHeight
//            tableView.reloadData()
////            tableView.reloadRowAtIndexPath(indexPath, withRowAnimation: UITableViewRowAnimation.None)
//        }
//        else {
//            let oldHeight = cellRowHeightDictionary[indexPath]
//            let newHeight = info[indexPath]
//            if oldHeight == newHeight {
//                print("same height, nothin to do")
//            }
//            else {
//                cellRowHeightDictionary[indexPath] = newHeight
//                tableView.reloadData()
////                tableView.reloadRowAtIndexPath(indexPath, withRowAnimation: UITableViewRowAnimation.None)
//            }
//        }
//    }
    
    func configurationCell(cell: TopicReplyTableViewCell, indexPath: NSIndexPath) {
        cell.indexPath = indexPath
        let reply = replies[indexPath.row] as TopicReplyModel
        cell.replyModel = reply
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        var f: CGRect = webView.frame
        f.size.height = webView.scrollView.contentSize.height
        headerWebView.frame = f
        tableView.tableHeaderView = headerWebView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
