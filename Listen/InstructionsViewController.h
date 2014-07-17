//
//  InstructionsViewController.h
//  Listen
//
//  Created by Dai Hovey on 10/11/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InstructionsDelegate <NSObject>

-(void) handleClose;

@end

@interface InstructionsViewController : UIViewController

@property (nonatomic, weak) id <InstructionsDelegate> delegate;

@end