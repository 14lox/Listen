//
//  PlayerViewController.m
//  Listen
//
//  Created by Dai Hovey on 20/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import "PlayerViewController.h"
#import "PlaylistEngine.h"
#import "VolumeOverlayViewController.h"

@interface PlayerViewController () <PlaylistEngineDelegate, VolumeHandleDelegate>


@property (nonatomic) CGFloat scrubberPercent;
@end

@implementation PlayerViewController

- (id)init
{
    self = [super init];
    if (self)
    {
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorFromRGB(BACKGROUND_COLOUR);
    
    [PlaylistEngine shared].delegate = self;
    
    _playerViewState = PlayerViewStateClosed;
    
    _largePlayerView = [[LargePlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - PLAYER_HEIGHT)];
    _largePlayerView.alpha = 0;
    _largePlayerView.delegate = self;
    [self.view addSubview:_largePlayerView];
    
    _smallPlayerView = [[SmallPlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, PLAYER_HEIGHT)];
    [self.view addSubview:_smallPlayerView];
    
    _draggableArea = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 44, PLAYER_HEIGHT)];
    [self.view addSubview:_draggableArea];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playListArrayModified:) name:NOTIFICATION_PLAYLIST_ARRAY_MODIFIED object:nil];
}

-(void) updateTimesWithScrubber:(double)percent duration:(double)duration currentTime:(double)currentTime
{
    if (_largePlayerView.isDisplayed)
    {
        [_largePlayerView.scrubberViewController setTime:currentTime andDuration:duration];
        [_largePlayerView.scrubberViewController updatePositionWithPercent:percent];
    }
    
    [_smallPlayerView playbackTimeUpdated:currentTime duration:duration];
}

-(void) playListArrayModified:(NSNotification*)notification
{
    // Not used...
}

-(void) setPlayerViewState:(PlayerViewState)playerViewState
{
    _playerViewState = playerViewState;
        
    if (_playerViewState == PlayerViewStateClosed)
    {
        _largePlayerView.isDisplayed = NO;
        
        [UIView animateWithDuration:0.3f animations:^
         {
             _smallPlayerView.alpha = 1;
         } completion:NULL];
    }
    else if (_playerViewState == PlayerViewStateOpen)
    {
        _largePlayerView.isDisplayed =YES;
        [UIView animateWithDuration:0.3f animations:^
         {
             _largePlayerView.alpha = 1;
         } completion:NULL];
    }
    else if (_playerViewState == PlayerViewStateWillOpen)
    {
        _largePlayerView.isDisplayed = YES;
        [_largePlayerView playlistModified];
        
        
        [UIView animateWithDuration:0.3f animations:^
         {
             _smallPlayerView.alpha = 0;
         } completion:NULL];
    }
    else if (_playerViewState == PlayerViewStateWillClose)
    {
        _largePlayerView.isDisplayed = NO;
        
        [UIView animateWithDuration:0.3f animations:^
         {
             _largePlayerView.alpha = 0;
         } completion:NULL];
    }
}

-(void) handleVolumeDisplay
{
    VolumeOverlayViewController *volumeOverlay = [[VolumeOverlayViewController alloc] init];
    volumeOverlay.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self presentViewController:volumeOverlay animated:NO completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

@end