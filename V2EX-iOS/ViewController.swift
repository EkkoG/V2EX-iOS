//
//  ViewController.swift
//  V2EX-iOS
//
//  Created by ciel on 15/11/24.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit


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
        self.addChildViewController(nav)
        self.view.addSubview(nav.view)
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

