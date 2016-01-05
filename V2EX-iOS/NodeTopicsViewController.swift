//
//  NodeTopicsViewController.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/31.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
let kNodeTopicsCellIdentifier = "com.cielpy.v2ex.node.NodeTopics.cellIdentifier"

class NodeTopicsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
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
        self.tabBarController?.tabBar.hidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = self.nodeModel?.title
        
        
        self.view.addSubview(self.topicListTableView)
        self.topicListTableView.registerClass(TopicTableViewCell.self, forCellReuseIdentifier: kNodeTopicsCellReuseIdentifier)
        
        DataManager.getNodeTopics(self.nodeModel!.name!) { (dataResponse) -> Void in
            guard let data = dataResponse.data else {
                return
            }
            
            self.topics = data
            self.topicListTableView.reloadData()
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kNodeTopicsCellReuseIdentifier, forIndexPath: indexPath) as! TopicTableViewCell
        let topic = topics[indexPath.row]
        cell.selectionStyle = .None
        cell.topic = topic
//        cell.lastModifyMember.text = topic.last_modified
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if topics.count > 0 {
            return topics.count
        }
        return 0
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 80
//    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let topic = self.topics[indexPath.row]
        let detail = TopicDetailViewController()
        detail.topicID = topic.topicID
        navigationController?.pushViewController(detail, animated: true)
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
