//
//  PlayerViewDelegate
//  Listen
//
//  Created by Dai Hovey on 20/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlayerViewDelegate <NSObject>

@optional

-(void) playPauseButtonPressed;
-(void) skipNextButtonPressed;
-(void) skipPreviousButtonPressed;
-(void) skipNextButtonPressedAnimateBigTitles:(void(^)(BOOL finished))complete;

@end