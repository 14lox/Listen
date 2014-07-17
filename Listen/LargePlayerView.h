//
//  LargePlayerView.h
//  Listen
//
//  Created by Dai Hovey on 20/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrubberViewController.h"
#import "PlaylistEngine.h"

@protocol VolumeHandleDelegate <NSObject>

-(void) handleVolumeDisplay;

@end

@interface LargePlayerView : UIView <PlaylistEngineDelegate>

@property (nonatomic, strong) ScrubberViewController *scrubberViewController;
@property (nonatomic, weak) id <VolumeHandleDelegate> delegate;
@property (nonatomic) BOOL isDisplayed;

-(void) playlistModified;
-(void) playPreviousTrackFromControlPanel;
-(void) playNextTrackFromControlPanel;

@end