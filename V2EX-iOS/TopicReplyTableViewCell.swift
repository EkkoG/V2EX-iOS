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
    
    lazy var contentLabel: CTLabel = {
        let ctLabel = CTLabel()
        ctLabel.backgroundColor = UIColor.whiteColor()
        return ctLabel
    }()
    
    var contentLabelHeight: CGFloat = 1
    
    let contentLabelHeightGroup = ConstraintGroup()
    
    var topicID: Int?
    
    var replyModel: TopicReplyModel? {
        willSet(replyModel){
            
            let url = NSURL(string:replyModel!.avatarURL())!
            self.avatarImageView.kf_setImageWithURL(url, placeholderImage: nil, optionsInfo: [KingfisherOptionsInfoItem.Options(KingfisherOptions.None)]) { (image, error, cacheType, imageURL) -> () in
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
            
            self.memberButton.setTitle(replyModel!.member?.username, forState: .Normal)
            
            self.createdTimeLabel.text = V2EXHelper.dateFormat(replyModel!.created!)
            if let thanks = replyModel!.thanks {
                self.thanksLabel.text = "\(thanks)"
            }
            
            let width = UIScreen.mainScreen().bounds.size.width - SPACING_BEWTWEEN_COMPONENTS - MARGIN_TO_BOUNDARY * 2 - 50
            let config = CTFrameParserConfig(width: width, fontSize: 15, lineSpace: 5, textColor: UIColor.blackColor())
            
            if !replyModel!.content_rendered!.hasPrefix("<p>") {
                replyModel?.content_rendered = "<p>\(replyModel!.content_rendered!)</p>"
            }
            
            let key = "indexpath\(self.indexPath!.section)+\(self.indexPath!.row)"
            
            var cellHeightCeche = V2EXShareDataManager.shareInstance.cellHeightCeche
            
            if let cache = cellHeightCeche[self.topicID!] {
                if let object = cache[key] {
                    self.contentLabel.data = object
                    self.refreshContentLabelHeight(object.height)
                }
                else {
                    let data = CTFrameParser.parseHTMLString(replyModel!.content_rendered!, config: config)
                    self.contentLabel.data = data
                    self.refreshContentLabelHeight(data.height)
//                    cache[key] = data
                    
                    var c = cache
                    c[key] = data
                    cellHeightCeche[self.topicID!] = c
                }
            }
            else {
                var cache = [String: CoreTextData]()
                let data = CTFrameParser.parseHTMLString(replyModel!.content_rendered!, config: config)
                self.contentLabel.data = data
                self.refreshContentLabelHeight(data.height)
                
                cache[key] = data
                cellHeightCeche[self.topicID!] = cache
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    deinit {
        self.contentLabel.removeObserver(self, forKeyPath: "textHeight")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentLabel.addObserver(self, forKeyPath: "textHeight", options: NSKeyValueObservingOptions.New, context: nil)
        
        self.UILayout()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let _ = change {
//            let obj = change[NSKeyValueChangeNewKey] as! CGFloat
//            print("indexpath \(self.indexPath!.row) + \(obj)")
            
            self.refreshContentLabelHeight(self.contentLabel.data!.height)
            NSNotificationCenter.defaultCenter().postNotificationName(TopicReplyCellContentHasNewHeightNotification, object: self.indexPath)
        }
    }
    
    func UILayout() {
        self.addSubview(self.avatarImageView)
        self.addSubview(self.memberButton)
        self.addSubview(self.createdTimeLabel)
        self.addSubview(self.thanksLabel)
        self.addSubview(self.contentLabel)
        
//        avatarImageView!.backgroundColor = UIColor.redColor()
//        self.memberButton.backgroundColor = UIColor.greenColor()
//        self.createdTimeLabel.backgroundColor = UIColor.grayColor()
//        self.thanksLabel.backgroundColor = UIColor.blueColor()
//        self.contentLabel.backgroundColor = UIColor.redColor()
        
//        memberButton.setContentHuggingPriority(750, forAxis: UILayoutConstraintAxis.Horizontal)
//        memberButton.setContentHuggingPriority(750, forAxis: UILayoutConstraintAxis.Vertical)
//        
//        createdTimeLabel.setContentHuggingPriority(750, forAxis: UILayoutConstraintAxis.Horizontal)
//        thanksLabel.setContentHuggingPriority(750, forAxis: UILayoutConstraintAxis.Horizontal)
        
        constrain(self.avatarImageView) { v in
            let width: CGFloat = 50
            v.width == width
            v.height == width
            v.top == v.superview!.top + MARGIN_TO_BOUNDARY
            v.left == v.superview!.left + MARGIN_TO_BOUNDARY
        }
        
        constrain(self.memberButton, self.createdTimeLabel, self.thanksLabel, self.avatarImageView) { v1, v2, v3, v4 in
            align(top: v1, v2, v3, v4)
            
            v1.left == v4.right + SPACING_BEWTWEEN_COMPONENTS
            v2.left == v1.right + SPACING_BEWTWEEN_COMPONENTS
            
            v3.right == v3.superview!.right - MARGIN_TO_BOUNDARY
            
            v1.height == 18
            v2.height == v1.height
        }
        
        constrain(self.contentLabel, self.memberButton) { v1, v2 in
            align(left: v1, v2)
            v1.top == v2.bottom + SPACING_BEWTWEEN_COMPONENTS
            v1.right == v1.superview!.right - MARGIN_TO_BOUNDARY
//            v1.bottom == v1.superview!.bottom - MARGIN_TO_BOUNDARY
        }
        
        self.refreshContentLabelHeight(15)
    }
    
    func refreshContentLabelHeight(height: CGFloat) {
        constrain(self.contentLabel, replace: self.contentLabelHeightGroup) { v1 in
            v1.height == height
        }
        
        self.contentLabel.setNeedsDisplay()
        self.sizeToFit()
    }
    override func sizeThatFits(size: CGSize) -> CGSize {
        var totalHeight: CGFloat = 0
        totalHeight += MARGIN_TO_BOUNDARY
        totalHeight += 18
        totalHeight += SPACING_BEWTWEEN_COMPONENTS
        if let data = self.contentLabel.data {
            totalHeight += data.height
        }
        else {
            totalHeight += 15
        }
        totalHeight += MARGIN_TO_BOUNDARY
        
        let minHeight = 50 + MARGIN_TO_BOUNDARY * 2
        if totalHeight < minHeight {
            totalHeight = minHeight
        }
        
        return CGSizeMake(size.width, totalHeight)
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}