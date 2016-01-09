//
//  ViewController.swift
//  V2EX-iOS
//
//  Created by ciel on 15/11/24.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import Kingfisher
import LCTabBarController


class ViewController: UIViewController, ZTViewControllerProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tuple = self.getClassesAndTitles()
        
        let vc = ZTViewController(mneuViewStyle: MenuViewStyleDefault)
        vc.delegate = self
        vc.loadVC(tuple.0, andTitle: tuple.1)
        
        let nav = BaseNavigationViewController(rootViewController: vc)
        vc.title = "V2EX"
        
        let item = UITabBarItem(title: "主页", image: UIImage(named: "tabbar_home"), selectedImage: UIImage(named: "tabbar_home_selected"))
        nav.tabBarItem = item
        
        
        let node = AllNodeViewController()
        let nav1 = BaseNavigationViewController(rootViewController: node)
        let item1 = UITabBarItem(title: "节点", image: UIImage(named: "tabbar_discover"), selectedImage: UIImage(named: "tabbar_discover_selected"))
        nav1.tabBarItem = item1
        
        
        let login = LoginViewController()
        let nav2 = BaseNavigationViewController(rootViewController: login)
        
        let item2 = UITabBarItem(title: "个人", image: UIImage(named: "tabbar_profile"), selectedImage: UIImage(named: "tabbar_profile_selected"))
        nav2.tabBarItem = item2
        
        let tab = LCTabBarController()
        tab.viewControllers = [nav, nav1, nav2]
        self.addChildViewController(tab)
        self.view.addSubview(tab.view)
    }
    
    func getClassesAndTitles() -> ([UIViewController.Type], [String]) {
        let className = HomeViewController.self
        var classes = [HomeViewController.Type]()
        var titles = [String]()
        for tab in HomeTabs.allValue {
            classes.append(className)
            titles.append(tab.title)
        }
        return (classes, titles)
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

