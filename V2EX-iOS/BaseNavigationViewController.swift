//
//  BaseNavigationViewController.swift
//  V2EX-iOS
//
//  Created by ciel on 15/11/25.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit

class BaseNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationBar.setBackgroundImage(UIImage(color: UIColor.whiteColor()), forBarMetrics: .Default)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        let item = UIBarButtonItem.appearance()
        var textAttrs = [String : AnyObject]()
        textAttrs[NSForegroundColorAttributeName] = UIColor.redColor()
        textAttrs[NSFontAttributeName] = UIFont.systemFontOfSize(15)
        item.setTitleTextAttributes(textAttrs, forState: .Normal)
        
        var disableAttrs = [String : AnyObject]()
        disableAttrs[NSForegroundColorAttributeName] = UIColor.redColor()
        disableAttrs[NSFontAttributeName] = UIFont.systemFontOfSize(15)
        item.setTitleTextAttributes(disableAttrs, forState: .Disabled)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
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
