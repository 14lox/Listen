//
//  InstructionsViewController.m
//  Listen
//
//  Created by Dai Hovey on 10/11/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import "InstructionsViewController.h"
#import "UIFont+ListenFont.h"

@interface InstructionsViewController ()

@end

@implementation InstructionsViewController

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

#warning Need to check if they actually have at least one track.

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self showPartOne];
}

-(void) showPartOne
{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, PLAYER_HEIGHT)];
    topView.backgroundColor = UIColorFromRGB(0x000000);
    topView.alpha = 0.8;
    [self.view addSubview:topView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, PLAYER_HEIGHT + 150, self.view.frame.size.width, self.view.frame.size.height - PLAYER_HEIGHT - 150)];
    bottomView.backgroundColor = UIColorFromRGB(0x000000);
    bottomView.alpha = 0.7;
    [self.view addSubview:bottomView];
    
    UILabel *partOneText = [[UILabel alloc] initWithFrame:bottomView.frame];
    partOneText.font = [UIFont lightListenFontOfSize:32];
    partOneText.numberOfLines = 0;
    partOneText.textColor = UIColorFromRGB(WHITE_COLOUR);
    partOneText.text = @"Welcome,\nTo add a track tap on a track name or slide to the right.";
    [self.view addSubview:partOneText];
}

-(void) closeButtonPressed:(id)sender
{
    [_delegate handleClose];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
