//
//  SongObject.m
//  Listen
//
//  Created by Dai Hovey on 12/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import "AlbumObject.h"

@implementation AlbumObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"\nAlbumObject: \nArtist: %@ \nAlbum: %@ \n", _album, _artist];
}

@end