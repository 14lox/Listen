//
//  SmallPlayerView.h
//  Listen
//
//  Created by Dai Hovey on 20/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmallPlayerView : UIView

-(void) playbackTimeUpdated:(CGFloat)playbackTime duration:(CGFloat)duration;
-(void) willBackground;
-(void) nowActive;

@end
