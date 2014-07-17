//
//  SongObject.m
//  Listen
//
//  Created by Dai Hovey on 12/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import "SongObject.h"

@implementation SongObject


-(void) setTitle:(NSString *)title
{
    self.title = title;
}

-(NSString*) title
{
    return [_mediaItem valueForProperty:MPMediaItemPropertyTitle];
}

-(void) setArtist:(NSString *)artist
{
    self.artist = artist;
}

-(NSString*) artist
{
    return [_mediaItem valueForProperty:MPMediaItemPropertyArtist];
}

-(void) setAlbum:(NSString *)album
{
    self.album = album;
}

-(NSString*) album
{
    return [_mediaItem valueForProperty:MPMediaItemPropertyAlbumTitle];
}

-(void) setAlbumID:(NSNumber *)albumID
{
    self.albumID = albumID;
}

-(NSNumber*) albumID
{
    long long longlongPersistantID = [[_mediaItem valueForProperty:MPMediaItemPropertyAlbumPersistentID] longLongValue];
    
    return [NSNumber numberWithLongLong:longlongPersistantID];
}

-(void) setAlbumTrackNumber:(NSNumber *)albumTrackNumber
{
    self.albumTrackNumber = albumTrackNumber;
}

-(NSNumber*) albumTrackNumber
{
    return [_mediaItem valueForProperty:MPMediaItemPropertyAlbumTrackNumber];
}

- (void)setPersistantID:(NSNumber *)persistantID
{
    self.persistantID = persistantID;
}

-(NSNumber*) persistantID
{
    long long longlongPersistantID = [[_mediaItem valueForProperty:MPMediaItemPropertyPersistentID] longLongValue];
    
    return [NSNumber numberWithLongLong:longlongPersistantID];
}

-(void) setIsCloudItem:(BOOL)isCloudItem
{
    self.isCloudItem = isCloudItem;
}

-(BOOL) isCloudItem
{
    return [[_mediaItem valueForProperty:MPMediaItemPropertyIsCloudItem] boolValue];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\nSongObject: \nTitle: %@ \nArtist: %@ \nAlbum: %@ \nID: %@ \nMediaItem: %@" , self.title, self.artist, self.album, self.persistantID, _mediaItem];
}

@end
