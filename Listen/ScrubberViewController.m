
//
//  VolumeViewController.m
//  Listen
//
//  Created by Dai Hovey on 19/02/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//
#import "ScrubberViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PlaylistEngine.h"
#import "ScrubberSlider.h"

@interface ScrubberViewController ()

@property (nonatomic, strong) ScrubberSlider *scrubberSlider;
@property (nonatomic) CGFloat savedValue;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL isTapped;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic) double duration;
@property (nonatomic) double currentTime;

@end

@implementation ScrubberViewController

- (id)init
{
    self = [super init];
    if (self) {}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _scrubberSlider = [[ScrubberSlider alloc] initWithFrame:CGRectMake(14, -10.0f, self.view.frame.size.width - 28, 50)];
    _scrubberSlider.continuous = YES;
    _scrubberSlider.maximumValue = 1.0f;
    _scrubberSlider.minimumValue = 0.0f;
    
    [_scrubberSlider setMaximumTrackImage:[UIImage imageNamed:@"scrubber-bground"] forState:UIControlStateNormal];
    [_scrubberSlider setMinimumTrackImage:[UIImage imageNamed:@"Scrubber-Bg"] forState:UIControlStateNormal];
    [_scrubberSlider setThumbImage:[UIImage imageNamed:@"ScrubBtn"] forState:UIControlStateNormal];
    
    [_scrubberSlider addTarget:self action:@selector(handleSliderMove:) forControlEvents:UIControlEventValueChanged];
    [_scrubberSlider addTarget:self action:@selector(handleSliderStopped:) forControlEvents:UIControlEventTouchUpInside];
    [_scrubberSlider addTarget:self action:@selector(handleSliderStopped:) forControlEvents:UIControlEventTouchUpOutside];
    [_scrubberSlider addTarget:self action:@selector(handleSliderCancelled:) forControlEvents:UIControlEventTouchCancel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    [_scrubberSlider addGestureRecognizer:tap];
    
    [self.view addSubview:_scrubberSlider];
}

-(void) setTime:(double)currentTime andDuration:(double)duration
{
    _duration = duration;
    _currentTime = currentTime;
}

- (void) handleSliderMove:(UISlider*)sender
{
    _isPlaying = [PlaylistEngine shared].isPlaying;
    
    NSDictionary *params = @{@"duration" : [NSNumber numberWithDouble:_duration],
                             @"currentTime" : [NSNumber numberWithDouble:_currentTime]};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIME_CHANGED object:nil userInfo:params];

    [[PlaylistEngine shared] seekToTime:sender.value];
}

-(void) handleSliderStopped:(UISlider*)sender
{
    if (_isPlaying) [[PlaylistEngine shared] playPlayer];
}

-(void) handleSliderCancelled:(UISlider*)sender
{
    _timeLabel.hidden = YES;
   if (_isPlaying) [[PlaylistEngine shared] playPlayer];
}

- (void) tapped: (UITapGestureRecognizer*)gesture
{
    if (_scrubberSlider.highlighted)
        return; // tap on thumb, let slider deal with it
    
    CGPoint pt = [gesture locationInView: _scrubberSlider];
    CGFloat percentage = pt.x / _scrubberSlider.bounds.size.width;
    CGFloat delta = percentage * (_scrubberSlider.maximumValue - _scrubberSlider.minimumValue);
    CGFloat value = _scrubberSlider.minimumValue + delta;
    
    [[PlaylistEngine shared] seekToTime:value];
    
    if (_isPlaying) [[PlaylistEngine shared] playPlayer];
}
     
-(void) updatePositionWithPercent:(double)percent
{
     _scrubberSlider.value = percent;
}

@end
