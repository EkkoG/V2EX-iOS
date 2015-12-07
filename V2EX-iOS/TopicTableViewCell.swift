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
    let avatarWidth:CGFloat = 60
    
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
    lazy var node: UILabel = {
        let node = UILabel()
        
        node.backgroundColor = UIColor.init(hexString: "#F5F5F5")
        node.layer.cornerRadius = 3
        node.layer.masksToBounds = true
        
        node.font = UIFont.systemFontOfSize(self.smallFont)
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
    
    var topic: TopicModel? {
        willSet(topic){
            let url = NSURL(string:topic!.avatarURL())!
            avatar.kf_setImageWithURL(url, placeholderImage: nil, optionsInfo: [KingfisherOptionsInfoItem.Options(KingfisherOptions.None)]) { (image, error, cacheType, imageURL) -> () in
                if let image = image {
                    Async.main(block: { () -> Void in
                        UIGraphicsBeginImageContextWithOptions(self.avatar.bounds.size, false, 1.0)
                        UIBezierPath.init(roundedRect: self.avatar.bounds, cornerRadius: 3.0).addClip()
                        image.drawInRect(self.avatar.bounds)
                        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
                        self.avatar.image = finalImage
                        UIGraphicsEndImageContext()
                    })
                }
            }
            
            self.title.text = topic!.title
            self.node.text = topic!.node?.title
            self.member.text = topic!.member?.username
            self.lastModified.text = topic!.lastModifiedText()
            setNeedsUpdateConstraints()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(avatar)
        contentView.addSubview(title)
        contentView.addSubview(node)
        contentView.addSubview(lastModified)
        contentView.addSubview(member)
        contentView.addSubview(lastModifyMember)
        contentView.addSubview(replies)
        
//        title.backgroundColor = UIColor.grayColor()
//        avatar.backgroundColor = UIColor.redColor()
//        node.backgroundColor = UIColor.blueColor()
//        lastModified.backgroundColor = UIColor.greenColor()
//        member.backgroundColor = UIColor.purpleColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func UILayout() {
        
        constrain(avatar) { view in
            view.width == self.avatarWidth
            view.height == self.avatarWidth
            view.top == view.superview!.top + MARGIN_TO_BOUNDARY
            view.left == view.superview!.left + MARGIN_TO_BOUNDARY
        }
        
        constrain(title, avatar) { view1, view2 in
            view1.left == view2.right + SPACING_BEWTWEEN_COMPONENTS
            view1.top == view2.top
            view1.right == view1.superview!.right - MARGIN_TO_BOUNDARY
            /*
            For node label to align to avatar's bottom
            node's height is 16
            the hard code minHeight is avatar's height - node's label's height
            */
            let minHeight:CGFloat = self.avatarWidth - 16
            view1.height >= minHeight ~ 1000
        }
        
        constrain(node, member, lastModified, lastModifyMember, title) {v1, v2, v3, v4, v5 in
            v1.left == v5.left
            v2.left == v1.right + SPACING_BEWTWEEN_COMPONENTS
//            v3.left == v2.right + SPACING_BEWTWEEN_COMPONENTS
//            v4.left == v3.right + SPACING_BEWTWEEN_COMPONENTS
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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
