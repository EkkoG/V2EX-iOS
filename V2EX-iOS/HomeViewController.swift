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
        topicsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(topicsTableView)
        constrain(topicsTableView) { (view) -> () in
            view.edges == inset(view.superview!.edges, 0)
        }
        
        print(type.title)
        
        DataManager.loadTabsDataWithTabsPath(HomeTabs.latest.path) { (data, error) -> Void in
            if let data = data {
                if let dataFromeString = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    var error: NSError?
                    let json = JSON(data: dataFromeString, options: NSJSONReadingOptions.AllowFragments, error: &error)
                    print(json[0])
                    let arr = json.arrayObject
                    self.topics = arr
                    self.topicsTableView.reloadData()
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let dic = topics![indexPath.row] as! NSDictionary
        cell.textLabel?.text = dic["title"] as? String
        cell.textLabel?.font = UIFont.systemFontOfSize(15)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let arr = topics {
            return arr.count
        }
        return 0
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
