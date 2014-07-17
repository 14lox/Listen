//
//  SearchViewController.h
//  Listen
//
//  Created by David Hovey on 12/04/2012.
//  Copyright (c) 2012 14lox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SearchViewController : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

+ (SearchViewController *)shared;

- (void) savedPlaylistAdded;

@end
