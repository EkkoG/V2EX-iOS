//
//  ViewController.swift
//  V2EX-iOS
//
//  Created by ciel on 15/11/24.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import Kingfisher


class ViewController: UIViewController, ZTViewControllerProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let cla = HomeViewController.self
        var classArr = [HomeViewController.Type]()
        var titles = [String]()
        for tab in HomeTabs.allValue {
            classArr.append(cla)
            titles.append(tab.title)
        }
        
        let vc = ZTViewController(mneuViewStyle: MenuViewStyleDefault)
        vc.delegate = self
        vc.loadVC(classArr, andTitle: titles)
        
        let nav = BaseNavigationViewController(rootViewController: vc)
        vc.title = "V2EX"
        
        var profile: UIViewController?
        if let username = NSUserDefaults.standardUserDefaults().objectForKey(signinedMemberNameKey) {
            let userProfile = UserProfileViewController()
            userProfile.username = username as? String
            profile = userProfile
        }
        else {
            let login = LoginViewController()
            profile = login
        }
        
        let nav1 = BaseNavigationViewController(rootViewController: profile!)
        nav1.title = "Profile"
        
        let tab = UITabBarController()
        tab.setViewControllers([nav, nav1], animated: true)
        self.addChildViewController(tab)
        self.view.addSubview(tab.view)
    }
    
    func viewControllerCreated(viewController: UIViewController!, index: Int) {
        let home = viewController as! HomeViewController
        home.type = HomeTabs.allValue[index]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

