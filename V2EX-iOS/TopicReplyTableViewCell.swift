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
            self.setupModel(model)
        }
    }
    
    func setupModel(model: TopicReplyModel) {
        
        self.createdTimeLabel.text = model.createdText
        
        if let thanks = model.thanks {
            self.thanksLabel.text = "\(thanks)"
        }
        
        self.contentLabel.htmlString = model.content_rendered
        self.refreshContentLabelHeight(self.contentLabel.data!.height)
        
        
        guard let member = model.member else {
            return
        }
        
        self.loadAvatarImage(member.avatar_normal!)
        
        
        self.memberButton.setTitle(member.username, forState: .Normal)
    }
    
    func loadAvatarImage(urlString: String) {
        let url = NSURL(string:urlString)!
        self.avatarImageView.kf_setImageWithURL(url, placeholderImage: nil, optionsInfo: [KingfisherOptionsInfoItem.Options(KingfisherOptions.None)]) { (image, error, cacheType, imageURL) -> () in
            if let image = image {
                Async.main(block: { () -> Void in
                    self.avatarImageView.image = image.imageByRoundCornerRadius(3)
                })
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //        self.setupModel(self.replyModel!)
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