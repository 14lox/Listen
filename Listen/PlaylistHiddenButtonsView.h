//
//  PlaylistHiddenButtonsView.h
//  Listen
//
//  Created by Dai Hovey on 05/12/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlaylistHiddenButtonsDelegate <NSObject>

-(void) clearButtonPressed;
-(void) shuffleButtonPressed;

@end

@interface PlaylistHiddenButtonsView : UIView

@property (nonatomic, weak) id <PlaylistHiddenButtonsDelegate> delegate;

@end
