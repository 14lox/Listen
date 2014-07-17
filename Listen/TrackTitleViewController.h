//
//  TrackTitleViewController.h
//  Listen
//
//  Created by Dai Hovey on 22/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum
{
    PreviousPlayDirectionState,
    NextPlayDirectionState
} PlayDirectionState;

@interface TrackTitleViewController : UIViewController

-(void) populateWithCurrentIndex:(NSInteger)currentIndex didReachEnd:(BOOL)didReachEnd;
-(void) playPrevious;
-(void) playNextDidReachEnd:(BOOL)didReachEnd;
-(void) refreshWithCurrentIndex:(NSInteger)currentIndex;

@end