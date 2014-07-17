//
//  SearchTableCell.h
//  Listen
//
//  Created by Dai Hovey on 12/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    TrackCellType = 0,
    AlbumHeaderCellType = 1,
    AlbumAllCellType = 2,
    AlbumTrackCellType = 3,
} CellType;

@class SearchTableCell;

@protocol SearchCellAddSongProtocol <NSObject>

-(void) songAddedWithCell:(SearchTableCell*)cell;

@end

@interface SearchTableCell : UITableViewCell

@property (nonatomic, strong) UIScrollView *textScrollView;
@property (nonatomic, strong) UILabel *songLabel;
@property (nonatomic, strong) UILabel *artistAlbumLabel;
@property (nonatomic, strong) NSString *albumNumberString;
@property (nonatomic) BOOL isAdded;
@property (nonatomic) BOOL isCloud;
@property (nonatomic, weak) id <SearchCellAddSongProtocol> delegate;
@property (nonatomic) CellType cellType;
@property (nonatomic, strong) UILabel *albumNumberLabel;

-(void) cellTapped;

@end
