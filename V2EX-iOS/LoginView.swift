//
//  LoginView.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/26.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import Cartography
protocol LoginViewProtocol {
    func signInButtonClicked(username: String, password: String)
}

class LoginView: UIView {
    
    var usernameTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "用户名"
        
        return textField
    }()
    
    var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "密码"
        return textField
    }()
    
    var signInButton: UIButton = {
        let btn = UIButton(type: .Custom)
        return btn
    }()
    
    var delegate: LoginViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.usernameTextField)
        
        self.addSubview(self.passwordTextField)
        
        self.addSubview(self.signInButton)
        self.signInButton.backgroundColor = kListViewHeaderViewBackroundColor
        self.signInButton.setTitle("登录", forState: .Normal)
        self.signInButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        self.signInButton.addBlockForControlEvents(.TouchUpInside) { (sender) -> Void in
            guard let delegate = self.delegate else {
                return
            }
            
            guard let username = self.usernameTextField.text else {
                print("请输入用户名")
                return
            }
            
            guard username.length > 0 else {
                print("请输入用户名")
                return
            }
            
            guard let password = self.passwordTextField.text else {
                print("请输入密码")
                return
            }
            
            guard password.length > 0 else {
                print("请输入密码")
                return
            }
            self.usernameTextField.resignFirstResponder()
            self.passwordTextField.resignFirstResponder()
            
            delegate.signInButtonClicked(username, password: password)
        }
            
        self.UILayout()
    }
    
    func UILayout() {
        constrain(self.usernameTextField, self.passwordTextField, self.signInButton) { v1, v2, v3 in
            let width: CGFloat = 100
            let height: CGFloat = 35
            
            v1.centerX == v1.superview!.centerX
            v1.width == width
            v1.height == height
            v1.top == v1.superview!.top + 20
            
            v2.width == v1.width
            v2.height == v1.height
            v2.centerX == v1.centerX
            v2.top == v1.bottom + SPACING_BEWTWEEN_COMPONENTS
            
            v3.width == v1.width
            v3.height == v1.height
            v3.centerX == v1.centerX
            v3.top == v2.bottom + SPACING_BEWTWEEN_COMPONENTS
        }
        
    }
    
    func clearMemberInput() {
        self.usernameTextField.text = nil
        self.passwordTextField.text = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
