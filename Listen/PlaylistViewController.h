//
//  PlaylistViewController.h
//  Listen
//
//  Created by David Hovey on 12/04/2012.
//  Copyright (c) 2012 14lox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PlaylistViewController : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

+ (PlaylistViewController *)shared;

@end