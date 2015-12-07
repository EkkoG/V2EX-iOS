//
//  CLTopAlignLabel.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/4.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit

class CLTopAlignLabel: UILabel {
    override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = super.textRectForBounds(bounds, limitedToNumberOfLines: numberOfLines)
        rect.origin.y = bounds.origin.y
        return rect
    }
    
    override func drawTextInRect(rect: CGRect) {
        let r = textRectForBounds(rect, limitedToNumberOfLines: self.numberOfLines)
        super.drawTextInRect(r)
    }
}
