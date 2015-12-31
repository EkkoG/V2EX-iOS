//
//  AllNodeViewController.swift
//  V2EX-iOS
//
//  Created by ciel on 15/12/31.
//  Copyright © 2015年 CL. All rights reserved.
//

import UIKit
import RFQuiltLayout

let kAllNodeCellReuseIndentifier = "com.ciepy.v2ex-ios.allNodeCell"

class AllNodeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,  RFQuiltLayoutDelegate {
    lazy var nodeCollectionView: UICollectionView = {
        [unowned self] in
        
        let layout = RFQuiltLayout()
        layout.direction = .Vertical
        layout.blockPixels = CGSizeMake(20, 30)
        layout.delegate = self
        let collection = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collection.backgroundColor = UIColor.whiteColor()
        collection.dataSource = self
        collection.delegate = self
        return collection
    }()
    
    var allNodeArray = [Node]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "节点"
        self.view.addSubview(self.nodeCollectionView)
        self.nodeCollectionView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleHeight]
        
        self.nodeCollectionView.registerClass(NodeCollectionViewCell.self, forCellWithReuseIdentifier: kAllNodeCellReuseIndentifier)
        
        DataManager.getAllNode { (dataResponse) -> Void in
            guard let data = dataResponse.data else {
                return
            }
//            print(data)
            self.allNodeArray = data
            self.nodeCollectionView.reloadData()
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kAllNodeCellReuseIndentifier, forIndexPath: indexPath) as! NodeCollectionViewCell
        
        cell.nodeModel = self.allNodeArray[indexPath.row]

        return cell
    }
    
    func blockSizeForItemAtIndexPath(indexPath: NSIndexPath!) -> CGSize {
        let model = self.allNodeArray[indexPath.row]
        let width = self.getTitleWidth(model.title! as NSString) / 20.0 + 0.5
        return CGSizeMake(width, 1)
    }
    
    func insetsForItemAtIndexPath(indexPath: NSIndexPath!) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allNodeArray.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let model = self.allNodeArray[indexPath.row]
        print(model.title)
    }
    
    func getTitleWidth(title: NSString) -> CGFloat {
        let size = title.boundingRectWithSize(CGSizeMake(UIScreen.mainScreen().bounds.width, 200), options: [NSStringDrawingOptions.UsesLineFragmentOrigin, NSStringDrawingOptions.UsesFontLeading], attributes: [NSFontAttributeName: UIFont.systemFontOfSize(17)], context: nil)
        return size.width
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
