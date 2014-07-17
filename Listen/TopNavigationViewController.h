//
//  TopNavigationViewController.h
//  Listen
//
//  Created by Dai Hovey on 06/12/2012.
//  Copyright (c) 2012 14lox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TopNavigationDelegate <NSObject>

@optional

-(void) searchButtonPressed;
-(void) playlistButtonPressed;

@end

@interface TopNavigationViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *playlistButton;
@property (nonatomic, strong) UIButton *scrollTopButton;
@property (nonatomic, strong) id <TopNavigationDelegate> delegate;
@property (nonatomic, strong) UITextField *textField;

-(void) updateIconsForSearchTextEntry;
-(void) updateIconsForSearch;
-(void) updateIconsForPlaylist;

@end