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
    
    lazy var topicsTableView: UITableView = {
        [unowned self] in
        let topicsTableView = UITableView(frame: self.view.bounds, style: .Plain)
        topicsTableView.dataSource = self
        topicsTableView.delegate = self
        topicsTableView.estimatedRowHeight = 60
        topicsTableView.rowHeight = UITableViewAutomaticDimension
        return topicsTableView
    }()
    
    var topics = [TopicModel]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(self.type.title)
        
        self.setupTableView()
        
        self.loadData()
    }
    
    func setupTableView() {
        self.topicsTableView.registerClass(TopicTableViewCell.self, forCellReuseIdentifier: kHomeTopicsCellIdentifier)
        self.view.addSubview(self.topicsTableView)
        constrain(self.topicsTableView) { v1 in
            v1.edges == inset(v1.superview!.edges, 0, 0, 0, 0)
        }
        
        self.topicsTableView.addPullToRefresh(PullToRefresh()) { () -> () in
            self.loadData()
        }
    }
    
    func loadData() {
        DataManager.loadTabsTopicsDataWithTabsPath(self.type.path) { (response) -> Void in
            guard let data = response.data else {
                return
            }
            self.topics = data
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
}

extension HomeViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kHomeTopicsCellIdentifier, forIndexPath: indexPath) as! TopicTableViewCell
        let topic = self.topics[indexPath.row]
        cell.selectionStyle = .None
        cell.topic = topic
        cell.tapSendButton = { _ in
            self.gotoNodeTopics(topic.node!)
        }
        
        cell.tapAvatar = { _ in
            self.gotoMemberProfile(topic.member!.username!)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.topics.count
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let topic = self.topics[indexPath.row]
        let detail = TopicDetailViewController()
        detail.topicID = topic.topicID
        self.navigationController!.pushViewController(detail, animated: true)
    }
}