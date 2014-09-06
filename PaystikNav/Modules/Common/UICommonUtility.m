//
//  UICommonUtility.m
//  HandyFlickr
//
//  Created by Bobie Chen on 2014/3/4.
//  Copyright (c) 2014年 Bobie Chen. All rights reserved.
//

#import "UICommonUtility.h"

@implementation UICommonUtility

+ (CGSize)getScreenSize
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    
    return screenBound.size;
}

+ (UIColor*)hexToColor:(NSUInteger)hexValue withAlpha:(CGFloat)fAlpha
{
    CGFloat fRed = ((hexValue >> 16) & 0xFF) / 255.0f;
    CGFloat fGreen = ((hexValue >> 8) & 0xFF) / 255.0f;
    CGFloat fBlue = (hexValue & 0xFF) / 255.0f;
    
    UIColor* color = [UIColor colorWithRed:fRed green:fGreen blue:fBlue alpha:fAlpha];
    return color;
}

@end
