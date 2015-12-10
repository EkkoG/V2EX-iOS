//
//  TopicReplyTableViewCell.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/3.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import Cartography
import Kingfisher
import Async

public let TopicReplyCellContentHasNewHeightNotification = "com.cielpy.v2ex.topicreplycontenthasnewheight"
public let TopicContentNewHeightIndexPathKey = "com.cielpy.v2ex.topiccontentnewheight"
public let TopicContentNewHeightHeightKey = "com.cielpy.v2ex.topiccontentnewheightheight"

class TopicReplyTableViewCell: UITableViewCell {
    var indexPath: NSIndexPath?
    var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    var memberButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFontOfSize(15)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        return button
    }()
    
    var createdTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(15)
        return label
    }()
    lazy var thanksLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(15)
        return label
    }()
    
    var contentLabelHeight: CGFloat = 1
    
    let contentLabelHeightGroup = ConstraintGroup()
    
    var replyModel: TopicReplyModel? {
        willSet(replyModel){
            
            let url = NSURL(string:replyModel!.avatarURL())!
            avatarImageView.kf_setImageWithURL(url, placeholderImage: nil, optionsInfo: [KingfisherOptionsInfoItem.Options(KingfisherOptions.None)]) { (image, error, cacheType, imageURL) -> () in
//                if let image = image {
//                    Async.main(block: { () -> Void in
//                        UIGraphicsBeginImageContextWithOptions(self.avatarImageView.bounds.size, false, 1.0)
//                        UIBezierPath.init(roundedRect: self.avatarImageView.bounds, cornerRadius: 3.0).addClip()
//                        image.drawInRect(self.avatarImageView.bounds)
//                        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
//                        self.avatarImageView.image = finalImage
//                        UIGraphicsEndImageContext()
//                    })
//                }
            }
            
            memberButton.setTitle(replyModel!.member?.username, forState: .Normal)
            createdTimeLabel.text = V2EXHelper.dateFormat(replyModel!.created!)
            if let thanks = replyModel!.thanks {
                thanksLabel.text = "\(thanks)"
            }
            
            var dic = [String: AnyObject]()
            dic[NSDocumentTypeDocumentAttribute] = NSHTMLTextDocumentType
            dic[NSCharacterEncodingDocumentAttribute] = "\(NSUTF8StringEncoding)"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        UILayout()
    }
    
    func UILayout() {
//        addSubview(avatarImageView)
//        addSubview(memberButton)
//        addSubview(createdTimeLabel)
//        addSubview(thanksLabel)
//
////        avatarImageView!.backgroundColor = UIColor.redColor()
//        memberButton.backgroundColor = UIColor.greenColor()
//        createdTimeLabel.backgroundColor = UIColor.grayColor()
//        thanksLabel.backgroundColor = UIColor.blueColor()
//
//        memberButton.setContentHuggingPriority(750, forAxis: UILayoutConstraintAxis.Horizontal)
//        memberButton.setContentHuggingPriority(750, forAxis: UILayoutConstraintAxis.Vertical)
//        
//        createdTimeLabel.setContentHuggingPriority(750, forAxis: UILayoutConstraintAxis.Horizontal)
//        thanksLabel.setContentHuggingPriority(750, forAxis: UILayoutConstraintAxis.Horizontal)
//        
//        constrain(avatarImageView) { v in
//            let width: CGFloat = 50
//            v.width == width
//            v.height == width
//            v.top == v.superview!.top + MARGIN_TO_BOUNDARY
//            v.left == v.superview!.left + MARGIN_TO_BOUNDARY
//        }
//        
//        
//        constrain(memberButton, createdTimeLabel, thanksLabel, avatarImageView) { v1, v2, v3, v4 in
//            align(top: v1, v2, v3, v4)
//            
//            v1.left == v4.right + SPACING_BEWTWEEN_COMPONENTS
//            v2.left == v1.right + SPACING_BEWTWEEN_COMPONENTS
//            
//            v3.right == v3.superview!.right - MARGIN_TO_BOUNDARY
//            
////            v1.height == 18
////            v2.height == v1.height
//        }
        
//        Async.main { () -> Void in
//            constrain(self.contentLabel ) { v1 in
//    //            align(left: v1, v2)
//    //            v1.height == self.contentLabelHeight
//                v1.left == v1.superview!.left + MARGIN_TO_BOUNDARY + 50 + SPACING_BEWTWEEN_COMPONENTS
//                v1.top == v1.superview!.top + SPACING_BEWTWEEN_COMPONENTS
//                v1.right == v1.superview!.right - MARGIN_TO_BOUNDARY
//    //            v1.bottom == v1.superview!.bottom - MARGIN_TO_BOUNDARY
//            }
//            
//            constrain(self.contentLabel, replace: self.contentLabelHeightGroup) {v1 in
//                v1.height == 10
//            }
//                
//        }
        
    }
    
    
//    override func sizeThatFits(size: CGSize) -> CGSize {
//        var totalHeight: CGFloat = 0
//        totalHeight += MARGIN_TO_BOUNDARY
//        totalHeight += 18
//        totalHeight += SPACING_BEWTWEEN_COMPONENTS
//        totalHeight += contentLabelHeight
//        totalHeight += MARGIN_TO_BOUNDARY
//        
//        return CGSizeMake(size.width, totalHeight)
//    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
