//
//  CoreTextImageRunDelegateHelper.h
//  CoreTextTest
//
//  Created by ciel on 15/12/17.
//  Copyright © 2015年 CL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class CTFrameParserConfig;


@interface CoreTextImageRunDelegateHelper : NSObject

+ (NSAttributedString *)parseAttributedContentFromDictionary:(UIImage *)image attributes:(NSDictionary *)attributes;
@end
