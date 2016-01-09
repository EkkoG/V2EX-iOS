//
//  TopicReplyPhoto.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/31.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import NYTPhotoViewer

class TopicReplyPhoto: NSObject, NYTPhoto {
    var image: UIImage?
    var imageData: NSData?
    var placeholderImage: UIImage?
    let attributedCaptionTitle: NSAttributedString?
    let attributedCaptionSummary: NSAttributedString?
    let attributedCaptionCredit: NSAttributedString?
    
    init(imageData: NSData? = nil, image: UIImage? = nil, attributedCaptionTitle: NSAttributedString? = nil) {
        self.imageData = imageData
        self.image = image
        self.attributedCaptionTitle = attributedCaptionTitle
        self.attributedCaptionSummary = nil
        self.attributedCaptionCredit = nil
        super.init()
    }
    
    convenience init(attributedCaptionTitle: NSAttributedString) {
        self.init(imageData: nil, attributedCaptionTitle: attributedCaptionTitle)
    }
}
