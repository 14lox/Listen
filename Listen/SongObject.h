//
//  SongObject.h
//  Listen
//
//  Created by Dai Hovey on 12/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

typedef enum
{
    SongObjectArtistSongType = 0,
    SongObjectArtistHeaderType = 1,
    SongObjectAlbumHeaderType = 2,
    SongObjectAlbumSongType = 3,
    SongObjectAllType = 4

}SongObjectType;

@interface SongObject : NSObject

@property (nonatomic, strong) MPMediaItem *mediaItem;
@property (nonatomic) BOOL isAdded;
@property (nonatomic) BOOL isCloudItem;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *album;
@property (nonatomic, strong) NSNumber *trackID;
@property (nonatomic, strong) NSNumber *albumID;
@property (nonatomic, strong) NSNumber *albumTrackNumber;
@property (nonatomic) SongObjectType songObjectType;
@property (nonatomic, strong) NSNumber *persistantID;

@end