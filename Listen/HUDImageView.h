//
//  HUDImageView.h
//  Listen
//
//  Created by Dai Hovey on 24/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    Add_HUDImageType,
    Delete_HUDImageType,
    Play_ImageType,
    Pause_ImageType
} HUDImageType;

@interface HUDImageView : UIImageView

+(instancetype) shared;

-(void) showImage:(HUDImageType)imageType;

@end