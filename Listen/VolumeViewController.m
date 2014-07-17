//
//  VolumeViewController.m
//  Listen
//
//  Created by Dai Hovey on 19/02/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import "VolumeViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VolumeViewController ()

@property (nonatomic, strong) MPMusicPlayerController *theMusicPlayer;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) MPVolumeView *volumeView;

@end

@implementation VolumeViewController

- (id)init
{
    self = [super init];
    if (self)
    {
       _volumeView = [[MPVolumeView alloc] initWithFrame:CGRectZero];
    }
    return self;
}


-(void) handleSystemVolumeChange:(NSNotification*)notification
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *airplayImage = [UIImage imageNamed:@"Airplay-Off"];
    UIImageView *airplayView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, airplayImage.size.width, airplayImage.size.height)];
    airplayView.image = airplayImage;
    [self.view addSubview:airplayView];
    
    _volumeView.frame = CGRectMake(-7.5f, 0, airplayImage.size.width, airplayImage.size.height);
    _volumeView.showsVolumeSlider = NO;
    _volumeView.showsRouteButton = YES;
    [_volumeView setRouteButtonImage:[UIImage imageNamed:@"Airplay-On"] forState:UIControlStateNormal];
    
    [self.view addSubview:_volumeView];
}

-(void) dealloc
{

}

@end
