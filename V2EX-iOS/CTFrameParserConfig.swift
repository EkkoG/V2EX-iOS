//
//  CTFrameParserConfig.swift
//  CoreTextTest
//
//  Created by ciel on 15/12/14.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit

class CTFrameParserConfig: NSObject {
    var width: CGFloat? = 200
    var fontSize: CGFloat = 15
    var lineSpace: CGFloat = 5
    var textColor: UIColor = UIColor.blackColor()

    init(fontSize: CGFloat = 15, lineSpace: CGFloat = 5, textColor: UIColor = UIColor.blackColor()) {
        self.fontSize = fontSize
        self.lineSpace = lineSpace
        self.textColor = textColor
    }
}
