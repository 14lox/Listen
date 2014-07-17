//
//  ScrubberViewController.h
//  Listen
//
//  Created by Dai Hovey on 19/02/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrubberViewController : UIViewController

@property (nonatomic) CGFloat trackDuration;

-(void) updatePositionWithPercent:(double)percent;

-(void) setTime:(double)currentTime andDuration:(double)duration;

@end
