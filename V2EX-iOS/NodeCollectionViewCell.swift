//
//  NodeCollectionViewCell.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/31.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import Cartography

class NodeCollectionViewCell: UICollectionViewCell {
    
    var nodeNameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var nodeModel: Node? {
        didSet {
            self.nodeNameLabel.text = nodeModel?.title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = UIColor.redColor()
//        self.nodeNameLabel.backgroundColor = UIColor.yellowColor()
        
        self.addSubview(self.nodeNameLabel)
        
        constrain(self.nodeNameLabel) { v1 in
            v1.centerX == v1.superview!.centerX
            v1.centerY == v1.superview!.centerY
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
