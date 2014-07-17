//
//  HUDImageView.m
//  Listen
//
//  Created by Dai Hovey on 24/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import "HUDImageView.h"
#import "UIFont+ListenFont.h"

@interface HUDImageView ()

@property (nonatomic, strong) UIImageView *addImageView;
@property (nonatomic, strong) UIImageView *pauseImgView;
@property (nonatomic, strong) UIImageView *deleteImgView;
@property (nonatomic, strong) UIImageView *playImgView;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *middleSlashLabel;
@property (nonatomic) BOOL __block timeShowing;

@end

@implementation HUDImageView

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    static HUDImageView *instance;
    dispatch_once(&onceToken, ^{ instance = [[[self class] alloc] init]; });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        UIImage *add = [UIImage imageNamed:@"Alert-Add-white"];
        _addImageView = [[UIImageView alloc] initWithImage:add];
        _addImageView.frame = CGRectMake(220 * 0.5 - ((add.size.width * 0.387f) * 0.5), (46.5 * 0.5) - ((add.size.width * 0.387f) * 0.5f), add.size.width * 0.387f, add.size.height * 0.387f);
        
        UIImage *delete = [UIImage imageNamed:@"Alert-Remove-white"];
        _deleteImgView = [[UIImageView alloc] initWithImage:delete];
        _deleteImgView.frame = CGRectMake(220 * 0.5 - ((delete.size.width * 0.387f) * 0.5), (46.5 * 0.5) - ((delete.size.width * 0.387f) * 0.5f), delete.size.width * 0.387f, delete.size.height * 0.387f);
 
        UIImage *play = [UIImage imageNamed:@"New-Play"];
        _playImgView = [[UIImageView alloc] initWithImage:play];
        _playImgView.frame = CGRectMake(220 * 0.5 - ((play.size.width) * 0.5), (46.5 * 0.5) - (play.size.height * 0.5f), play.size.width , play.size.height);
       
        UIImage *pause = [UIImage imageNamed:@"New-Pause"];
        _pauseImgView = [[UIImageView alloc] initWithImage:pause];
        _pauseImgView.frame = CGRectMake(220 * 0.5 - ((pause.size.width) * 0.5), (46.5 * 0.5) - (pause.size.height * 0.5f), pause.size.width, pause.size.height );
        
        _leftTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 105, 46.5)];
        _leftTimeLabel.textColor = UIColorFromRGB(WHITE_COLOUR);
        _leftTimeLabel.backgroundColor = [UIColor clearColor];
        _leftTimeLabel.textAlignment = NSTextAlignmentRight;
        _leftTimeLabel.font = [UIFont lightListenFontOfSize: 18];
        _leftTimeLabel.adjustsFontSizeToFitWidth = YES;
        _leftTimeLabel.alpha = 0;
        [self addSubview:_leftTimeLabel];
        
        _middleSlashLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 0, 10, 46.5)];
        _middleSlashLabel.textColor = UIColorFromRGB(WHITE_COLOUR);
        _middleSlashLabel.backgroundColor = [UIColor clearColor];
        _middleSlashLabel.textAlignment = NSTextAlignmentCenter;
        _middleSlashLabel.text = @"/";
        _middleSlashLabel.font = [UIFont lightListenFontOfSize:18];
        _middleSlashLabel.adjustsFontSizeToFitWidth = YES;
        _middleSlashLabel.alpha = 0;
        [self addSubview:_middleSlashLabel];
        
        _rightTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 0, 105, 46.5)];
        _rightTimeLabel.textColor = UIColorFromRGB(WHITE_COLOUR);
        _rightTimeLabel.backgroundColor = [UIColor clearColor];
        _rightTimeLabel.textAlignment = NSTextAlignmentLeft;
        _rightTimeLabel.font = [UIFont lightListenFontOfSize:18];
        _rightTimeLabel.adjustsFontSizeToFitWidth = YES;
        _rightTimeLabel.alpha = 0;
        [self addSubview:_rightTimeLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeChanged:) name:NOTIFICATION_TIME_CHANGED object:nil];
    }
    return self;
}

-(void) timeChanged:(NSNotification*)note
{
    NSDictionary *dict = note.userInfo;
    double duration = [[dict objectForKey:@"duration"] doubleValue];
    double currentTime = [[dict objectForKey:@"currentTime"] doubleValue];
    
    [_addImageView removeFromSuperview];
    [_deleteImgView removeFromSuperview];
    [_playImgView removeFromSuperview];
    [_pauseImgView removeFromSuperview];
    
    [self addSubview:_rightTimeLabel];
    [self addSubview:_middleSlashLabel];
    [self addSubview:_leftTimeLabel];
    
    _leftTimeLabel.text = [NSString stringWithFormat:@"%lu:%02lu\u2009", (unsigned long)(currentTime / 60), ((NSUInteger)currentTime % 60)];
    _rightTimeLabel.text = [NSString stringWithFormat:@"\u2009%lu:%02lu", (unsigned long)(duration / 60), ((NSUInteger)duration % 60)];
    
    _leftTimeLabel.alpha = 0;
    _rightTimeLabel.alpha = 0;
    _middleSlashLabel.alpha = 0;
    
    _timeShowing = YES;
    
    [UIView animateWithDuration:0.3 animations:^
    {
        _rightTimeLabel.alpha = 1;
        _leftTimeLabel.alpha = 1;
        _middleSlashLabel.alpha = 1;
    }];
    
    [UIView animateWithDuration:0.3 delay:1.3 options:(UIViewAnimationOptionTransitionNone) animations:^
    {
        _leftTimeLabel.alpha = 0;
        _rightTimeLabel.alpha = 0;
        _middleSlashLabel.alpha = 0;
    } completion:^(BOOL finished)
    {
        if (finished)
        {
            _timeShowing = NO;
        }
    }];
}

-(void) showImage:(HUDImageType)imageType
{
    [_addImageView removeFromSuperview];
    [_deleteImgView removeFromSuperview];
    [_playImgView removeFromSuperview];
    [_pauseImgView removeFromSuperview];
 
    _addImageView.alpha = 0;
    _deleteImgView.alpha = 0;
    _playImgView.alpha = 0;
    _pauseImgView.alpha = 0;
   
    if (!_timeShowing)
    {
        switch (imageType)
        {
            case Add_HUDImageType:
            {
                [self addSubview:_addImageView];
                
                [UIView animateWithDuration:0.3 animations:^
                {
                    _addImageView.alpha = 1;
                }];
                
                [UIView animateWithDuration:0.3 delay:1.3 options:(UIViewAnimationOptionTransitionNone) animations:^
                {
                    _addImageView.alpha = 0;
                } completion:NULL];
            }
                break;
                
            case Delete_HUDImageType:
            {
                [self addSubview:_deleteImgView];
                
                [UIView animateWithDuration:0.3 animations:^
                {
                    _deleteImgView.alpha = 1;
                }];
                
                [UIView animateWithDuration:0.3 delay:1.3 options:(UIViewAnimationOptionTransitionNone) animations:^
                {
                    _deleteImgView.alpha = 0;
                } completion:NULL];
            }
                break;
                
            case Play_ImageType:
            {
                [self addSubview:_playImgView];
                
                [UIView animateWithDuration:0.3 animations:^
                {
                    _playImgView.alpha = 1;
                }];
                
                [UIView animateWithDuration:0.3 delay:1.3 options:(UIViewAnimationOptionTransitionNone) animations:^
                {
                    _playImgView.alpha = 0;
                } completion:NULL];
            }
                break;
                
            case Pause_ImageType:
            {
                [self addSubview:_pauseImgView];
                
                [UIView animateWithDuration:0.3 animations:^
                {
                    _pauseImgView.alpha = 1;
                }];
                
                [UIView animateWithDuration:0.3 delay:1.3 options:(UIViewAnimationOptionTransitionNone) animations:^
                {
                    _pauseImgView.alpha = 0;
                } completion:NULL];
            }
                break;
                
            default:
                break;
        }
    }
}

@end
