//
//  CoreTextImageRunDelegateHelper.m
//  CoreTextTest
//
//  Created by ciel on 15/12/17.
//  Copyright © 2015年 CL. All rights reserved.
//

#import "CoreTextImageRunDelegateHelper.h"
#import <CoreText/CoreText.h>
#import "V2EX_iOS-Swift.h"
#import <YYCategories/UIImage+YYAdd.h>

@implementation CoreTextImageRunDelegateHelper

+ (NSAttributedString *)parseImageDataFromNSDictionary:(UIImage *)image {
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(image));

    // 使用0xFFFC作为空白的占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString * content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString * space = [[NSMutableAttributedString alloc] initWithString:content];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1),
                                   kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    return space;
}

static CGFloat ascentCallback(void *ref){
    UIImage *image = (__bridge UIImage*)ref;
    UIImage *newImage = [CoreTextImageRunDelegateHelper scaleImage:image];
    return newImage.size.height;
}

static CGFloat descentCallback(void *ref){
    return 0;
}

static CGFloat widthCallback(void* ref){
    UIImage *image = (__bridge UIImage*)ref;
    UIImage *newImage = [CoreTextImageRunDelegateHelper scaleImage:image];
    return newImage.size.width;
}

+ (UIImage *)scaleImage:(UIImage *)image {
    CGFloat maxWitdh = [UIScreen mainScreen].bounds.size.width - 5 * 2 - 5;
    if (image.size.width > maxWitdh) {
        CGFloat scale = image.size.width / maxWitdh;
        CGSize newSize = CGSizeMake(image.size.width / scale, image.size.height / scale);
        UIImage *newImage = [image imageByResizeToSize:newSize];
        return newImage;
    }
    return image;
}

@end
