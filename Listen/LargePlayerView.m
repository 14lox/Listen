//
//  LargePlayerView.m
//  Listen
//
//  Created by Dai Hovey on 20/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import "LargePlayerView.h"
#import "VolumeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PlaylistEngine.h"
#import "TrackTitleViewController.h"
#import "SongObject.h"
#import "VolumeOverlayViewController.h"
#import "UIFont+ListenFont.h"

@interface LargePlayerView () <UIScrollViewDelegate>

@property (nonatomic) CGFloat percentagePlayed;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *counterLabel;
@property (nonatomic, strong) TrackTitleViewController *trackTitleViewController;
@property (nonatomic, strong) UILabel *nowPlaying;

@end

@implementation LargePlayerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

-(void) setup
{
    CGFloat screenWidth = self.frame.size.width;
    
    self.backgroundColor = UIColorFromRGB(BACKGROUND_COLOUR);
    
    _nowPlaying = [[UILabel alloc] initWithFrame:CGRectMake(14, 44, 90, 15)];
    _nowPlaying.textColor = UIColorFromRGB(GREY_COLOUR);
    _nowPlaying.backgroundColor = [UIColor clearColor];
    _nowPlaying.textAlignment = NSTextAlignmentLeft;
    _nowPlaying.font = [UIFont lightListenFontOfSize :14];
    [self addSubview:_nowPlaying];
    
    CALayer *line = [CALayer layer];
    line.backgroundColor = UIColorFromRGB(GREY_COLOUR).CGColor;
    line.frame = CGRectMake(self.frame.size.width *0.5 - 8, 20, 16, 1);
    [self.layer addSublayer:line];

    CALayer *line2 = [CALayer layer];
    line2.backgroundColor = UIColorFromRGB(GREY_COLOUR).CGColor;
    line2.frame = CGRectMake(self.frame.size.width * 0.5f - 8, 24, 16, 1);
    [self.layer addSublayer:line2];
    
    _counterLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, self.frame.size.height - 50, 92, 50)];
    _counterLabel.textColor = UIColorFromRGB(0x6d6e71);
    _counterLabel.textAlignment = NSTextAlignmentLeft;
    _counterLabel.font = [UIFont lightListenFontOfSize: 18];
    [self addSubview:_counterLabel];
    
    _scrubberViewController = [[ScrubberViewController alloc] init];
    _scrubberViewController.view.frame = CGRectMake(0, self.frame.size.height - 34 - 20 - 14, screenWidth, 50);
    [self addSubview:_scrubberViewController.view];

    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat titleHeight;
    
    if (screenHeight >= 568)
    {
        titleHeight = 364;
    }
    else
    {
        titleHeight = 264;
    }
    
    _trackTitleViewController = [[TrackTitleViewController alloc] init];
    _trackTitleViewController.view.frame = CGRectMake(0, 68, self.frame.size.width, titleHeight);
    _trackTitleViewController.view.backgroundColor = [UIColor clearColor];
    [self addSubview:_trackTitleViewController.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentTrackUpdatedWithIndex:) name:NOTIFICATION_CURRENT_TRACK_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playPauseToggleNotification:) name:NOTIFICATION_PLAY_PAUSE_TOGGLE object:nil];
}


#pragma mark PlaylistEngine delegate

-(void) playPauseToggleNotification:(NSNotification*)note
{
    if ([PlaylistEngine shared].isPlaying)
    {
        _nowPlaying.text = @"Now Playing";
    }
    else
    {
        _nowPlaying.text = @"Paused";
    }
}

-(void) playPreviousTrackFromControlPanel
{
    [_trackTitleViewController playPrevious];
    [self updateCounterLabel];
}

-(void) playNextTrackFromControlPanel
{
    [_trackTitleViewController playNextDidReachEnd:NO];
    [self updateCounterLabel];
}

-(void) currentTrackUpdatedWithIndex:(NSNotification*)note
{
    if (_isDisplayed)
    {
        NSDictionary *dict = note.userInfo;
        NSInteger indx = [[dict objectForKey:SONG_INDEX] integerValue];
        BOOL didReachEnd = [[dict objectForKey:REACHED_END] boolValue];
        
        [_trackTitleViewController populateWithCurrentIndex:indx didReachEnd:didReachEnd];
        
        [self updateCounterLabel];
    }
}

-(void) updateCounterLabel
{
    if ([PlaylistEngine shared].mutablePlaylistArray.count > 0)
    {
        _counterLabel.text = [NSString stringWithFormat:@"%li\u2009/\u2009%lu", [PlaylistEngine shared].indexOfPlaylistTrack + 1, (unsigned long)[PlaylistEngine shared].mutablePlaylistArray.count];
    }
    else
    {
        _counterLabel.text = @"0\u2009/\u20090";
    }
}

-(void) playlistModified
{
     NSLog(@"playlistModified  _isDisplayed= %i", _isDisplayed);
    
    if (_isDisplayed)
    {
        [_trackTitleViewController refreshWithCurrentIndex:[PlaylistEngine shared].indexOfPlaylistTrack];
        
        [_trackTitleViewController populateWithCurrentIndex:[PlaylistEngine shared].indexOfPlaylistTrack didReachEnd:NO];
        
        [self updateCounterLabel];
    }
}

@end
