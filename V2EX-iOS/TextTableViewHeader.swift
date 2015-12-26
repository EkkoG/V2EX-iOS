//
//  TextTableViewHeader.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/26.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import Cartography

class TextTableViewHeader: UIView {
    var textLabel = UILabel()
    
    var text: String? {
        didSet {
            self.textLabel.text = text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(textLabel)
        
        constrain(self.textLabel) { v1 in
            v1.left == v1.superview!.left + MARGIN_TO_BOUNDARY
            v1.centerY == v1.superview!.centerY
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
