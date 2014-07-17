//
//  SmallPlayerView.m
//  Listen
//
//  Created by Dai Hovey on 20/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import "SmallPlayerView.h"
#import "PlaylistEngine.h"
#import "CBAutoScrollLabel.h"
#import "UIFont+ListenFont.h"

@interface SmallPlayerView ()

@property (nonatomic) CALayer *progressLayer;
@property (nonatomic) CGFloat percentagePlayed;
@property (nonatomic, strong) CBAutoScrollLabel *scrollingLabel;
@property (nonatomic, strong) NSAttributedString *littleTitleString;
@property (nonatomic, strong) UIImageView *playPauseIcon;
@property (nonatomic, strong) UIView *playPauseBG;

@end

@implementation SmallPlayerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = UIColorFromRGB(BACKGROUND_COLOUR);
        
        _playPauseBG = [[UIView alloc] init];
        _playPauseBG.backgroundColor = UIColorFromRGB(BACKGROUND_COLOUR);
        _playPauseBG.frame = CGRectMake(0, 0, 44, 44);
        [self addSubview:_playPauseBG];
        
        _playPauseIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"More-On"]];
        _playPauseIcon.frame = CGRectMake(0, 0, 44, 44);
        _playPauseIcon.transform = CGAffineTransformMakeRotation(270 * M_PI/180);
        [_playPauseBG addSubview:_playPauseIcon];
    
        CALayer *line = [CALayer layer];
        line.backgroundColor = UIColorFromRGB(GREY_COLOUR).CGColor;
        line.frame = CGRectMake(self.frame.size.width - 44 + 14, 20, 16, 1);
        [self.layer addSublayer:line];
        
        CALayer *line2 = [CALayer layer];
        line2.backgroundColor = UIColorFromRGB(GREY_COLOUR).CGColor;
        line2.frame = CGRectMake(self.frame.size.width - 44 + 14, 24, 16, 1);
        [self.layer addSublayer:line2];

        _progressLayer = [CALayer layer];
        _progressLayer.backgroundColor = UIColorFromRGB(RED_COLOUR).CGColor;
        _progressLayer.frame = CGRectMake(0, 0, 0, 6.0f);
        [self.layer addSublayer:_progressLayer];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentTrackUpdatedWithNotification:) name:NOTIFICATION_CURRENT_TRACK_UPDATE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playPauseToggleNotification:) name:NOTIFICATION_PLAY_PAUSE_TOGGLE object:nil];
    }
    return self;
}

-(void) playPauseToggleNotification:(NSNotification*)note
{
    if ([PlaylistEngine shared].isPlaying)
    {
        _playPauseIcon.image = [UIImage imageNamed:@"Pause"];
        _playPauseIcon.transform = CGAffineTransformMakeRotation(0 * M_PI/180);
    }
    else
    {
        _playPauseIcon.image = [UIImage imageNamed:@"More-On"];
        _playPauseIcon.transform = CGAffineTransformMakeRotation(270 * M_PI/180);
    }
}

-(void) currentTrackUpdatedWithNotification:(NSNotification*)note
{
    NSDictionary *dict = note.userInfo;
    SongObject *songObj = [dict objectForKey:SONG_OBJECT];
    [self getDataFromMediaItem:songObj.mediaItem];
}

-(void) titleAttributedStringWithFullString:(NSString*)fullString titleString:(NSString*)titleString artist:(NSString*)artistString album:(NSString*)albumString scale:(CGFloat)scale
{
//     NSLog(@"fullString = %@", fullString);
//    NSLog(@"titleString = %@", titleString);
//    NSLog(@"artistString = %@", artistString);
//    NSLog(@"albumString = %@", albumString);

    NSMutableAttributedString * littleString = [[NSMutableAttributedString alloc] initWithString:fullString];
    
    [littleString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(RED_COLOUR) range:NSMakeRange(0,titleString.length)];
    [littleString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(PINK_COLOUR) range:NSMakeRange(titleString.length + 1,artistString.length )];
    [littleString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(GREY_COLOUR) range:NSMakeRange(titleString.length + artistString.length + 2 ,albumString.length)];
    [littleString addAttribute:NSFontAttributeName value:[UIFont lightListenFontOfSize: 18] range:NSMakeRange(0, fullString.length)];
    [littleString addAttribute:NSKernAttributeName value:[NSNumber numberWithFloat:-0.5f] range:NSMakeRange(0, fullString.length)];
    
    [self setLittleTitleString:littleString];
}

-(void) getDataFromMediaItem:(MPMediaItem*)mediaItem
{
    NSString *titleName = [mediaItem valueForKey:MPMediaItemPropertyTitle];
    if (titleName.length == 0 || !titleName) titleName = @"";
    
    NSString *artistName = [mediaItem valueForProperty: MPMediaItemPropertyArtist];
    if (artistName.length == 0 || !artistName) artistName = @"";
    
    NSString *albumName = [mediaItem valueForProperty: MPMediaItemPropertyAlbumTitle];
    if (albumName.length == 0 || !albumName) albumName = @"";
    
    NSString *songArtistAlbumName = [NSString stringWithFormat:@"%@ %@ %@", titleName , artistName, albumName];
    
    [self titleAttributedStringWithFullString:songArtistAlbumName titleString:titleName artist:artistName album:albumName scale:1];
}

-(void) setLittleTitleString:(NSAttributedString *)littleTitleString
{
    _littleTitleString = littleTitleString;
   
    if (!_scrollingLabel)
    {
        _scrollingLabel = [[CBAutoScrollLabel alloc] initWithFrame:CGRectMake(44, 0, self.frame.size.width - 88, PLAYER_HEIGHT)];
        _scrollingLabel.backgroundColor = [UIColor clearColor];
    }
    
    _scrollingLabel.attributedText = _littleTitleString;
    
    _scrollingLabel.labelSpacing = 35; // distance between start and end labels
    _scrollingLabel.pauseInterval = 1.7; // seconds of pause before scrolling starts again
    _scrollingLabel.scrollSpeed = 20; // pixels per second
    _scrollingLabel.textAlignment = NSTextAlignmentLeft; // centers text when no auto-scrolling is applied
    _scrollingLabel.fadeLength = 0.f;
    _scrollingLabel.scrollDirection = CBAutoScrollDirectionLeft;
    [_scrollingLabel observeApplicationNotifications];
    
    [self insertSubview:_scrollingLabel belowSubview:_playPauseBG];
    }

-(void) playbackTimeUpdated:(CGFloat)playbackTime duration:(CGFloat)duration
{
    if (!isnan(playbackTime))
    {
#warning Does this need to be called when not active / in view? No.
        _percentagePlayed = playbackTime / duration;
        if (isnan(_percentagePlayed)) _percentagePlayed = 0.0f;
        _progressLayer.frame = CGRectMake(0, PLAYER_HEIGHT - 6.0f, self.frame.size.width * _percentagePlayed, 6.0f);
    }
}

-(void) marqueeLittleTrackArtistAlbumLabel
{

}

-(void) willBackground
{
   
}

-(void) nowActive
{
   
}

@end