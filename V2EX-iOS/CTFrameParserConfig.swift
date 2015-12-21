//
//  CTFrameParserConfig.swift
//  CoreTextTest
//
//  Created by ciel on 15/12/14.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit

class CTFrameParserConfig: NSObject {
    var width: CGFloat = 200
    var fontSize: CGFloat = 15
    var lineSpace: CGFloat = 5
    var textColor: UIColor = UIColor.blackColor()

    init(width: CGFloat, fontSize: CGFloat, lineSpace: CGFloat, textColor: UIColor) {
        self.width = width
        self.fontSize = fontSize
        self.lineSpace = lineSpace
        self.textColor = textColor
    }
    
    class func defaultConfig(width: CGFloat) -> CTFrameParserConfig {
        let config = CTFrameParserConfig(width: width, fontSize: 15, lineSpace: 5, textColor: UIColor.blackColor())
        return config
    }
}
