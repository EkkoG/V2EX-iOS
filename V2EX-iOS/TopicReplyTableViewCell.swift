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

public let kTopicDetailCellHasNewHeightNotification = "com.cielpy.v2ex.TopicDetailCellHasNewHeight"

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
    
    var tapAvatar: () -> Void = { _ in }
    
    var topicID: Int?
    
    var replyModel: TopicReplyModel? {
        willSet(newValue){
            
            guard let model = newValue else {
                return
            }
            
            self.createdTimeLabel.text = model.createdText
            
            if let thanks = model.thanks {
                self.thanksLabel.text = "\(thanks)"
            }
            
            let width = UIScreen.mainScreen().bounds.size.width - SPACING_BEWTWEEN_COMPONENTS - MARGIN_TO_BOUNDARY * 2 - 50
            let config = CTFrameParserConfig(width: width, fontSize: 15, lineSpace: 5, textColor: UIColor.blackColor())
            
            let key = "indexpath\(self.indexPath!.section)+\(self.indexPath!.row)"
            
            var cache = V2EXShareDataManager.shareInstance.getCacheByKey(self.topicID!)
            
            if let object = cache[key] {
                self.contentLabel.data = object
                self.refreshContentLabelHeight(object.height)
            }
            else {
                let data = CTFrameParser.parseHTMLString(model.content_rendered!, config: config)
                self.contentLabel.data = data
                self.refreshContentLabelHeight(data.height)
                cache[key] = data
                
                V2EXShareDataManager.shareInstance.updateObjectByKey(self.topicID!, object: cache)
            }
            
            guard let member = model.member else {
                return
            }
            
            let url = NSURL(string:member.avatar_normal!)!
            self.avatarImageView.kf_setImageWithURL(url, placeholderImage: nil, optionsInfo: [KingfisherOptionsInfoItem.Options(KingfisherOptions.None)]) { (image, error, cacheType, imageURL) -> () in
                if let image = image {
                    Async.main(block: { () -> Void in
                        self.avatarImageView.image = image.imageByRoundCornerRadius(3)
                    })
                }
            }
            
            self.memberButton.setTitle(member.username, forState: .Normal)
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
        
        let tap = UITapGestureRecognizer(target: self, action: "tapAvatarImageView:")
        self.avatarImageView.addGestureRecognizer(tap)
        self.avatarImageView.userInteractionEnabled = true
        
        self.UILayout()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let _ = change {
//            let obj = change[NSKeyValueChangeNewKey] as! CGFloat
//            print("indexpath \(self.indexPath!.row) + \(obj)")
            
            self.refreshContentLabelHeight(self.contentLabel.data!.height)
            NSNotificationCenter.defaultCenter().postNotificationName(kTopicDetailCellHasNewHeightNotification, object: self.indexPath)
        }
    }
    
    func UILayout() {
        self.contentView.addSubview(self.avatarImageView)
        self.contentView.addSubview(self.memberButton)
        self.contentView.addSubview(self.createdTimeLabel)
        self.contentView.addSubview(self.thanksLabel)
        self.contentView.addSubview(self.contentLabel)
        
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
    
    func tapAvatarImageView(gesture: UIGestureRecognizer) {
        self.tapAvatar()
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}