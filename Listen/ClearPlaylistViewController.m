//
//  ClearPlaylistViewController.m
//  Listen
//
//  Created by Dai Hovey on 04/12/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import "ClearPlaylistViewController.h"
#import "UIFont+ListenFont.h"

@interface ClearPlaylistViewController ()

@end

@implementation ClearPlaylistViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    background.alpha = 0.7;
    background.backgroundColor = [UIColor blackColor];
    [self.view addSubview:background];
    
    UILabel *clearPlaylistLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    clearPlaylistLabel.font = [UIFont boldListenFontOfSize: 36];
    clearPlaylistLabel.numberOfLines = 0;
    clearPlaylistLabel.text = @"Clearing\nList.en\nplaylist...";
    clearPlaylistLabel.textAlignment = NSTextAlignmentCenter;
    clearPlaylistLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:clearPlaylistLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end