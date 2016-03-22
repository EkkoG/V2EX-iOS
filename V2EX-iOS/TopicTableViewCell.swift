//
//  TopicTableViewCell.swift
//  V2EX-iOS
//
//  Created by ciel on 15/11/29.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import Cartography
import Kingfisher
import Async

class TopicTableViewCell: UITableViewCell {
    
    let smallFont:CGFloat = 13
    var avatarWidth:CGFloat = 60
    
    lazy var avatar: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var title: CLTopAlignLabel = {
        let title = CLTopAlignLabel()
        
        title.numberOfLines = 0
        let font = UIFont.systemFontOfSize(15)
        title.font = font
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    lazy var node: UIButton = {
        let node = UIButton(type: UIButtonType.Custom)
        
        node.backgroundColor = kListViewHeaderViewBackroundColor
        node.layer.cornerRadius = 3
        node.layer.masksToBounds = true
        
        node.titleLabel?.font = UIFont.systemFontOfSize(self.smallFont)
        node.setTitleColor(UIColor.blackColor(), forState: .Normal)
        node.translatesAutoresizingMaskIntoConstraints = false
        return node
    }()
    lazy var lastModified: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFontOfSize(self.smallFont)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var member: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(self.smallFont)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var lastModifyMember: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
   lazy var replies: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var avatarHidden : Bool? {
        didSet {
            if avatarHidden == true {
                self.avatar.removeFromSuperview()
                self.avatarWidth = 0
                self.needsUpdateConstraints()
            }
        }
    }
    
    var topic: TopicModel? {
        willSet(topic){
            let url = NSURL(string:topic!.avatarURL())!
            if let _ = self.avatar.superview {
                self.avatar.kf_setImageWithURL(url, placeholderImage: nil, optionsInfo: [KingfisherOptionsInfoItem.Options(KingfisherOptions.None)]) { (image, error, cacheType, imageURL) -> () in
                    if let image = image {
                        Async.main(block: { () -> Void in
                            self.avatar.image = image.imageByRoundCornerRadius(3)
                        })
                    }
                }
            }
            
            self.title.text = topic!.title
            self.node.setTitle(topic?.node?.title, forState: .Normal)
            self.member.text = topic!.member?.username
            self.lastModified.text = topic!.lastModifiedText()
            setNeedsUpdateConstraints()
        }
    }
    var tapSendButton: () -> Void = { _ in }
    var tapAvatar: () -> Void = { _ in }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.avatar)
        self.contentView.addSubview(self.title)
        self.contentView.addSubview(self.node)
        self.contentView.addSubview(self.lastModified)
        self.contentView.addSubview(self.member)
        self.contentView.addSubview(self.lastModifyMember)
        self.contentView.addSubview(self.replies)
        
        self.node.addTarget(self, action: #selector(TopicTableViewCell.gotoNodeTopics(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAvatarImageView(_:)))
        self.avatar.addGestureRecognizer(tap)
        self.avatar.userInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func UILayout() {
        
        if let _ = self.avatar.superview {
            constrain(self.avatar) { view in
                view.width == self.avatarWidth
                view.height == self.avatarWidth
                view.top == view.superview!.top + MARGIN_TO_BOUNDARY
                view.left == view.superview!.left + MARGIN_TO_BOUNDARY
            }
        }
        
        constrain(self.title) { view1 in
            view1.left == view1.superview!.left + MARGIN_TO_BOUNDARY + self.avatarWidth + SPACING_BEWTWEEN_COMPONENTS
            view1.top == view1.superview!.top + MARGIN_TO_BOUNDARY
            view1.right == view1.superview!.right - MARGIN_TO_BOUNDARY
            /*
            For node label to align to avatar's bottom
            node's height is 16
            the hard code minHeight is avatar's height - node's label's height
            */
            let minHeight:CGFloat = self.avatarWidth - 16
            view1.height >= minHeight ~ 1000
        }
        
        constrain(self.node, self.member, self.lastModified, self.lastModifyMember, title) {v1, v2, v3, v4, v5 in
            v1.height == 16
            v1.left == v5.left
            v2.left == v1.right + SPACING_BEWTWEEN_COMPONENTS
            v3.right == v3.superview!.right - MARGIN_TO_BOUNDARY
            
            v5.bottom == v1.top
            
            v1.bottom == v1.superview!.bottom - MARGIN_TO_BOUNDARY
            align(bottom: v1, v2, v3, v4)
        }
    }
    
    override func updateConstraints() {
        UILayout()
        super.updateConstraints()
    }
    
    func gotoNodeTopics(sender: UIButton) {
        self.tapSendButton()
    }
    
    func tapAvatarImageView(gesture: UIGestureRecognizer) {
        self.tapAvatar()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
