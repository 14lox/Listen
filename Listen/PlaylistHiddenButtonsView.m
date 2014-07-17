//
//  PlaylistHiddenButtonsView.m
//  Listen
//
//  Created by Dai Hovey on 05/12/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import "PlaylistHiddenButtonsView.h"

@implementation PlaylistHiddenButtonsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor redColor];
        
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        clearButton.backgroundColor = UIColorFromRGB(RED_COLOUR);
        [clearButton setTitleColor:UIColorFromRGB(GREY_COLOUR) forState:UIControlStateNormal];
        [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
        clearButton.frame = CGRectMake(0, 0, self.frame.size.width * 0.5f, self.frame.size.height);
        [clearButton addTarget:self action:@selector(clearButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearButton];

        UIButton *shuffleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shuffleButton.backgroundColor = UIColorFromRGB(0xfb797a);
        [shuffleButton setTitleColor:UIColorFromRGB(GREY_COLOUR) forState:UIControlStateNormal];
        [shuffleButton setTitle:@"Shuffle" forState:UIControlStateNormal];
        shuffleButton.frame = CGRectMake(self.frame.size.width * 0.5f, 0, self.frame.size.width * 0.5f, self.frame.size.height);
        [shuffleButton addTarget:self action:@selector(shuffleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:shuffleButton];
        
    }
    return self;
}

-(void) clearButtonPressed:(id)sender
{
    [_delegate clearButtonPressed];
}

-(void) shuffleButtonPressed:(id)sender
{
    [_delegate shuffleButtonPressed];
}

@end
