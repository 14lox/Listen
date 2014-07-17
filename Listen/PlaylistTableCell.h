//
//  PlaylistTableCell.h
//  Listen
//
//  Created by Dai Hovey on 13/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlaylistTableCell;

@protocol PlaylistCellDeleteSongProtocol <NSObject>

-(void) songDeletedWithCell:(PlaylistTableCell*)cell;

@end

@interface PlaylistTableCell : UITableViewCell 

@property (nonatomic, strong) UIScrollView *textScrollView;
@property (nonatomic, strong) UILabel *songLabel;
@property (nonatomic, strong) UILabel *artistAlbumLabel;
@property (nonatomic, weak) id <PlaylistCellDeleteSongProtocol> delegate;
@property (nonatomic) BOOL isCurrentTrack;

@end