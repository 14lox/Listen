//
//  VolumeOverlayViewController.m
//  Listen
//
//  Created by Dai Hovey on 05/10/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import "VolumeOverlayViewController.h"
#import "PlaylistEngine.h"

@interface VolumeOverlayViewController ()

@property (nonatomic, strong) UIView *volumeBox;

@end

@implementation VolumeOverlayViewController

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
    
    self.view.backgroundColor =  [UIColor blackColor];
    self.view.alpha = 0.6;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    _volumeBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _volumeBox.backgroundColor = [UIColor redColor];
    
     NSLog(@"volume = %f", [PlaylistEngine shared].player.volume);
}


-(void) tapped:(UITapGestureRecognizer*)gesture
{
    [self dismissViewControllerAnimated:NO completion:NULL];
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
