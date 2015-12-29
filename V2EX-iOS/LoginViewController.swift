//
//  LoginViewController.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/26.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,LoginViewProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let loginView = LoginView(frame: self.view.bounds)
        loginView.delegate = self
        self.view.addSubview(loginView)
    }
    
    func signInButtonClicked(username: String, password: String) {
        print(username + "  " + password)
        DataManager.signIn(username, password: password) { (dataResponse) -> Void in
            guard dataResponse.data! == true else {
                print("登录失败")
                return
            }
            
            DataManager.loadUserProfileInfo(username, completion: { (dataResponse) -> Void in
                guard let profile = dataResponse.data else {
                    print("登录失败")
                    return
                }
                
                V2EXShareDataManager.shareInstance.memberProfile = profile
                
                NSUserDefaults.standardUserDefaults().setObject(username, forKey: signinedMemberNameKey)
                
                let userProfile = UserProfileViewController()
                userProfile.username = username
                self.addChildViewController(userProfile)
                self.view.addSubview(userProfile.view)
            })
        }
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
