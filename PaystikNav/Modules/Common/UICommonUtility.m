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

+ (UIColor*)hexToColor:(NSUInteger)hexValue withAlpha:(NSNumber*)alpha
{
    NSNumber* red = [NSNumber numberWithInt:(hexValue>>16)];
    NSNumber* green = [NSNumber numberWithInt:((hexValue >> 8) & 0xFF)];
    NSNumber* blue = [NSNumber numberWithInt:(hexValue & 0xFF)];
    
    float fAlpha = (alpha)? [alpha floatValue] : 1.0f;
    UIColor* color = [UIColor colorWithRed:[red floatValue]/255.0f green:[green floatValue]/255.0f blue:[blue floatValue]/255.0f alpha:fAlpha];
    
    return color;
}

@end
