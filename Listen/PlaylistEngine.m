//
//  PlaylistEngine.m
//  Listen
//
//  Created by Dai Hovey on 13/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import "PlaylistEngine.h"

@interface PlaylistEngine ()

@property (nonatomic) BOOL isDirty; // The Playlist has changed - update the queue at the next possible time.
@property (nonatomic) BOOL isLocked;
@property (nonatomic) BOOL wasInterruptedPlaying; // If the app is interrupted while playing.
@property (nonatomic) id playbackObserver;

@property (nonatomic) NSUInteger INSTRUCTIONS_countTracks;

@end

@implementation PlaylistEngine

+ (PlaylistEngine *)shared
{
    static dispatch_once_t onceToken;
    static PlaylistEngine *instance;
    dispatch_once(&onceToken, ^{ instance = [[[self class] alloc] init]; });
    return instance;
}

-(id) init
{
    self = [super init];
    if (self)
    {
        _mutablePlaylistArray   = [[NSMutableArray alloc] init];
        _arraySongsOffDevice    = [[NSMutableArray alloc] init];
        _arrayAlbums            = [[NSMutableArray alloc] init];
        _arraySearchTracks      = [[NSMutableArray alloc] init];
        
        _player = [[AVPlayer alloc] init];
        
        _indexOfPlaylistTrack   = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[_player currentItem]];
    }
    return self;
}

-(void) setupPlayerWithQueueWithIndex:(NSInteger)indexTrackToPlay didReachEnd:(BOOL)didReachEnd playTrack:(BOOL)playTrack withTime:(double)seekToTime
{
    if (_isDirty && !_isLocked)
    {
        _isLocked = YES;
        
        SongObject *songObject = (SongObject*)[_mutablePlaylistArray objectAtIndex:indexTrackToPlay];
        
        AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:[songObject.mediaItem valueForProperty:MPMediaItemPropertyAssetURL] options:nil];
        
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:urlAsset];
        
        [self pausePlayer];
    
        [_player replaceCurrentItemWithPlayerItem:playerItem];
        
        _player.allowsExternalPlayback = YES;
        
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        
        NSString *title = [songObject.mediaItem valueForProperty:MPMediaItemPropertyTitle];
        
        if (title == nil)
        {
            title = @"";
        }
        
        NSString *artist = [songObject.mediaItem valueForProperty:MPMediaItemPropertyArtist];

        if (artist == nil)
        {
            artist = @"";
        }
        
        NSString *album = [songObject.mediaItem valueForProperty:MPMediaItemPropertyAlbumTitle];
        
        if (album == nil)
        {
            album = @"";
        }
        
        [songInfo setObject:title forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:artist forKey:MPMediaItemPropertyArtist];
        [songInfo setObject:album forKey:MPMediaItemPropertyAlbumTitle];
        [songInfo setObject:[songObject.mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration]  forKey:MPMediaItemPropertyPlaybackDuration];
        [songInfo setObject:@"1.0f" forKey:MPNowPlayingInfoPropertyPlaybackRate];
        [songInfo setObject:[NSNumber numberWithInteger:_indexOfPlaylistTrack] forKey:MPNowPlayingInfoPropertyPlaybackQueueIndex];
        [songInfo setObject:[NSNumber numberWithInteger:_mutablePlaylistArray.count] forKey:MPNowPlayingInfoPropertyPlaybackQueueCount];
        [songInfo setObject:[NSNumber numberWithFloat:0.0f] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        
        [_player seekToTime:CMTimeMakeWithSeconds(seekToTime, _player.currentTime.timescale)];
        
        if (playTrack)
        {
            [self playPlayer];
        }
        
        [self updatedCurrentTrack:songObject didReachEnd:didReachEnd];
        
        _isDirty = NO;
        _isLocked = NO;
    }
}

-(void) willBecomeActive
{
    CMTime interval = CMTimeMake(100, 1000);
    
    __weak PlaylistEngine *weakSelf = self;
    
    _playbackObserver =  [_player addPeriodicTimeObserverForInterval:interval queue:NULL usingBlock: ^(CMTime time)
                            {
                               if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
                               {
                                   CMTime endTime = CMTimeConvertScale (weakSelf.player.currentItem.asset.duration, weakSelf.player.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
                                   
                                   if (CMTimeCompare(endTime, kCMTimeZero) != 0)
                                   {
                                       double normalizedTime = (double) weakSelf.player.currentTime.value / (double) endTime.value;
                                       
                                       if ([weakSelf.delegate respondsToSelector:@selector(updateTimesWithScrubber:duration:currentTime:)])
                                       {
                                           [weakSelf.delegate updateTimesWithScrubber:normalizedTime duration:CMTimeGetSeconds(endTime) currentTime:CMTimeGetSeconds(weakSelf.player.currentTime)];
                                       }
                                   }
                               }
                            }];

}

-(void) willBackground
{
    [_player removeTimeObserver:_playbackObserver];
}

-(void) updatedCurrentTrack:(SongObject*)song didReachEnd:(BOOL)didReachEnd
{
    NSNumber *didReachEndNumber = [NSNumber numberWithBool:didReachEnd];
    
    NSDictionary *params = @{SONG_OBJECT : song,
                              SONG_INDEX : [NSNumber numberWithInteger: _indexOfPlaylistTrack],
                             REACHED_END : didReachEndNumber};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CURRENT_TRACK_UPDATE object:nil userInfo:params];
}

-(void) gotoNextTrack
{
    _isDirty = YES;
    
    _indexOfPlaylistTrack = _indexOfPlaylistTrack + 1;
    
    if (_indexOfPlaylistTrack >= _mutablePlaylistArray.count - 1)
    {
        _indexOfPlaylistTrack = _mutablePlaylistArray.count - 1;
    }
    
    [self setupPlayerWithQueueWithIndex:_indexOfPlaylistTrack didReachEnd:NO playTrack:_isPlaying withTime:0];
}

-(void) gotoPreviousTrack
{
    _isDirty = YES;
    
    _indexOfPlaylistTrack = _indexOfPlaylistTrack - 1;
    
    if (_indexOfPlaylistTrack <= 0)
    {
        _indexOfPlaylistTrack = 0;
    }
    
     //NSLog(@"gotoPreviousTrack _indexOfPlaylistTrack = %i", _indexOfPlaylistTrack);
    
    [self setupPlayerWithQueueWithIndex:_indexOfPlaylistTrack didReachEnd:NO playTrack:_isPlaying withTime:0];
}

-(void) playerItemDidReachEnd:(NSNotification*)note
{
//    NSLog(@"\n\nplayerItemDidReachEnd");
//    NSLog(@"_player.currentItem = %@", _player.currentItem);
//    NSLog(@"_indexOfPlaylistTrack = %i", _indexOfPlaylistTrack);
   // NSLog(@"_queueItems.count = %i", _queueItems.count);
    
    _isDirty = YES;
    
    if (_indexOfPlaylistTrack < _mutablePlaylistArray.count - 1 )
    {
        // Notify rest of App that the next track is playing
        _indexOfPlaylistTrack = _indexOfPlaylistTrack + 1;
        
        [self setupPlayerWithQueueWithIndex:_indexOfPlaylistTrack didReachEnd:YES playTrack:YES withTime:0];
    }
    else
    {
        _isPlaying = NO;
        [self updatedCurrentTrack:[_mutablePlaylistArray objectAtIndex:_indexOfPlaylistTrack] didReachEnd:NO];
    }
}

-(void) playPlayer
{
    if(_player)
    {
        [_player play];
        
        _isPlaying = YES;
        
        if (_IN_INSTRUCTIONAL_MODE)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION___INSTRUCTION_THIRD_STEP_COMPLETE object:nil];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PLAY_PAUSE_TOGGLE object:nil];
    }
}

-(void) pausePlayer
{
    if(_player)
    {
        [_player pause];
        
        _isPlaying = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PLAY_PAUSE_TOGGLE object:nil];
    }
}

-(void) addSong:(SongObject*)song
{
    for (SongObject *songObject in _mutablePlaylistArray)
    {
        if ([songObject.persistantID longLongValue] == [song.persistantID longLongValue])
        { 
            return;
        }
    }
    
    _isDirty = YES;
    
    song.isAdded = YES;
    
    [_mutablePlaylistArray addObject:song];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PLAYLIST_ARRAY_MODIFIED object:nil];
    
    if (_mutablePlaylistArray.count == 1) // Only one track...
    {
        _indexOfPlaylistTrack = 0;
        [self setupPlayerWithQueueWithIndex:_indexOfPlaylistTrack didReachEnd:NO playTrack:NO withTime:0];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TRACK_ADDED object:nil];
    
    if (_IN_INSTRUCTIONAL_MODE)
    {
        _INSTRUCTIONS_countTracks = _INSTRUCTIONS_countTracks + 1;
        
        if ((_INSTRUCTIONS_countTracks == 2 && _mutablePlaylistArray.count > 1) || (_INSTRUCTIONS_countTracks == 1 && _arraySongsOffDevice.count == 1))
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION___INSTRUCTION_FIRST_STEP_COMPLETE object:nil];
        }
    }
}

-(void) deleteSong:(SongObject*)song
{
    NSInteger indexOfDeletedSong =  [_mutablePlaylistArray indexOfObject:song];
    
    _isDirty = YES;
    
    if (indexOfDeletedSong < _indexOfPlaylistTrack)
    {
        _indexOfPlaylistTrack = _indexOfPlaylistTrack - 1;
    }
    
    [_mutablePlaylistArray removeObject:song];
    
    song.isAdded = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TRACK_DELETED object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PLAYLIST_ARRAY_MODIFIED object:nil];
    
    // Need to check if deleted track was current playing track.
    AVURLAsset *currentItemAsset = (AVURLAsset *)[_player.currentItem asset];
    AVURLAsset *deletedSongAsset = [[AVURLAsset alloc] initWithURL:[song.mediaItem valueForProperty:MPMediaItemPropertyAssetURL] options:nil];
    
    if ([currentItemAsset.URL isEqual:deletedSongAsset.URL])
    {
#warning What should happen when song is deleted?
        [_player pause];
    }
    
    if (_mutablePlaylistArray.count == 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PLAYER_IS_EMPTY object:nil];
        _indexOfPlaylistTrack = -1;
    }
}

-(void) playSong:(SongObject*)song withIndex:(NSInteger)index
{
    _indexOfPlaylistTrack = index;
    _isDirty = YES;
    [self setupPlayerWithQueueWithIndex:_indexOfPlaylistTrack didReachEnd:NO playTrack:YES withTime:0];
}

-(void) seekToTime:(double)percent
{
    [_player pause];
    
    CMTime endTime = CMTimeConvertScale (_player.currentItem.asset.duration, _player.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
    double seekedTime = percent *  CMTimeGetSeconds(endTime);

    [_player seekToTime:CMTimeMakeWithSeconds(seekedTime, _player.currentTime.timescale)];
}

-(void) playPauseToggle
{
    if (_isPlaying)
    {
         [self pausePlayer];
    }
    else
    {
        [self playPlayer];
    }
}

-(void) clearPlaylist
{
    if (_isPlaying)
    {
        [self pausePlayer];
    }
    
    NSArray *tempArray = [_mutablePlaylistArray copy];
    
    for (SongObject *song in tempArray)
    {
        [self deleteSong:song];
    }
}

-(void) stopForInterruption
{
    if (_isPlaying)
    {
        [self pausePlayer];
        _wasInterruptedPlaying = YES;
    }
}

-(void) playForInterruption
{
    if (_wasInterruptedPlaying)
    {
        [self playPlayer];
        _wasInterruptedPlaying = NO;
    }
}

-(void) fromSavedPlaylistCurrentTrackIndex:(NSUInteger)currentTrackIndex currentTime:(double)currentTime
{
    _isDirty = YES;
    _indexOfPlaylistTrack = currentTrackIndex;
    [self setupPlayerWithQueueWithIndex:_indexOfPlaylistTrack didReachEnd:NO playTrack:NO withTime:currentTime];
}

-(double) getCurrentTrackTime
{
    if (_player)
    {
        return CMTimeGetSeconds(_player.currentTime);
    }
    else
    {
        return 0;
    }
}

@end
