//
//  PlaylistViewController.m
//  Listen
//
//  Created by David Hovey on 12/04/2012.
//  Copyright (c) 2012 14lox. All rights reserved.
//

#import "PlaylistViewController.h"
#import "PlaylistTableCell.h"
#import "ListenNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import "PlaylistEngine.h"
#import "PlaylistTableCell.h"
#import "NSMutableArray+Shuffle.h"
#import "BVReorderTableView.h"
#import "ClearPlaylistViewController.h"
#import "EmptyPlaylistCell.h"
#import "PlaylistHiddenButtonsView.h"

@interface PlaylistViewController () <PlaylistEngineDelegate, PlaylistCellDeleteSongProtocol, PlaylistHiddenButtonsDelegate>

@property (nonatomic, strong) UIView *popupBackground;
@property (nonatomic, strong) UITableViewController *tableViewController;
@property (nonatomic, strong) PlaylistHiddenButtonsView *playlistHiddenButtonsView;
@property (nonatomic) BOOL hiddenButtonsShowed;

@end

@implementation PlaylistViewController

+ (PlaylistViewController *)shared
{
    static dispatch_once_t onceToken;
    static PlaylistViewController *instance;
    dispatch_once(&onceToken, ^{ instance = [[[self class] alloc] init]; });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.view.backgroundColor =  UIColorFromRGB(0x000000);
        
        BVReorderTableView *reorderTableView = [[BVReorderTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        
        _tableViewController = [[UITableViewController alloc] init];
        
        _tableViewController.tableView = reorderTableView;

        _tableViewController.tableView.dataSource = self;
        _tableViewController.tableView.delegate = self;
        _tableViewController.view.backgroundColor = UIColorFromRGB(0x000000);
        _tableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableViewController.clearsSelectionOnViewWillAppear = NO;

        [_tableViewController.tableView setContentInset:UIEdgeInsetsMake(TOP_NAVIGATION_HEIGHT,0,PLAYER_HEIGHT,0)];
        
        [self.view addSubview:_tableViewController.tableView];

        _tableViewController.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        _tableViewController.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(TOP_NAVIGATION_HEIGHT,0,PLAYER_HEIGHT,0);
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        tapGesture.numberOfTapsRequired = 1;
        [_tableViewController.tableView addGestureRecognizer:tapGesture];
        
        _playlistHiddenButtonsView = [[PlaylistHiddenButtonsView alloc] initWithFrame:CGRectMake(0, TOP_NAVIGATION_HEIGHT, self.view.frame.size.width, 55)];
        _playlistHiddenButtonsView.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentTrackUpdatedWithIndex:) name:NOTIFICATION_CURRENT_TRACK_UPDATE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToTop) name:NOTIFICATION_SCROLL_TABLE_TO_TOP object:nil];
    }
    return self;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

-(void) clearPlaylist
{
    ClearPlaylistViewController *clearPlaylistViewController = [[ClearPlaylistViewController alloc] init];
    [self.parentViewController.view.superview  addSubview:clearPlaylistViewController.view];
    
    [[PlaylistEngine shared] clearPlaylist];
    [_tableViewController.tableView reloadData];
    
    [clearPlaylistViewController.view removeFromSuperview];
    
     [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOW_SEARCHTABLE object:nil userInfo:nil];
}

-(void) shufflePlaylist
{
    if ([PlaylistEngine shared].mutablePlaylistArray.count > 0)
    {
        [_tableViewController.tableView beginUpdates];
        
        // Move Playing track to the top.
        
        SongObject *currentSong = [[PlaylistEngine shared].mutablePlaylistArray objectAtIndex:[PlaylistEngine shared].indexOfPlaylistTrack];
        
       //  NSLog(@"current song = %@", currentSong);
        
        [[PlaylistEngine shared].mutablePlaylistArray removeObjectAtIndex:[PlaylistEngine shared].indexOfPlaylistTrack];
        
       //  NSLog(@"[PlaylistEngine shared].mutablePlaylistArray = %@", [PlaylistEngine shared].mutablePlaylistArray);
        
        [[PlaylistEngine shared].mutablePlaylistArray shuffle];
        
        //NSLog(@"[PlaylistEngine shared].mutablePlaylistArray = %@", [PlaylistEngine shared].mutablePlaylistArray);
        
        NSMutableArray *indexArray = [[NSMutableArray alloc] initWithCapacity:[PlaylistEngine shared].mutablePlaylistArray.count];
        
        NSInteger i = 0;
        for (SongObject *songs in [PlaylistEngine shared].mutablePlaylistArray)
        {
            [indexArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            i = i + 1;
        }
        
        [_tableViewController.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [[PlaylistEngine shared].mutablePlaylistArray insertObject:currentSong atIndex:0];
    
        [_tableViewController.tableView endUpdates];
        
        [_tableViewController.tableView reloadData];
        
        [PlaylistEngine shared].indexOfPlaylistTrack = 0;

        [_tableViewController.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}

-(void) dealloc
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _tableViewController.tableView.delegate = self;
    
    [_tableViewController.tableView reloadData];

    [_tableViewController.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[PlaylistEngine shared].indexOfPlaylistTrack inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    [_tableViewController.tableView setContentInset:UIEdgeInsetsMake(TOP_NAVIGATION_HEIGHT,0,PLAYER_HEIGHT,0)];
    
    if ([PlaylistEngine shared].IN_INSTRUCTIONAL_MODE)
        _tableViewController.tableView.scrollEnabled = NO;
    else
        _tableViewController.tableView.scrollEnabled = YES;

}

#warning Need a delegate method fired from PlayerView when closed, to trigger reloadData

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return ([PlaylistEngine shared].mutablePlaylistArray.count  == 0) ? (self.view.frame.size.height - 100) : CELL_HEIGHT;
    return CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return ([PlaylistEngine shared].mutablePlaylistArray.count  == 0) ? 1 : [PlaylistEngine shared].mutablePlaylistArray.count;
    return [PlaylistEngine shared].mutablePlaylistArray.count;
}

// BVReorderTableView.h

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[PlaylistEngine shared].mutablePlaylistArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// This method is called when starting the re-ording process. You insert a blank row object into your
// data source and return the object you want to save for later. This method is only called once.
- (id)saveObjectAndInsertBlankRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [[PlaylistEngine shared].mutablePlaylistArray objectAtIndex:indexPath.row];
    
    if (indexPath.row == [PlaylistEngine shared].indexOfPlaylistTrack)
        [[PlaylistEngine shared].mutablePlaylistArray replaceObjectAtIndex:indexPath.row withObject:REORDER_CURRENT_TRACK];
    else
        [[PlaylistEngine shared].mutablePlaylistArray replaceObjectAtIndex:indexPath.row withObject:REORDER_DUMMY_TRACK];
    
    return object;
}

// This method is called when the selected row is dragged to a new position. You simply update your
// data source to reflect that the rows have switched places. This can be called multiple times
// during the reordering process.
- (void)moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    id object = [[PlaylistEngine shared].mutablePlaylistArray objectAtIndex:fromIndexPath.row];
    
    [[PlaylistEngine shared].mutablePlaylistArray removeObjectAtIndex:fromIndexPath.row];
    [[PlaylistEngine shared].mutablePlaylistArray insertObject:object atIndex:toIndexPath.row];
    
    if ([PlaylistEngine shared].indexOfPlaylistTrack == fromIndexPath.row)
    {
        [PlaylistEngine shared].indexOfPlaylistTrack = toIndexPath.row;
    }
    else if ([PlaylistEngine shared].indexOfPlaylistTrack == toIndexPath.row)
    {
        [PlaylistEngine shared].indexOfPlaylistTrack = fromIndexPath.row;
    }
}

// This method is called when the selected row is released to its new position. The object is the same
// object you returned in saveObjectAndInsertBlankRowAtIndexPath:. Simply update the data source so the
// object is in its new position. You should do any saving/cleanup here.
- (void)finishReorderingWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath;
{
    [[PlaylistEngine shared].mutablePlaylistArray replaceObjectAtIndex:indexPath.row withObject:object];
    // do any additional cleanup here
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Empty playlist message
    
//    if ([PlaylistEngine shared].mutablePlaylistArray.count == 0)
//    {
//        
//        NSString *cellIdentifier = @"EmptyCell";
//        EmptyPlaylistCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//        
//        if (!cell)
//        {
//            cell = [[EmptyPlaylistCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//        }
//        
//        cell.contentView.backgroundColor = [UIColor clearColor];
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        return cell;
//    }
    
    NSString *cellIdentifier = @"PlaylistCell";
    PlaylistTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
    if (!cell)
    {
        cell = [[PlaylistTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    if ([[[PlaylistEngine shared].mutablePlaylistArray objectAtIndex:indexPath.row] isKindOfClass:[NSString class]] &&
        [[[PlaylistEngine shared].mutablePlaylistArray objectAtIndex:indexPath.row] isEqualToString:REORDER_DUMMY_TRACK])
    {
        cell.songLabel.text = @"";
        cell.artistAlbumLabel.text = @"";
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.isCurrentTrack = NO;
    }
    else if ([[[PlaylistEngine shared].mutablePlaylistArray objectAtIndex:indexPath.row] isKindOfClass:[NSString class]] &&
        [[[PlaylistEngine shared].mutablePlaylistArray objectAtIndex:indexPath.row] isEqualToString:REORDER_CURRENT_TRACK])
    {
        cell.songLabel.text = @"";
        cell.artistAlbumLabel.text = @"";
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.isCurrentTrack = YES;
    }
    else
    {
        SongObject *songObject = [[PlaylistEngine shared].mutablePlaylistArray objectAtIndex:indexPath.row];
        
        NSString *titleName = (NSString*)[songObject.mediaItem valueForProperty: MPMediaItemPropertyTitle];
        if (titleName.length == 0 || !titleName) titleName = @"";
        
        NSString *artistName = [songObject.mediaItem valueForProperty: MPMediaItemPropertyArtist];
        if (artistName.length == 0 || !artistName) artistName = @"";
        
        NSString *albumName = [songObject.mediaItem valueForProperty: MPMediaItemPropertyAlbumTitle];
        if (albumName.length == 0 || !albumName) albumName = @"";
        
        cell.songLabel.text = titleName;
        cell.artistAlbumLabel.text = [NSString stringWithFormat:@"%@ \u2014 %@", artistName ,albumName ];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == [PlaylistEngine shared].indexOfPlaylistTrack)
        {
            cell.isCurrentTrack = YES;
        }
        else
        {
            cell.isCurrentTrack = NO;
        }
    }

    return cell;
}

-(void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint tapLocation = [gestureRecognizer locationInView:_tableViewController.tableView];
        NSIndexPath *indexPath = [_tableViewController.tableView indexPathForRowAtPoint:tapLocation];
        [_tableViewController.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self tableView:_tableViewController.tableView didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath)
    {
        [self removeHiddenButtonsWithAnimation:NO];
        
        PlaylistTableCell *cell = (PlaylistTableCell*)[_tableViewController.tableView cellForRowAtIndexPath:indexPath];
        
        cell.isCurrentTrack = YES;
        
        if (indexPath.row == [PlaylistEngine shared].indexOfPlaylistTrack)
        {
            [[PlaylistEngine shared] playPauseToggle];
        }
        else
        {
            SongObject *songObject = [[PlaylistEngine shared].mutablePlaylistArray objectAtIndex:indexPath.row];
            [[PlaylistEngine shared] playSong:songObject withIndex:indexPath.row];
        }
    }
}

#pragma mark Playlist Workings

-(void)songDeletedWithCell:(PlaylistTableCell*)cell
{
    [self removeHiddenButtonsWithAnimation:YES];
    
    [_tableViewController.tableView beginUpdates];
    
    NSIndexPath *indx = [_tableViewController.tableView indexPathForCell:cell];
    SongObject *songObject = [[PlaylistEngine shared].mutablePlaylistArray objectAtIndex:indx.row];
    
    if (songObject)
    {
        [[PlaylistEngine shared] deleteSong:songObject];
        [_tableViewController.tableView deleteRowsAtIndexPaths:@[indx] withRowAnimation:UITableViewRowAnimationTop];
    }
    
    [_tableViewController.tableView endUpdates];
}

-(void) currentTrackUpdatedWithIndex:(NSNotification*)note
{
    NSDictionary *dict = note.userInfo;
    NSNumber *indx = [dict objectForKey:SONG_INDEX];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[indx integerValue]  inSection:0];
    
    [_tableViewController.tableView reloadData];
    
    if ([PlaylistEngine shared].mutablePlaylistArray.count > 1) // Crashes if just one item in playlist
        [_tableViewController.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{

}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SCROLL_START object:nil];
    
    [self removeHiddenButtonsWithAnimation:YES];
}

-(void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView.contentOffset.y <= -100.0f)
    {
    	[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		scrollView.contentInset = UIEdgeInsetsMake(100.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
        
        _playlistHiddenButtonsView.alpha = 0;
        
        [UIView animateWithDuration:0.3 animations:^{
            _playlistHiddenButtonsView.alpha = 1;
        } completion:^(BOOL finished) {
            [self.view addSubview: _playlistHiddenButtonsView];
            _hiddenButtonsShowed = YES;
        }];
	}
    
    // userInfo Hack to get delay happening - why?
    [[NSNotificationCenter defaultCenter] postNotificationName:SCROLL_END object:nil userInfo:@{@"": @""}];
}

-(void) removeHiddenButtonsWithAnimation:(BOOL)animate
{
    if (_hiddenButtonsShowed)
    {
        [UIView animateWithDuration:0.15 animations:^{
            _playlistHiddenButtonsView.alpha = 0;
        } completion:^(BOOL finished) {
            [_playlistHiddenButtonsView removeFromSuperview];
            _hiddenButtonsShowed = NO;
        }];
        
        if (animate)
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
           [_tableViewController.tableView setContentInset:UIEdgeInsetsMake(TOP_NAVIGATION_HEIGHT,0,PLAYER_HEIGHT,0)];
            [UIView commitAnimations];
        }
        else
        {
           [_tableViewController.tableView setContentInset:UIEdgeInsetsMake(TOP_NAVIGATION_HEIGHT,0,PLAYER_HEIGHT,0)];
        }
    }
}

#pragma mark - HiddenButtonDelegate

-(void) clearButtonPressed
{
    [self clearPlaylist];
    [self removeHiddenButtonsWithAnimation:YES];
}

-(void) shuffleButtonPressed
{
    [self shufflePlaylist];
    [self removeHiddenButtonsWithAnimation:YES];
}

#pragma mark -

-(void) scrollToTop
{
    if ([self.tableViewController.tableView numberOfRowsInSection:0] > 0)
        [self.tableViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

@end
