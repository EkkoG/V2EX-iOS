//
//  MemberProfileView.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/25.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import Cartography
import Kingfisher

class MemberProfileView: UIView {
    var avatarImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    var memberNameLabel = UILabel()
    var memberCreateLabel = UILabel()
    
    var memberProfileModel: MemberProfileModel? {
        didSet {
            self.avatarImageView.kf_setImageWithURL(NSURL(string: memberProfileModel!.avatar_large!)!, placeholderImage: UIImage(named: "ic_launcher144"))
            self.memberNameLabel.text = memberProfileModel?.username
            self.memberCreateLabel.text = memberProfileModel?.createDateString
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.avatarImageView)
        self.addSubview(self.memberNameLabel)
        self.addSubview(self.memberCreateLabel)
//        self.avatarImageView.backgroundColor = UIColor.redColor()
        self.UILayout()
//        self.backgroundColor = UIColor.greenColor()
    }
    
    func UILayout() {
        constrain(self.avatarImageView, self.memberNameLabel, self.memberCreateLabel) { v1, v2 ,v3 in
            v1.top == v1.superview!.top + MARGIN_TO_BOUNDARY
            v1.left == v1.superview!.left + MARGIN_TO_BOUNDARY
            let height: CGFloat = 60
            v1.height == height
            v1.width == height
            
            v2.top == v1.top
            v2.left == v1.right + SPACING_BEWTWEEN_COMPONENTS
            
            v3.bottom == v1.bottom
            v3.left == v2.left
        }
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
