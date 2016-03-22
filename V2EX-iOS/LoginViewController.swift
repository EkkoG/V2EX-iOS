//
//  LoginViewController.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/26.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController,LoginViewProtocol {
    
    lazy var loginView: LoginView = {
        [unowned self] in
        let loginView = LoginView(frame: self.view.bounds)
        loginView.delegate = self
        
        return loginView
        }()
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "登录"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(memberSignInSuccessful(_:)), name: kMemberSignInSuccessfulNotification, object: nil)
        
        // Do any additional setup after loading the view.
        self.view.addSubview(self.loginView)
        self.showUserProfile()
    }
    
    func signInButtonClicked(username: String, password: String) {
        //        print(username + "  " + password)
        DataManager.signIn(username, password: password) { (dataResponse) -> Void in
            guard dataResponse.data! == true else {
                print("登录失败")
                return
            }
            
            self.loadMemberProfile(username)
        }
    }
    
    func loadMemberProfile(username: String) {
        DataManager.loadUserProfileInfo(username, completion: { (dataResponse) -> Void in
            guard let profile = dataResponse.data else {
                print("登录失败")
                return
            }
            
            self.loginView.clearMemberInput()
            V2EXShareDataManager.shareInstance.memberProfile = profile
            
            self.showUserProfile()
            NSUserDefaults.standardUserDefaults().setObject(username, forKey: kSigninedMemberNameKey)
        })
    }
    
    func memberSignInSuccessful(notification: NSNotification) {
        self.showUserProfile()
    }
    
    func showUserProfile() {
        guard let profile = V2EXShareDataManager.shareInstance.memberProfile else {
            return
        }
        
        let userProfile = UserProfileViewController()
        userProfile.username = profile.username
        self.addChildViewController(userProfile)
        self.view.addSubview(userProfile.view)
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
