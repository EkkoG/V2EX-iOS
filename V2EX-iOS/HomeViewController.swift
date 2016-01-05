//
//  HomeViewController.swift
//  V2EX-iOS
//
//  Created by ciel on 15/11/25.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import Cartography
import SwiftyJSON
import Async
import PullToRefresh

class HomeViewController: BaseViewController {
    let kHomeTopicsCellIdentifier = "com.cielpy.v2ex.home.cellIdentifier"
    var type: HomeTabs!
    var topicsTableView: UITableView!
    var topics: NSArray?
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.topicsTableView = UITableView(frame: self.view.bounds, style: .Plain)
        self.topicsTableView.dataSource = self
        self.topicsTableView.delegate = self
        self.topicsTableView.estimatedRowHeight = 60
        self.topicsTableView.rowHeight = UITableViewAutomaticDimension
        self.topicsTableView.registerClass(TopicTableViewCell.self, forCellReuseIdentifier: kHomeTopicsCellIdentifier)
        self.view.addSubview(self.topicsTableView)
        constrain(topicsTableView) { (view) -> () in
            view.edges == inset(view.superview!.edges, 0, 0, 0, 0)
        }
        
        print(self.type.title)
        
        self.loadData()
        
        self.topicsTableView.addPullToRefresh(PullToRefresh()) { () -> () in
            self.loadData()
        }
    }
    
    func loadData() {
        DataManager.loadTabsTopicsDataWithTabsPath(self.type.path) { (response) -> Void in
            self.topics = response.data
            self.topicsTableView.reloadData()
            self.topicsTableView.endRefreshing()
        }
    }
    
    func gotoNodeTopics(node: Node) {
        let nodeTopics = NodeTopicsViewController()
        nodeTopics.nodeModel = node
        self.navigationController!.pushViewController(nodeTopics, animated: true)
    }
    
    func gotoMemberProfile(username: String) {
        let profile = UserProfileViewController()
        profile.username = username
        self.navigationController!.pushViewController(profile, animated: true)
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

extension HomeViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kHomeTopicsCellIdentifier, forIndexPath: indexPath) as! TopicTableViewCell
        let topic = topics![indexPath.row] as! TopicModel
        cell.selectionStyle = .None
        cell.topic = topic
        cell.tapSendButton = { _ in
            self.gotoNodeTopics(topic.node!)
        }
        
        cell.tapAvatar = { _ in
            self.gotoMemberProfile(topic.member!.username!)
        }
//        cell.lastModifyMember.text = topic.last_modified
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let arr = topics {
            return arr.count
        }
        return 0
    }
}

extension HomeViewController: UITableViewDelegate {
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let topic = topics![indexPath.row] as! TopicModel
        let detail = TopicDetailViewController()
        detail.topicID = topic.topicID
        self.navigationController?.pushViewController(detail, animated: true)
    }
}