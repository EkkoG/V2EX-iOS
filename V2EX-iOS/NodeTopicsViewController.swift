//
//  NodeTopicsViewController.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/31.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit

class NodeTopicsViewController: BaseViewController {
    
    let kNodeTopicsCellIdentifier = "com.cielpy.v2ex.node.NodeTopics.cellIdentifier"
    
    var nodeModel: Node?
    
    lazy var topicListTableView: UITableView = {
        [unowned self] in
        let tableView = UITableView(frame: self.view.bounds, style: .Plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        
        return tableView
    }()
    
    var topics = [TopicModel]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = self.nodeModel?.title
        
        
        self.view.addSubview(self.topicListTableView)
        self.topicListTableView.registerClass(TopicTableViewCell.self, forCellReuseIdentifier: kNodeTopicsCellIdentifier)
        
        DataManager.getNodeTopics(self.nodeModel!.name!) { (dataResponse) -> Void in
            guard let data = dataResponse.data else {
                return
            }
            
            self.topics = data
            self.topicListTableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension NodeTopicsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let topic = self.topics[indexPath.row]
        let detail = TopicDetailViewController()
        detail.topicID = topic.topicID
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
}

extension NodeTopicsViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kNodeTopicsCellIdentifier, forIndexPath: indexPath) as! TopicTableViewCell
        let topic = topics[indexPath.row]
        cell.selectionStyle = .None
        cell.topic = topic
//        cell.lastModifyMember.text = topic.last_modified
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.topics.count > 0 {
            return self.topics.count
        }
        return 0
    }
}