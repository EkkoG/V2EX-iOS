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

class HomeViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    var type: HomeTabs!
    var topicsTableView: UITableView!
    var topics: NSArray?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        topicsTableView = UITableView(frame: self.view.bounds, style: .Plain)
        topicsTableView.dataSource = self
        topicsTableView.delegate = self
        topicsTableView.estimatedRowHeight = 60
        topicsTableView.rowHeight = UITableViewAutomaticDimension
        topicsTableView.registerClass(TopicTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(topicsTableView)
        constrain(topicsTableView) { (view) -> () in
            view.edges == inset(view.superview!.edges, 0, 0, 0, 0)
        }
        
        print(type.title)
//        print(V2EXHelper.dateFormat(1448793443))
        
        DataManager.loadTabsTopicsDataWithTabsPath(type.path) { (response) -> Void in
            self.topics = response.data
            self.topicsTableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TopicTableViewCell
        let topic = topics![indexPath.row] as! TopicModel
        cell.selectionStyle = .None
        cell.topic = topic
//        cell.lastModifyMember.text = topic.last_modified
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let arr = topics {
            return arr.count
        }
        return 0
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 80
//    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let topic = topics![indexPath.row] as! TopicModel
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
