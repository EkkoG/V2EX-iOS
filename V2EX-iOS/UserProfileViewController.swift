//
//  UserProfileViewController.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/25.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import EZSwiftExtensions
import SafariServices


class UserProfileViewController: BaseViewController {
    
    let kMemberProfileSocialCellIdentifier = "com.cielpy.v2ex.MemberProfile.social.cellIdentifier"
    let kMemberProfileLatestTopicsCellIdentifier = "com.cielpy.v2ex.MemberProfile.latestTopics.cellIdentifier"
    
    var username: String? {
        didSet {
            self.loadData(username!)
        }
    }
    
    lazy var profileTableView: UITableView = {
        [unowned self] in
        let tableView = UITableView(frame: self.view.bounds, style: .Plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        
        return tableView
    }()
    
    lazy var headerView: MemberProfileView = {
        [unowned self] in
        
        let headerView = MemberProfileView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 70))
        headerView.addBorderBottom(size: 1, color: kSeparateLineColor)
        
        return headerView
    }()
    
    var memberProfile: MemberProfileModel?
    
    var memberLatestTopics = [TopicModel]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupTitleAndTabbar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        self.loadData(self.username!)
        
//        self.profileTableView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleHeight]

        // Do any additional setup after loading the view.
        
    }
    
    func setupViews() {
        self.view.addSubview(self.profileTableView)
        
        self.profileTableView.registerClass(MemberSoicalInfoTableViewCell.self, forCellReuseIdentifier: kMemberProfileSocialCellIdentifier)
        self.profileTableView.registerClass(TopicTableViewCell.self, forCellReuseIdentifier: kMemberProfileLatestTopicsCellIdentifier)
        
        //hard code
        self.view.height = self.view.height - 110
        
    }
    
    func setupTitleAndTabbar() {
        func hideTabbar() {
            self.title = self.username
            self.tabBarController?.tabBar.hidden = true
        }
        
        //check if member signin
        if V2EXShareDataManager.shareInstance.signInStatus().status == true {
            //check if is the signin member
            if V2EXShareDataManager.shareInstance.signInStatus().memberName == self.username {
                self.parentViewController!.title = "个人"
                let signOutItem = UIBarButtonItem(title: "退出", style: UIBarButtonItemStyle.Plain, target: self, action: "signOut")
                self.parentViewController!.navigationItem.leftBarButtonItem = signOutItem
                self.tabBarController?.tabBar.hidden = false
            }
            else {
                hideTabbar()
            }
        }
        else { //member not signin,only a case,show member's profile
            hideTabbar()
        }
    }
    
    func loadData(username: String) {
        DataManager.loadUserProfileInfo(username) { (dataResponse) -> Void in
            guard let model = dataResponse.data else {
                return
            }
            
            self.headerView.memberProfileModel = model
            
            self.memberProfile = model
            
            self.profileTableView.tableHeaderView = self.headerView
            self.profileTableView.reloadData()
        }
        
        DataManager.loadMemberLatestTopics(username) { (dataResponse) -> Void in
            guard let list = dataResponse.data else {
                return
            }
            
            self.memberLatestTopics = list
            self.profileTableView.reloadSection(1, withRowAnimation: .None)
        }
        
    }
    
    func signOut() {
        V2EXShareDataManager.shareInstance.memberProfile = nil
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = storage.cookies {
            for cookie in cookies {
                storage.deleteCookie(cookie)
            }
        }
        self.parentViewController!.title = "登录"
        self.parentViewController!.navigationItem.leftBarButtonItem = nil
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kSigninedMemberNameKey)
        self.removeFromParentViewController()
        self.view.removeFromSuperview()
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

extension UserProfileViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(kMemberProfileSocialCellIdentifier, forIndexPath: indexPath) as! MemberSoicalInfoTableViewCell
            cell.selectionStyle = .None
            let info = self.memberProfile!.memberSoicalInfo[indexPath.row]
            cell.memberSocialInfoModel = info
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(kMemberProfileLatestTopicsCellIdentifier, forIndexPath: indexPath) as! TopicTableViewCell
            cell.selectionStyle = .None
            cell.avatarHidden = true
            cell.topic = self.memberLatestTopics[indexPath.row]
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            guard let model = self.memberProfile else {
                return 0
            }
            return model.memberSoicalInfo.count
        }
        if section == 1 {
            guard self.memberLatestTopics.count != 0 else {
                return 0
            }
            return self.memberLatestTopics.count
        }
        return 0
    }
    
}

extension UserProfileViewController: UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 25
        }
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = TextTableViewHeader(frame: CGRectZero)
        view.backgroundColor = kListViewHeaderViewBackroundColor
        view.text = "最近主题"
        return view
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0{
            let info = self.memberProfile?.memberSoicalInfo[indexPath.row]
            
            let sf = SFSafariViewController(URL: NSURL(string: info!.URL!)!)
//            self.navigationController!.pushViewController(sf, animated: true)
            self.presentVC(sf)
        }
        
        if indexPath.section == 1 {
            let topic = self.memberLatestTopics[indexPath.row]
            let detail = TopicDetailViewController()
            detail.topicID = topic.topicID
            navigationController?.pushViewController(detail, animated: true)
        }
    }
    
}