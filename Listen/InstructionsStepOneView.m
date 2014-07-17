//
//  InstructionsStepOneView.m
//  Listen
//
//  Created by Dai Hovey on 12/11/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import "InstructionsStepOneView.h"
#import "UIFont+ListenFont.h"

@implementation InstructionsStepOneView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    { 
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bottomView.backgroundColor = UIColorFromRGB(0x000000);
        bottomView.alpha = 0.95;
        [self addSubview:bottomView];
        
        UILabel *littleNumber = [[UILabel alloc] initWithFrame:CGRectMake(12, 42, 20, 20)];
        littleNumber.font = [UIFont lightListenFontOfSize: 16];
        littleNumber.numberOfLines = 1;
        littleNumber.textAlignment = NSTextAlignmentLeft;
        littleNumber.textColor = UIColorFromRGB(RED_COLOUR);
        littleNumber.text = @"1";
        [self addSubview:littleNumber];
        
        UILabel *partOneText = [[UILabel alloc] initWithFrame:CGRectMake(36, 42, bottomView.frame.size.width - 48, bottomView.frame.size.height)];
        partOneText.numberOfLines = 0;
        partOneText.textAlignment = NSTextAlignmentLeft;

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 2.0f;
        paragraphStyle.minimumLineHeight = 28;
        paragraphStyle.maximumLineHeight = 28;
        paragraphStyle.paragraphSpacing = 2.0f;
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping | NSLineBreakByTruncatingTail;

        NSString *partOneString = @"Welcome.\nTo get started, add two tracks to your Playlist by tapping the title or swiping to the right.";
        
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:partOneString];
        
        [string addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(RED_COLOUR) range:NSMakeRange(0, partOneString.length)];
        [string addAttribute:NSFontAttributeName value:[UIFont lightListenFontOfSize: 28] range:NSMakeRange(0,partOneString.length)];
        [string addAttribute:NSKernAttributeName value:[NSNumber numberWithFloat:0.f] range:NSMakeRange(0,partOneString.length)];
        [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, partOneString.length)];
        
        partOneText.attributedText = string;
       
        [self addSubview:partOneText];
        
        [partOneText sizeToFit];
    }
    return self;
}

@end
