//
//  CommonConfiguration.swift
//  V2EX-iOS
//
//  Created by ciel on 15/11/25.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit

//let HomeTabs = ["最新", "最热", "全部", "R2", "技术", "创意", "好玩", "Apple", "酷工作", "交易", "城市", "问与答", "节点", "关注"]

enum HomeTabs {
    case tech, creative, play, apple, jobs, deals, city, qna, hot, all, r2, latest, node
    var title: String {
        switch self {
        case  .tech:
            return "技术"
        case .creative:
            return "创意"
        case .play:
            return "好玩"
        case .apple:
            return "Apple"
        case .jobs:
            return "酷工作"
        case .deals:
            return "交易"
        case .city:
            return "城市"
        case .qna:
            return "问与答"
        case .hot:
            return "最热"
        case .all:
            return "全部"
        case .r2:
            return "R2"
        case .latest:
            return "最新"
        case .node:
            return "节点"
        }
    }

    var path: String {
        switch self {
        case  .tech:
            return "tech"
        case .creative:
            return "creative"
        case .play:
            return "play"
        case .apple:
            return "apple"
        case .jobs:
            return "jobs"
        case .deals:
            return "deals"
        case .city:
            return "city"
        case .qna:
            return "qna"
        case .hot:
            return "hot"
        case .all:
            return "all"
        case .r2:
            return "r2"
        case .latest:
            return "latest"
        case .node:
            return "node"
        }
    }
    
    static let allValue = [latest, tech, creative, play, apple, jobs, deals, city, qna, hot, all, r2, node]
}

public let SPACING_BEWTWEEN_COMPONENTS:CGFloat = 5
public let MARGIN_TO_BOUNDARY:CGFloat = 5

class CommonConfiguration: NSObject {

}
