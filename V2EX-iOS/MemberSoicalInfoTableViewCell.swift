//
//  MemberSoicalInfoTableViewCell.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/26.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import Cartography

class MemberSoicalInfoTableViewCell: UITableViewCell {
    
    var iconImageView = UIImageView()
    var titleLabel = UILabel()
    
    var memberSocialInfoModel: MemberSocialInfo? {
        didSet {
            self.iconImageView.image = memberSocialInfoModel?.iconImage
            self.titleLabel.text = memberSocialInfoModel?.title
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(self.iconImageView)
        self.addSubview(self.titleLabel)
        self.UILayout()
    }
    
    func UILayout() {
        constrain(self.iconImageView, self.titleLabel) { v1, v2 in
            let height: CGFloat = 30
            v1.height == height
            v1.width == height
            
            v1.centerY == v1.superview!.centerY
            v1.left == v1.superview!.left + MARGIN_TO_BOUNDARY
            
            v2.centerY == v2.superview!.centerY
            v2.left == v1.right + SPACING_BEWTWEEN_COMPONENTS
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
