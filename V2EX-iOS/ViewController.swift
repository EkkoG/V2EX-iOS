//
//  ViewController.swift
//  V2EX-iOS
//
//  Created by ciel on 15/11/24.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.greenColor()
        let cla = HomeViewController.self
        var classArr = [HomeViewController.Type]()
        let titles = HomeTabs
        for _ in titles {
            classArr.append(cla)
        }
        
        let vc = ZTViewController(mneuViewStyle: MenuViewStyleDefault)
        vc.loadVC(classArr, andTitle: titles)
        
        let nav = BaseNavigationViewController(rootViewController: vc)
        vc.title = "V2EX"
        self.addChildViewController(nav)
        self.view.addSubview(nav.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

