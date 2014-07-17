//
//  ListenAppDelegate.m
//  Listen
//
//  Created by David Hovey on 12/04/2012.
//  Copyright (c) 2012 14lox. All rights reserved.
//

#import "ListenAppDelegate.h"
#import "ListenNavigationController.h"
#import "SearchViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "PlaylistEngine.h"

#define PLAYLISTITEMS @"playlistItems"

@interface ListenAppDelegate ()

@property (nonatomic, strong) ListenNavigationController *navigationController;

@end

@implementation ListenAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.window.backgroundColor = [UIColor blackColor];
    
    _navigationController = [[ListenNavigationController alloc] init];
    self.window.rootViewController = _navigationController;
    [self.window makeKeyAndVisible];
    
#pragma mark AVAudioSession
    
    NSError *sessionError = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    //  AVAudioSessionInterruptionOptionShouldResume
    [[AVAudioSession sharedInstance] setActive:YES error:&activationErr];
    
    @try
    {
        NSError *error = nil;
        
        // Configure the audio session
        AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
        
        // our default category -- we change this for conversion and playback appropriately
        [sessionInstance setCategory:AVAudioSessionCategoryPlayback error:&error];
        // XThrowIfError(error.code, "couldn't set audio category");
        
        NSTimeInterval bufferDuration = .005;
        [sessionInstance setPreferredIOBufferDuration:bufferDuration error:&error];
        // XThrowIfError(error.code, "couldn't set IOBufferDuration");
        
        double hwSampleRate = 44100.0;
        [sessionInstance setPreferredSampleRate:hwSampleRate error:&error];
        // XThrowIfError(error.code, "couldn't set preferred sample rate");
        
        // add interruption handler
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleInterruption:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:sessionInstance];
        
        // we don't do anything special in the route change notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRouteChange:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:sessionInstance];
        
        // activate the audio session
        [sessionInstance setActive:YES error:&error];
        // XThrowIfError(error.code, "couldn't set audio session active\n");
        
        // just print out the sample rate
        printf("Hardware Sample Rate: %.1f Hz\n", sessionInstance.sampleRate);
    }
    @catch (NSException * e)
    {
        NSLog(@"MASSIVE ERROR");
        printf("You probably want to fix this before continuing!");
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMediaLibraryDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         NSLog(@"library changed! note = %@", note);
         
         
     }];
    
    [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
    
     NSLog(@"library last modified %@", [[MPMediaLibrary defaultMediaLibrary] lastModifiedDate]);
    
    /*
     
     http://www.apeth.com/iOSBook/ch29.html
     
     One of the properties of an MPMediaEntity is its persistent ID, which uniquely identifies this song (MPMediaItemPropertyPersistentID) or playlist (MPMediaPlaylistPropertyPersistentID). No other means of identification is guaranteed unique; two songs or two playlists can have the same title, for example. Using the persistent ID, you can retrieve again at a later time the same song or playlist you retrieved earlier, even across launches of your app. All sorts of things have persistent IDs — entities in general (MPMediaEntityPropertyPersistentID), albums, artists, composers, and more.
     
     While you are maintaining the results of a search, the contents of the music library may themselves change. For example, the user might connect the device to a computer and add or delete music with iTunes. This can put your results out of date. For this reason, the library’s own modified state is available through the MPMediaLibrary class. Call the class method defaultMediaLibrary to get the actual library instance; now you can ask it for its lastModifiedDate. You can also register to receive a notification, MPMediaLibraryDidChangeNotification, when the music library is modified; this notification is not emitted unless you first send the library beginGeneratingLibraryChangeNotifications. You should eventually balance this with endGeneratingLibraryChangeNotifications.
     
     New in iOS 6, a song has a property MPMediaItemPropertyIsCloudItem, allowing you to ask whether it lives in the cloud (thanks to iTunes Match) or on the device. The distinction is clearer in than it was in iOS 5, because a song can now be played from the cloud without downloading it, and the user can manually download a song from the cloud or delete it from the device. Such changes in a song’s cloud status do not count as a change in the library.
     
     */
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(beginReceivingRemoteControlEvents)])
    {
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self becomeFirstResponder];
    }
    [self getSavedPlaylist];
    
    
#if TARGET_IPHONE_SIMULATOR
    
    [[[UIAlertView alloc] initWithTitle:@"Nope" message:@"This wont work on the Simulator. \nWe can't access any music. \nRun on a device with music." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    
#endif
        
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)theEvent
{
    if (theEvent.type == UIEventTypeRemoteControl)
    {
        switch(theEvent.subtype)
        {
            case UIEventSubtypeRemoteControlTogglePlayPause:
            {
                [[PlaylistEngine shared] playPauseToggle];
            }
            break;
            
            case UIEventSubtypeRemoteControlPlay:
            {
                [[PlaylistEngine shared] playPlayer];
            }
            break;
            
            case UIEventSubtypeRemoteControlPause:
            {
                [[PlaylistEngine shared] pausePlayer];
            }
            break;
            
            case UIEventSubtypeRemoteControlStop:
            {
                [[PlaylistEngine shared] pausePlayer];
            }
            break;
            
            case UIEventSubtypeRemoteControlNextTrack:
            {
                 NSLog(@"_navigationController.isPlayerOpen = %i", _navigationController.isPlayerOpen);
                
                if (_navigationController.isPlayerOpen)
                {
                    [_navigationController.playerViewController.largePlayerView playNextTrackFromControlPanel];
                }
                else
                {
                    [[PlaylistEngine shared] gotoNextTrack];
                }
            }
            break;
            case UIEventSubtypeRemoteControlPreviousTrack:
            {
                NSLog(@"_navigationController.isPlayerOpen = %i", _navigationController.isPlayerOpen);
                
                if (_navigationController.isPlayerOpen)
                {
                    [_navigationController.playerViewController.largePlayerView playPreviousTrackFromControlPanel];
                }
                else
                {
                    [[PlaylistEngine shared] gotoPreviousTrack];
                }
            }
            break;
            default:
                return;
        }
    }
}

#pragma mark -Audio Session Interruption Notification

- (void)handleInterruption:(NSNotification *)notification
{
    UInt8 theInterruptionType = [[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] intValue];
    
    NSLog(@"Session interrupted > --- %s ---\n", theInterruptionType == AVAudioSessionInterruptionTypeBegan ? "Begin Interruption" : "End Interruption");
    
    if (theInterruptionType == AVAudioSessionInterruptionTypeBegan)
    {
        [[PlaylistEngine shared] stopForInterruption];
    }
    else if (theInterruptionType == AVAudioSessionInterruptionTypeEnded)
    {
        // make sure to activate the session
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        
        [[PlaylistEngine shared] playForInterruption];
        
        if (nil != error) NSLog(@"AVAudioSession set active failed with error: %@", error);
    }
}

#pragma mark -Audio Session Route Change Notification

- (void)handleRouteChange:(NSNotification *)notification
{
    UInt8 reasonValue = [[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] intValue];
    AVAudioSessionRouteDescription *routeDescription = [notification.userInfo valueForKey:AVAudioSessionRouteChangePreviousRouteKey];
    
    NSLog(@"Route change:");
    switch (reasonValue) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"     NewDeviceAvailable");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"     OldDeviceUnavailable");
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            NSLog(@"     CategoryChange");
            NSLog(@" New Category: %@", [[AVAudioSession sharedInstance] category]);
            break;
        case AVAudioSessionRouteChangeReasonOverride:
            NSLog(@"     Override");
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            NSLog(@"     WakeFromSleep");
            break;
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            NSLog(@"     NoSuitableRouteForCategory");
            break;
        default:
            NSLog(@"     ReasonUnknown");
    }
    
    NSLog(@"Previous route:\n");
    NSLog(@"%@", routeDescription);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
    
    [[PlaylistEngine shared] willBackground];
    
    [_navigationController.playerViewController.smallPlayerView willBackground];
    
    [self savePlaylist];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
    
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
    
    [[PlaylistEngine shared] willBecomeActive];
    
    [_navigationController.playerViewController.smallPlayerView nowActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
    
    [self savePlaylist];
}

-(void) savePlaylist
{
    // Process playlist - stripping out persistantIDs from playlistarray
    
    NSMutableArray *trackPersistantIDArray = [[NSMutableArray alloc] initWithCapacity:[PlaylistEngine shared].mutablePlaylistArray.count];

    for (SongObject *song in [PlaylistEngine shared].mutablePlaylistArray)
    {
        unsigned long long persistantID = [[song.mediaItem valueForProperty:MPMediaItemPropertyPersistentID] unsignedLongLongValue];
        [trackPersistantIDArray addObject:[NSNumber numberWithLongLong:persistantID]];
    }
    
    // Get current track and time;
    
    unsigned long long currentTrackID = 0;
    
    double currentTrackTime = 0;
    
    if ([PlaylistEngine shared].mutablePlaylistArray.count > 0)
    {
        SongObject *currentTrack = [[PlaylistEngine shared].mutablePlaylistArray objectAtIndex: [PlaylistEngine shared].indexOfPlaylistTrack];
       
        currentTrackID = [[currentTrack.mediaItem valueForProperty:MPMediaItemPropertyPersistentID] longLongValue];
        
        currentTrackTime = [[PlaylistEngine shared] getCurrentTrackTime];
    }
    
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"userPlaylists.plist"];
    
    NSDictionary *plistDict = @{ @"playlists" :
                                                @[
                                                    @{
                                                        SAVE_NAME: @"OG playlist",
                                                        SAVE_TRACKS: trackPersistantIDArray,
                                                        SAVE_MODIFIED: [NSDate date],
                                                        SAVE_CURRENT_TRACK: [NSNumber numberWithLongLong:currentTrackID],
                                                        SAVE_CURRENT_TRACK_TIME: [NSNumber numberWithDouble:currentTrackTime]
                                                    }
                                                 ]
                                };
    
     NSLog(@"plistDict = %@", plistDict);
    
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    if(plistData)
    {
        [plistData writeToFile:plistPath atomically:YES];
    }
    else
    {
         NSLog(@"savePlaylist error = %@", error);
    }
}

-(void) getSavedPlaylist
{
    // Read plist
    
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"userPlaylists.plist"];
   
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        plistPath = [[NSBundle mainBundle] pathForResource:@"userPlaylists" ofType:@"plist"];
    }
    
    NSData *plistData = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    
    NSDictionary *plistContents = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistData
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:&format
                                          errorDescription:&errorDesc];
    if (!plistContents)
    {
        NSLog(@"Error reading plist: %@, format: %lu", errorDesc, format);
    }
    
    // Populate playlist with saved content
    NSArray *playlistRoot = [plistContents objectForKey:@"playlists"];

    NSDictionary *playlistDictionary = playlistRoot[0];  //objectForKey:SAVE_TRACKS];

    // NSLog(@"playlistDictionary = %@", playlistDictionary);

    NSUInteger indexCount = 0;
    NSUInteger currentTrackIndex;
    
   //  NSLog(@"[PlaylistEngine shared] arraySongsOffDevice = %@", [[PlaylistEngine shared] arraySongsOffDevice][0]);
    
    NSArray *tracksArray = [playlistDictionary objectForKey:SAVE_TRACKS];
    
    for (NSNumber *persitantID in tracksArray)
    {
//         NSLog(@"[[playlistDictionary objectForKey:SAVE_CURRENT_TRACK] longLongValue] = %lld", [[playlistDictionary objectForKey:SAVE_CURRENT_TRACK] longLongValue]);
//         NSLog(@"[persitantID longLongValue] = %lld", [persitantID longLongValue]);
//        
        if ([[playlistDictionary objectForKey:SAVE_CURRENT_TRACK] unsignedLongLongValue] == [persitantID unsignedLongLongValue])
        {
            currentTrackIndex = indexCount;
        }
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"persistantID == [cd] %@", persitantID];
        
        NSArray * filteredarray  = [[[PlaylistEngine shared] arraySongsOffDevice] filteredArrayUsingPredicate:predicate];
        
        if (filteredarray.count > 0)
        {
            [[PlaylistEngine shared] addSong:filteredarray[0]];
            
            indexCount = indexCount + 1;
        }
    }
    
    if ([PlaylistEngine shared].mutablePlaylistArray.count > 0)
    {
        double currentTime = [[playlistDictionary objectForKey:SAVE_CURRENT_TRACK_TIME] doubleValue];
        
        [[PlaylistEngine shared] fromSavedPlaylistCurrentTrackIndex:currentTrackIndex currentTime:currentTime];
        
        [[SearchViewController shared] savedPlaylistAdded];
    }
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionInterruptionNotification
                                                  object:[AVAudioSession sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionRouteChangeNotification
                                                  object:[AVAudioSession sharedInstance]];
}

@end
