//
//  PlaylistTableCell.m
//  Listen
//
//  Created by Dai Hovey on 13/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import "PlaylistTableCell.h"
#import "PlaylistEngine.h"
#import "UIFont+ListenFont.h"

@interface PlaylistTableCell () <UIScrollViewDelegate>

@property (nonatomic) BOOL isDeleted;
@property (nonatomic, strong) UIImageView *deleteImageView;
@property (nonatomic, strong) UIImage *deleteOnImage;
@property (nonatomic, strong) UIImage *deleteOffImage;

@end

@implementation PlaylistTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = UIColorFromRGB(0x111111);
        
        _textScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, CELL_HEIGHT)];
        _textScrollView.backgroundColor = [UIColor clearColor];
        _textScrollView.contentSize = CGSizeMake(self.frame.size.width * 2, CELL_HEIGHT);
        _textScrollView.showsHorizontalScrollIndicator = NO;
        _textScrollView.showsVerticalScrollIndicator = NO;
        _textScrollView.delegate = self;
        _textScrollView.pagingEnabled = YES;
        _textScrollView.scrollEnabled = YES;
       
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, CELL_HEIGHT)];
        container.backgroundColor = [UIColor blackColor];
        [_textScrollView addSubview:container];
        
        _songLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 5, self.frame.size.width - 12, 42)];
        _songLabel.font = [UIFont boldListenFontOfSize:40];
        _songLabel.textColor = UIColorFromRGB(PINK_COLOUR);
        _songLabel.backgroundColor = [UIColor clearColor];
        
        _artistAlbumLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 50, self.frame.size.width - 12, 20)];
        _artistAlbumLabel.font = [UIFont lightListenFontOfSize:14];
        _artistAlbumLabel.textColor = UIColorFromRGB(PINK_COLOUR);
        _artistAlbumLabel.backgroundColor = [UIColor clearColor];
        
        _textScrollView.contentOffset = CGPointMake(0, 0);
        
        _deleteOnImage = [UIImage imageNamed:@"Delete-On"];
        _deleteOffImage = [UIImage imageNamed:@"Delete-Off"];
        
        _deleteImageView = [[UIImageView alloc] initWithImage:_deleteOffImage];
        _deleteImageView.frame = CGRectMake(self.frame.size.width - _deleteImageView.frame.size.width - 10, CELL_HEIGHT * .5f - _deleteImageView.image.size.height * 0.5, _deleteImageView.frame.size.width, _deleteImageView.frame.size.height);
        [self.contentView insertSubview:_deleteImageView belowSubview:_textScrollView];
        
        [container addSubview:self.songLabel];
        [container addSubview:self.artistAlbumLabel];
        [self.contentView addSubview:_textScrollView];
        
    }
    return self;
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x < self.frame.size.width * 0.5f)
    {
        _deleteImageView.image = _deleteOffImage;
    }
    else if (scrollView.contentOffset.x > self.frame.size.width * 0.5f)
    {
        _deleteImageView.image = _deleteOnImage;
    }
    
    if (scrollView.contentOffset.x >= self.frame.size.width && !_isDeleted)
    {
        [_delegate songDeletedWithCell:self];
        _isDeleted = YES;
        _textScrollView.scrollEnabled = NO;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CALayer *line = [CALayer layer];
    line.backgroundColor = UIColorFromRGB(GREY_COLOUR).CGColor;
    line.frame = CGRectMake(12, CELL_HEIGHT-1, 30, 1);
    [self.layer addSublayer:line];

    // Allow last track to be deleted
    if (_isCurrentTrack)
    {
        if ([PlaylistEngine shared].mutablePlaylistArray.count == 1)
            _textScrollView.scrollEnabled = YES;
        else
            _textScrollView.scrollEnabled = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    self.selectedBackgroundView = nil;
}

- (void)setIsCurrentTrack:(BOOL)isCurrentTrack
{
    self.selectedBackgroundView = nil;
    
    _isCurrentTrack = isCurrentTrack;
    
    if (_isCurrentTrack)
    {
        _songLabel.textColor = UIColorFromRGB(RED_COLOUR);
        _artistAlbumLabel.textColor = UIColorFromRGB(RED_COLOUR);
    }
    else
    {
        _songLabel.textColor = UIColorFromRGB(WHITE_COLOUR);
        _artistAlbumLabel.textColor = UIColorFromRGB(WHITE_COLOUR);
        _textScrollView.scrollEnabled = YES;
    }
}

-(void) prepareForReuse
{
    [super prepareForReuse];
    
    if (_isDeleted)
    {
        _textScrollView.contentOffset = CGPointMake(0, 0);
        _textScrollView.scrollEnabled = YES;
        _isDeleted = NO;
    }
}

@end