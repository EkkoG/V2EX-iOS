//
//  UserProfileViewController.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/25.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import EZSwiftExtensions

let ProfileInfoCellIdentifier = "com.cielpy.profileinfocellidentifier"

class UserProfileViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    lazy var profileTableView: UITableView = {
        [unowned self] in
        let tableView = UITableView(frame: self.view.bounds, style: .Plain)
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()
    
    var memberProfile: MemberProfileModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Profile"
        self.view.addSubview(self.profileTableView)
        
        self.profileTableView.registerClass(MemberSoicalInfoTableViewCell.self, forCellReuseIdentifier: ProfileInfoCellIdentifier)
        
        let headerView = MemberProfileView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 70))
        headerView.addBorderBottom(size: 1, color: UIColor.init(hexString: "#e2e2e2"))
        
        DataManager.loadUserProfileInfo("cielpy") { (dataResponse) -> Void in
            if let model = dataResponse.data {
                headerView.memberProfileModel = model
                
                self.memberProfile = model
                
                self.profileTableView.tableHeaderView = headerView
                self.profileTableView.reloadSection(1, withRowAnimation: .None)
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ProfileInfoCellIdentifier, forIndexPath: indexPath) as! MemberSoicalInfoTableViewCell
        let info = self.memberProfile!.memberSoicalInfo[indexPath.row]
        cell.memberSocialInfoModel = info
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            guard let model = self.memberProfile else {
                return 0
            }
            return model.memberSoicalInfo.count
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 44
        }
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.redColor()
        
        return view
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
