//
//  SearchViewController.m
//  Listen
//
//  Created by David Hovey on 12/04/2012.
//  Copyright (c) 2012 14lox. All rights reserved.
//

#import "SearchViewController.h"
#import "PlaylistViewController.h"
#import "ListenNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchTableCell.h"
#import "SongObject.h"
#import "AlbumObject.h"
#import "PlaylistEngine.h"
#import "SearchEngine.h"
#import "UIFont+ListenFont.h"

@interface SearchViewController () < UIAlertViewDelegate, SearchCellAddSongProtocol>

@property (nonatomic, strong) id grabbedObject;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic) BOOL allSongsShowing; // This is a flag for when all the songs are showing - either on load or no search term.
@property (nonatomic, strong) MPMediaPropertyPredicate* justMusicPredicate;
@property (nonatomic) __block BOOL isProcessing;
@property (nonatomic, strong) __block NSMutableArray *arrayOfArtistItems;
@end

@implementation SearchViewController

+ (SearchViewController *)shared
{
    static dispatch_once_t onceToken;
    static SearchViewController *instance;
    dispatch_once(&onceToken, ^ { instance = [[[self class] alloc] init]; });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = UIColorFromRGB(0x000000);
        _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(TOP_NAVIGATION_HEIGHT,0, PLAYER_HEIGHT,0);
        
        [self.view addSubview:self.tableView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToTop) name:NOTIFICATION_SCROLL_TABLE_TO_TOP object:nil];
        
    }
    return self;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

-(void) loadView
{
    [super loadView];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextFieldDidChange:) name:@"navSearchTextFieldChangedNotification" object:nil];
    
    __weak SearchViewController *weakSelf = self;
    
    [[SearchEngine shared] displayAllTracksWithCallback:^
     {
         weakSelf.allSongsShowing = YES;

         [weakSelf.tableView reloadData];
     }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(TOP_NAVIGATION_HEIGHT,0,PLAYER_HEIGHT,0)];
    
    [self.tableView reloadData];
    
    if ([PlaylistEngine shared].IN_INSTRUCTIONAL_MODE)
        _tableView.scrollEnabled = NO;
    else
        _tableView.scrollEnabled = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorFromRGB(0x000000);
}

-(void) searchTextFieldDidChange:(NSNotification *)notif
{
    NSLog(@"\n\n*****************************************************\n\n");
    
    UITextField *txt = (UITextField*)notif.object;
    
    NSString *textString = txt.text;
    // NSString *textString = @"tallest"; //txt.text;
    
    NSLog(@"textString  = %@", textString);
    
    __weak SearchViewController *weakSelf = self;
    
    if (textString.length == 0)
    {
        [[SearchEngine shared] clearSearchArraysCallback:^
         {
             weakSelf.allSongsShowing = YES;
             
             [weakSelf.tableView reloadData];
             
             if ([weakSelf.tableView numberOfRowsInSection:0] > 0)
             {
                 [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
             }
         }];
    }
    else
    {
        if (![SearchEngine shared].isProcessingSearch)
        {
            [[SearchEngine shared] searchWithString:textString callback:^
             {
                 weakSelf.allSongsShowing = NO;
                 
                 [weakSelf.tableView reloadData];
                 
                 if ([weakSelf.tableView numberOfRowsInSection:0] > 0)
                     [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
             }];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_allSongsShowing)
    {
        if (section == 0)
        {
            return [PlaylistEngine shared].arraySongsOffDevice.count;
        }
        else if (section == 1)
        {
            return 0;
        }
    }
    else
    {
        if (section == 0)
        {
           if ([[PlaylistEngine shared].arrayAlbums count] > 0)
           {
                return [PlaylistEngine shared].arrayAlbums.count;
           }
            else
            {
                return [PlaylistEngine shared].arraySearchTracks.count;
            }
        }
        else if (section == 1)
        {
            return [PlaylistEngine shared].arraySearchTracks.count;
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    if(_allSongsShowing)
        return 0;
    else
        if (section == 0)
        {
          if ([[PlaylistEngine shared].arrayAlbums count] > 0)
          {
              return SEARCH_HEADER_CELL_HEIGHT;
          }
          else if ([[PlaylistEngine shared].arraySearchTracks count] > 0)
          {
              return SEARCH_HEADER_CELL_HEIGHT;
          }
          else
          {
              return 0;
          }
            
        }
        else if (section == 1)
        {
            if ([PlaylistEngine shared].arraySearchTracks.count > 0)
            {
                return SEARCH_HEADER_CELL_HEIGHT;
            }
            else
            {
                return 0;
            }
        }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(_allSongsShowing)
    {
        return nil;
    }
    else
    {
        NSString *headerString;
      
        if (section == 0)
        {
            if ([[PlaylistEngine shared].arrayAlbums count] > 0)
            {
                headerString = @"Album";
            }
            else if ([[PlaylistEngine shared].arraySearchTracks count] > 0)
            {
                headerString = @"Track";
            }
            else
            {
                return nil;
            }
        }
        else if (section == 1)
        {
            if ([[PlaylistEngine shared].arraySearchTracks count] > 0)
            {
                headerString = @"Track";
            }
            else
            {
                return nil;
            }
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(7, 0, self.view.frame.size.width, SEARCH_HEADER_CELL_HEIGHT)];
        label.backgroundColor = [UIColor clearColor];
        
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:headerString];
        [string addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(RED_COLOUR) range:NSMakeRange(0,headerString.length)];
        [string addAttribute:NSFontAttributeName value:[UIFont lightListenFontOfSize:21] range:NSMakeRange(0,headerString.length)];
        [string addAttribute:NSKernAttributeName value:[NSNumber numberWithFloat:-0.5f] range:NSMakeRange(0,headerString.length)];
    
        label.attributedText = string;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SEARCH_HEADER_CELL_HEIGHT)];
        headerView.backgroundColor = UIColorFromRGB(0x000000);
        [headerView addSubview:label];
        return headerView;
    }
    
    return nil;
}

- (UITableViewCell *) cellSongWithIndexPath:(NSIndexPath*)indexPath andTableView:(UITableView*)tableView
{
    NSString *cellIdentifier = @"SongCell";
    SearchTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[SearchTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    [cell.contentView setBackgroundColor:[UIColor blackColor]];
    
    SongObject *songObject;
    
    if ([PlaylistEngine shared].arraySearchTracks.count > 0 || [PlaylistEngine shared].arraySongsOffDevice.count > 0)
    {
       if (!_allSongsShowing)
       {
           songObject  = [[PlaylistEngine shared].arraySearchTracks objectAtIndex:indexPath.row];
       }
       else
       {
           songObject = [[PlaylistEngine shared].arraySongsOffDevice objectAtIndex:indexPath.row];
       }
        
        NSString *title = songObject.title;
        NSString *artist = songObject.artist;
        NSString *albumTitle = songObject.album;
        
        if (title == nil || title.length == 0)
        {
            title = @"";
        }
        
        if (albumTitle == nil || albumTitle.length == 0)
        {
            albumTitle = @"";
        }
        if (artist == nil || artist.length == 0)
        {
            artist = @"";
        }
 
        cell.songLabel.text = title;
        cell.artistAlbumLabel.text = [NSString stringWithFormat:@"%@ \u2014 %@", artist, albumTitle];
        cell.cellType = TrackCellType;
        cell.delegate = self;
        cell.isCloud = songObject.isCloudItem;
        cell.isAdded = songObject.isAdded;
        
        // Remove gesture? - put in tableviewcontroller.tableview?
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleSingleTap:)];
        [cell.textScrollView addGestureRecognizer:tapGesture];
        cell.selectionStyle = UITableViewCellSelectionStyleNone; 
    }
    else
    {
        NSLog(@"Error");
    }

    return cell;
}

- (UITableViewCell *) cellAlbumWithIndexPath:(NSIndexPath*)indexPath andTableView:(UITableView*)tableView
{
    NSString *cellIdentifier = @"AlbumCell";
    
    SearchTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[SearchTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    [cell.contentView setBackgroundColor:[UIColor blackColor]];
    
    if ([PlaylistEngine shared].arrayAlbums.count > 0)
    {
       // Need to see if its a Album or a song.
        
        if ([[[PlaylistEngine shared].arrayAlbums objectAtIndex:indexPath.row] isKindOfClass:[AlbumObject class]])
        {
            AlbumObject *albumObject = [[PlaylistEngine shared].arrayAlbums objectAtIndex:indexPath.row];
            
            NSString *albumName = albumObject.album;
            
            if (albumName == nil || albumName.length == 0)
            {
                albumName = @"";
            }
            
            NSString *artistName = albumObject.artist;
            
            if (artistName == nil || artistName.length == 0)
            {
                artistName = @"";
            }
            
            cell.songLabel.text = albumName;
            cell.artistAlbumLabel.text = artistName;
            cell.cellType = AlbumHeaderCellType;
            cell.delegate = self;
            cell.albumNumberLabel.hidden = YES;
            cell.isAdded = NO;
            
            //NSLog(@"Album Cell");
            //    NSLog(@"albumName = %@", albumName);
            //    NSLog(@"artistName = %@", artistName);
            //    NSLog(@"_arrayOfSongItems.count = %i", _arrayOfAlbumsItems.count);
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                                  initWithTarget:self action:@selector(albumTapped:)];
            [cell.textScrollView addGestureRecognizer:tapGesture];

            cell.textScrollView.scrollEnabled = NO;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if ([[[PlaylistEngine shared].arrayAlbums objectAtIndex:indexPath.row] isKindOfClass:[SongObject class]])
        { 
            if ([PlaylistEngine shared].arrayAlbums.count > 0)
            {
                SongObject *songObject  = [[PlaylistEngine shared].arrayAlbums objectAtIndex:indexPath.row];
                
                if (songObject.songObjectType == SongObjectAllType)
                {
                    SongObject *nextSongObject  = [[PlaylistEngine shared].arrayAlbums objectAtIndex:indexPath.row +1]; // There always has to be one more...
                    
                    AlbumObject *albumObject = [[PlaylistEngine shared].arrayAlbums objectAtIndex:indexPath.row-1];
                    
                    NSInteger trackCount = albumObject.numberOfTracks;
                    
                    if (trackCount == 1)
                    {
                        cell.songLabel.text = @"+ 1 track";
                    }
                    else
                    {
                        cell.songLabel.text = [NSString stringWithFormat:@"+ %li tracks", (long)trackCount];
                    }
                    
                    cell.artistAlbumLabel.text = [NSString stringWithFormat:@"%@", nextSongObject.album];
                    cell.cellType = AlbumAllCellType;
                    cell.delegate = self;
                    cell.isCloud = songObject.isCloudItem;
                    // Need to think about isAdded
                    cell.isAdded = NO;
                    
                    cell.albumNumberLabel.hidden = YES;
                    cell.textScrollView.scrollEnabled = YES;
                    // Remove gesture? - put in tableviewcontroller.tableview?
                    
                    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFromAlbumSong:)];
                    [cell.textScrollView addGestureRecognizer:tapGesture];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                else
                {
                    NSString *title = songObject.title;
                    NSString *artist = songObject.artist;
                    NSString *albumTitle = songObject.album;
                    
                    if (title == nil || title.length == 0)
                    {
                        title = @"";
                    }
                    
                    if (albumTitle == nil || albumTitle.length == 0)
                    {
                        albumTitle = @"";
                    }
                    
                    if (artist == nil || artist.length == 0)
                    {
                        artist = @"";
                    }
                    
                    cell.songLabel.text =  title;
                    cell.artistAlbumLabel.text = [NSString stringWithFormat:@"%@ \u2014 %@", artist, albumTitle];
                    cell.delegate = self;
                    
                    if (songObject.songObjectType != SongObjectAlbumHeaderType)
                    {
                        cell.isAdded = songObject.isAdded;
                    }
                    
                    if (songObject.songObjectType == SongObjectAlbumSongType)
                    {
                        cell.albumNumberLabel.hidden = NO;
                        
                        if (!songObject.albumTrackNumber)
                        {
                            cell.albumNumberString = @"??";
                        }
                        else
                        {
                            cell.albumNumberString = [NSString stringWithFormat:@"%02ld.", (long)[songObject.albumTrackNumber integerValue]];
                        }
                        
                        cell.cellType = AlbumTrackCellType;
                    }
                    else
                    {
                        cell.albumNumberLabel.hidden = YES;
                        cell.albumNumberString = @"";
                        cell.cellType = TrackCellType;
                    }
                 
                    cell.isCloud = songObject.isCloudItem;
                    cell.textScrollView.scrollEnabled = YES;
                    
                    // Remove gesture? - put in tableviewcontroller.tableview?
                    
                    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self action:@selector(handleSingleTapFromAlbumSong:)];
                    [cell.textScrollView addGestureRecognizer:tapGesture];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
            }
        }
    }
    else
    {
        NSLog(@"Error");
    }
        
    return cell;
}

-(void) albumTapped:(UIGestureRecognizer*)gesture
{
    CGPoint p = [gesture locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:p];
    
    [self dismissSearchKeyboard];
    
    AlbumObject *albumObject = [[PlaylistEngine shared].arrayAlbums objectAtIndex:indexPath.row];
    
    if (albumObject.isTopLevelHeaderOpen)
    {
        [self hideSubLevelWithIndex:indexPath];
        albumObject.isTopLevelHeaderOpen = NO;
    }
    else
    {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [self showSubLevelWithIndex:indexPath];
        albumObject.isTopLevelHeaderOpen = YES;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_allSongsShowing)
    {
        return [self cellSongWithIndexPath:indexPath andTableView:tableView];
    }
    else
    {
        switch (indexPath.section)
        {               
            case 0:
            {
               if ([[PlaylistEngine shared].arrayAlbums count] > 0)
               {
                   return [self cellAlbumWithIndexPath:indexPath andTableView:tableView];
               }
               else
               {
                   return [self cellSongWithIndexPath:indexPath andTableView:tableView];
               }
            }
            break;
                
            case 1:
            {
                return [self cellSongWithIndexPath:indexPath andTableView:tableView];
            }
            break;
                
            default:
            break;
        }
    }
    return nil;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self dismissSearchKeyboard];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SCROLL_START object:nil userInfo:@{@"isInSearch": [NSNumber numberWithBool:!_allSongsShowing]}];
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

-(void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SCROLL_END object:nil userInfo:@{@"velocity": [NSNumber numberWithFloat:velocity.y]}];
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    return CELL_HEIGHT;
}

-(void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer // From normal track cell
{
    // Hack because of the scrollview in the cell.
    CGPoint p = [gestureRecognizer locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:p];
  
    SongObject *songObject;
    
    if (_allSongsShowing)
    {
        songObject = [[PlaylistEngine shared].arraySongsOffDevice objectAtIndex:indexPath.row];
    }
    else
    {
        songObject = [[PlaylistEngine shared].arraySearchTracks objectAtIndex:indexPath.row];
    }

    if (!songObject.isAdded)
    {
        [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self tableView:_tableView didSelectRowAtIndexPath:indexPath];
    }
}

-(void)handleSingleTapFromAlbumSong:(UITapGestureRecognizer *)gestureRecognizer
{
    // Hack because of the scrollview in the cell.
    CGPoint p = [gestureRecognizer locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:p];
    
    SongObject * songObject = [[PlaylistEngine shared].arrayAlbums objectAtIndex:indexPath.row];
    
    if (!songObject.isAdded)
    {
        [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self tableView:_tableView didSelectRowAtIndexPath:indexPath];
    }
}

-(void) showITunesMatchAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"iTunes Match" message:@"This song is not downloaded on to this device. We cannot add it to a playlist. Do you want to open the Music app to download the track?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView show];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchTableCell *searchCell = (SearchTableCell*)[_tableView cellForRowAtIndexPath:indexPath];
    
    if (searchCell.isCloud)
    {
        [self showITunesMatchAlert];
    }
    else
    {
        [searchCell cellTapped];
    }
}

-(void) showSubLevelWithIndex:(NSIndexPath*)indx
{
    if (![[[PlaylistEngine shared].arrayAlbums objectAtIndex:indx.row] isKindOfClass:[AlbumObject class]])
        return;
        
    AlbumObject *albumObject = [[PlaylistEngine shared].arrayAlbums objectAtIndex:indx.row];
    // Get all tracks in that album.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"albumID == %lld", [albumObject.albumID longLongValue]];
    
    NSArray *filteredArray = [[PlaylistEngine shared].arraySongsOffDevice filteredArrayUsingPredicate:predicate];
    
    NSInteger i = indx.row + 1;
    
    [self.tableView beginUpdates];

    // Sort it by albumTrackNumber
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"albumTrackNumber"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [filteredArray sortedArrayUsingDescriptors:sortDescriptors];
    
    albumObject.numberOfTracks = sortedArray.count;
    
    // Add All
    if (sortedArray.count > 0)
    {
        SongObject *allObject = [SongObject new];
        allObject.songObjectType = SongObjectAllType;
        [[PlaylistEngine shared].arrayAlbums insertObject:allObject atIndex:i];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
   
    i = i + 1;
    
    for (SongObject *songObj in sortedArray)
    {
        songObj.songObjectType = SongObjectAlbumSongType;
        [[PlaylistEngine shared].arrayAlbums insertObject:songObj atIndex:i];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        i = i + 1;
    }
    
    [self.tableView endUpdates];
}

-(void) hideSubLevelWithIndex:(NSIndexPath*)indx
{
    if (![[[PlaylistEngine shared].arrayAlbums objectAtIndex:indx.row] isKindOfClass:[AlbumObject class]])
        return;
    
    AlbumObject *albumObject = [[PlaylistEngine shared].arrayAlbums objectAtIndex:indx.row];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"albumID == %lld", [albumObject.albumID longLongValue]];
    
    NSArray *filteredArray = [[PlaylistEngine shared].arraySongsOffDevice filteredArrayUsingPredicate:predicate];
    
    [self.tableView beginUpdates];
    
    [[PlaylistEngine shared].arrayAlbums removeObjectsInRange:NSMakeRange(indx.row + 1,filteredArray.count +1)];

    NSMutableArray *arrayIndexPaths = [NSMutableArray array];
    
    for (NSInteger i = indx.row + 1; i < filteredArray.count + indx.row + 2; i++)
    {
        // #warning Section! - Not a problem now we only have one additonal section
        //  NSLog(@"i = %i", i);
        [arrayIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    [self.tableView deleteRowsAtIndexPaths:arrayIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
    
    [self.tableView endUpdates];
    
    //[self.tableView reloadData];
}

-(void) songAddedWithCell:(SearchTableCell *)cell
{
    NSIndexPath *indx = [self.tableView indexPathForCell:cell];

#warning Need validation - item that got deleted that was already deleted.
    
    switch (cell.cellType)
    {
        case TrackCellType:
        {
            if (_allSongsShowing)
            {
                SongObject *songObject = [[PlaylistEngine shared].arraySongsOffDevice objectAtIndex:indx.row];
               
                if (!songObject.isAdded)
                {
                    [[PlaylistEngine shared] addSong:songObject];
                }
            }
            else
            {
                SongObject *songObject = [[PlaylistEngine shared].arraySearchTracks objectAtIndex:indx.row];
               
                if (!songObject.isAdded)
                {
                    [[PlaylistEngine shared] addSong:songObject];
                }
            }
        }
            break;
    
        case AlbumAllCellType:
        {
            SongObject *songObject  = [[PlaylistEngine shared].arrayAlbums objectAtIndex:indx.row-1];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"albumID == %lld", [songObject.albumID longLongValue]];
            
            NSArray *filteredArray = [[PlaylistEngine shared].arraySongsOffDevice filteredArrayUsingPredicate:predicate];
            
            // Sort it by albumTrackNumber
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"albumTrackNumber"
                                                         ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            NSArray *sortedArray;
            sortedArray = [filteredArray sortedArrayUsingDescriptors:sortDescriptors];
            
            NSInteger i = indx.row + 1;
            
            for (SongObject *song in sortedArray)
            {
                if (song.isCloudItem)
                {
                    [self showITunesMatchAlert];
                    break;
                }
                
                SearchTableCell *cell = (SearchTableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indx.section]];
                
                 NSLog(@"cell = %@", cell);
                 NSLog(@"song = %@", song);
                
                // If cell is not showing, add it normally.
                    if (cell)
                    {
                        [[PlaylistEngine shared] addSong:song];
                        [cell cellTapped];
                    }

                    else
                        [[PlaylistEngine shared] addSong:song];
                
                i = i + 1;
            }
        }
        break;
            
        case AlbumTrackCellType:
        {
            // Need to fix SearchSongAlbumCellType
            
             NSLog(@"[[PlaylistEngine shared].arrayAlbums objectAtIndex:indx.row] = %@", [[PlaylistEngine shared].arrayAlbums objectAtIndex:indx.row]);
            
            if ( [[[PlaylistEngine shared].arrayAlbums objectAtIndex:indx.row] isKindOfClass:[SongObject class]])
            {
                SongObject *songObject = [[PlaylistEngine shared].arrayAlbums objectAtIndex:indx.row];
                if (!songObject.isAdded)
                {
                    [[PlaylistEngine shared] addSong:songObject];
                }

            }
        }
            break;
        
        default:
            break;
    }
}

-(void) savedPlaylistAdded;
{
    [_tableView reloadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            
        break;
            
        case 1:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"music://" relativeToURL:nil]];
        }
        break;
            
        default:
        break;
    }
}

-(void) scrollToTop
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void) dismissSearchKeyboard
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeSearchKeyboard" object:nil];
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"navSearchTextFieldChangedNotification" object:nil];
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