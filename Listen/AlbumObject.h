//
//  SongObject.h
//  Listen
//
//  Created by Dai Hovey on 12/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumObject : NSObject

@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *album;
@property (nonatomic, strong) NSNumber *albumID;
@property (nonatomic) NSInteger numberOfTracks;
@property (nonatomic) BOOL isTopLevelHeaderOpen;

@end