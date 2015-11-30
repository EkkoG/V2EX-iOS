//
//  TopicTableViewCell.swift
//  V2EX-iOS
//
//  Created by ciel on 15/11/29.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import Cartography
import Kingfisher

class TopicTableViewCell: UITableViewCell {
    
    var avatar = UIImageView()
    var title = UILabel()
    var node = UILabel()
    var lastModified = UILabel()
    var member = UILabel()
    var lastModifyMember = UILabel()
    var replies = UILabel()
    
    var topic: TopicModel? {
        didSet {
            let url = topic!.avatarURL()
            avatar.kf_setImageWithURL(NSURL(string:url)!)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(avatar)
        self.addSubview(title)
        self.addSubview(node)
        self.addSubview(lastModified)
        self.addSubview(member)
        self.addSubview(lastModifyMember)
        self.addSubview(replies)
        
//        title.backgroundColor = UIColor.grayColor()
//        avatar.backgroundColor = UIColor.redColor()
//        node.backgroundColor = UIColor.blueColor()
//        lastModified.backgroundColor = UIColor.greenColor()
//        member.backgroundColor = UIColor.purpleColor()
        UILayout()
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func UILayout() {
        let font = UIFont.systemFontOfSize(15)
        title.font = font
        let smallFont = UIFont.systemFontOfSize(13)
        node.font = smallFont
        lastModified.font = smallFont
        member.font = smallFont
        
        node.setContentHuggingPriority(750, forAxis: UILayoutConstraintAxis.Horizontal)
        member.setContentHuggingPriority(750, forAxis: UILayoutConstraintAxis.Horizontal)
        
        node.backgroundColor = UIColor.init(hexString: "#F5F5F5")
        
        title.numberOfLines = 0
        
        constrain(avatar) { view in
            let width: CGFloat = 60
            view.width == width
            view.height == width
            view.centerY == view.superview!.centerY
            view.left == view.superview!.left + SPACING_BEWTWEEN_COMPONENTS
        }
        
        constrain(title, avatar) { view1, view2 in
            view1.left == view2.right + SPACING_BEWTWEEN_COMPONENTS
            view1.top == view2.top
            view1.right == view1.superview!.right - MARGIN_TO_BOUNDARY
        }
        
        constrain(node, member, lastModified, lastModifyMember, avatar) {v1, v2, v3, v4, v5 in
            align(bottom: v5, v4, v3, v2, v1)
            
            v1.left == v5.right + SPACING_BEWTWEEN_COMPONENTS
            v2.left == v1.right + SPACING_BEWTWEEN_COMPONENTS
//            v3.left == v2.right + SPACING_BEWTWEEN_COMPONENTS
//            v4.left == v3.right + SPACING_BEWTWEEN_COMPONENTS
            v3.right == v3.superview!.right - MARGIN_TO_BOUNDARY
        }
        
        constrain(title, node) { v1, v2 in
            v1.bottom == v2.top
            v2.height >= 20 ~ 60
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
