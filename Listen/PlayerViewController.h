//
//  PlayerViewController.h
//  Listen
//
//  Created by Dai Hovey on 20/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LargePlayerView.h"
#import "SmallPlayerView.h"

typedef enum
{
    PlayerViewStateWillOpen = 1, // Hide SmallVC
    PlayerViewStateWillClose = 2, // Hide LargeVC
    PlayerViewStateOpen = 3, // LargeVC showing
    PlayerViewStateClosed = 4 // SmallVC showing
} PlayerViewState;

@interface PlayerViewController : UIViewController

@property (nonatomic) PlayerViewState playerViewState;
@property (nonatomic, strong) UIView *draggableArea; //invisible area used to drag it
@property (nonatomic, strong) LargePlayerView *largePlayerView;
@property (nonatomic, strong) SmallPlayerView *smallPlayerView;

@end