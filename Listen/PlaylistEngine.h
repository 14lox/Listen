//
//  PlaylistEngine.h
//  Listen
//
//  Created by Dai Hovey on 13/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SongObject.h"
@import AVFoundation;

@protocol PlaylistEngineDelegate <NSObject>

@optional
-(void) updateTimesWithScrubber:(double)percent duration:(double)duration currentTime:(double)currentTime;

@end

@interface PlaylistEngine : NSObject

@property (nonatomic, strong)  NSMutableArray *arraySongsOffDevice; 
@property (nonatomic, strong)  __block NSMutableArray *arraySearchTracks;
@property (nonatomic, strong)  __block NSMutableArray *arrayAlbums;
@property (nonatomic, strong)  NSMutableArray *mutablePlaylistArray;
@property (nonatomic, strong) id <PlaylistEngineDelegate> delegate;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) NSInteger indexOfPlaylistTrack;
@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic) BOOL IN_INSTRUCTIONAL_MODE;

+ (PlaylistEngine *) shared;

-(void) addSong:(SongObject*)song;
-(void) deleteSong:(SongObject*)song;
-(void) playPlayer;
-(void) pausePlayer;
-(void) clearPlaylist;
-(void) playSong:(SongObject*)song withIndex:(NSInteger)index;
-(void) seekToTime:(double)percent;
-(void) playPauseToggle;
-(void) gotoNextTrack;
-(void) gotoPreviousTrack;
-(void) stopForInterruption;
-(void) playForInterruption;
-(void) fromSavedPlaylistCurrentTrackIndex:(NSUInteger)currentTrackIndex currentTime:(double)currentTime;
-(double) getCurrentTrackTime; // for saving posisiton.
-(void) willBecomeActive;
-(void) willBackground;

@end