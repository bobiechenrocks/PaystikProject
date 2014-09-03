//
//  UICommonUtility.h
//  HandyFlickr
//
//  Created by Bobie Chen on 2014/3/4.
//  Copyright (c) 2014年 Bobie Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UICommonUtility : NSObject

+ (CGSize)getScreenSize;
+ (UIColor*)hexToColor:(NSUInteger)hexValue withAlpha:(NSNumber*)alpha;

@end
