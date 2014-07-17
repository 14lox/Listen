//
//  UIFont+ListenFont.m
//  Listen
//
//  Created by Dai Hovey on 18/12/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import "UIFont+ListenFont.h"

@implementation UIFont (ListenFont)

+ (UIFont*)lightListenFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:size];
}

+ (UIFont*)boldListenFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
}

@end
