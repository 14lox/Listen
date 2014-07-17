//
//  ListenNavigationControllerViewController.h
//  Listen
//
//  Created by David Hovey on 23/04/2012.
//  Copyright (c) 2012 14lox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopNavigationViewController.h"
#import "PlayerViewController.h"
#import "PlayerViewDelegate.h"

@protocol NavigationDelegate <NSObject>

@optional

-(void) handleToPlaylistSwipe;
-(void) handleToSearchSwipe;
-(void) handleUserInteractionOfBackgroundViewControllers:(BOOL)makeActive;

@end

@interface ListenNavigationController : UINavigationController <TopNavigationDelegate, PlayerViewDelegate>
{

}

@property (nonatomic, strong) TopNavigationViewController *topNavigation;
@property (nonatomic, strong) PlayerViewController *playerViewController;
@property (nonatomic, weak) id <NavigationDelegate> navigationDelegate;
@property (nonatomic, weak) id <TopNavigationDelegate> topNavigationDelegate;

@property (nonatomic) BOOL isPlayerOpen;

-(void) handleShowSearchTable;
-(void) handleShowPlaylistTable;

@end