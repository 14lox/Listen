//
//  ScrubberSlider.h
//  Listen
//
//  Created by Dai Hovey on 28/02/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrubberSlider : UISlider

@property(nonatomic) BOOL hasFinishedMoving;
@property(nonatomic) CGFloat savedValue;

@end