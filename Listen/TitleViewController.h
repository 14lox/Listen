//
//  TitleViewController.h
//  Listen
//
//  Created by Dai Hovey on 22/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface TitleViewController : UIViewController

@property (nonatomic, strong) NSAttributedString *titleString;
@property (nonatomic) NSUInteger titleIndex;

-(void) getDataFromMediaItem:(MPMediaItem*)mediaItem;

@end

@interface NextTitleViewController : TitleViewController

@end

@interface PreviousTitleViewController : TitleViewController

@end