//
//  SearchEngine.m
//  Listen
//
//  Created by Dai Hovey on 02/10/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import "SearchEngine.h"
#import "SongObject.h"
#import "AlbumObject.h"
#import "PlaylistEngine.h"

@interface SearchEngine ()

@property (nonatomic) dispatch_queue_t backgroundQueue;

@end

@implementation SearchEngine

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    static SearchEngine *instance;
    dispatch_once(&onceToken, ^{ instance = [[[self class] alloc] init]; });
    return instance;
}

-(id) init
{
    self = [super init];
    if (self)
    {
         _backgroundQueue = dispatch_queue_create("com.14lox.listen.search", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(void) displayAllTracksWithCallback:(void(^)())callback
{
    MPMediaQuery *everything = [MPMediaQuery songsQuery];
    NSArray *itemsFromGenericQuery = [everything items];
    
    for (MPMediaItem *song in itemsFromGenericQuery)
    {
        SongObject *songObject = [SongObject new];
        songObject.mediaItem = song;
        [[PlaylistEngine shared].arraySongsOffDevice addObject:songObject];
    }
    
     callback();
}

-(void) searchWithString:(NSString*)query callback:(void(^)())callback
{
    dispatch_async(_backgroundQueue, ^
    {
        @autoreleasepool
        {
            _isProcessingSearch = YES;
            
            [[PlaylistEngine shared].arraySearchTracks removeAllObjects];
            [[PlaylistEngine shared].arrayAlbums removeAllObjects];
        
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains [c] %@ OR album contains [c] %@ OR artist contains [c] %@", query, query, query];

            NSArray *filteredArray = [[PlaylistEngine shared].arraySongsOffDevice filteredArrayUsingPredicate:predicate];
        
            NSMutableArray *tempAlbumArray = [[NSMutableArray alloc] init];
            
            for (SongObject *song in filteredArray)
            {
                [[PlaylistEngine shared].arraySearchTracks addObject:song];
                
                BOOL shouldAdd = YES;
        
                for (AlbumObject *albObj in tempAlbumArray)
                {
                    if ([albObj.albumID longLongValue] == [song.albumID longLongValue])
                    {
                        shouldAdd = NO;
                        break;
                    }
                }

                if (shouldAdd)
                {
                    AlbumObject *albumObject = [AlbumObject new];
                    albumObject.artist = song.artist;
                    albumObject.album = song.album;
                    albumObject.albumID = song.albumID;
                
                    [tempAlbumArray addObject:albumObject];
                }
                shouldAdd = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^
           {
               [PlaylistEngine shared].arrayAlbums = [tempAlbumArray mutableCopy];
               
                _isProcessingSearch = NO;
               
               callback();
           });
        }
    });
}

-(void) clearSearchArraysCallback:(void(^)())callback
{
    dispatch_async(_backgroundQueue, ^
   {
       @autoreleasepool
       {
           [[PlaylistEngine shared].arraySearchTracks removeAllObjects];
           [[PlaylistEngine shared].arrayAlbums removeAllObjects];
       }
       
       dispatch_async(dispatch_get_main_queue(), ^
      {
          callback();
      });
   });
}

@end