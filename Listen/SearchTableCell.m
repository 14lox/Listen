//
//  SearchTableCell.m
//  Listen
//
//  Created by Dai Hovey on 12/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import "SearchTableCell.h"
#import "UIFont+ListenFont.h"

@interface SearchTableCell () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *plusImageView;
@property (nonatomic, strong) UIView *container;
@property (nonatomic) BOOL isAnimating;
@property (nonatomic, strong) UIImageView *cloudImage;
@property (nonatomic, strong) UIImage *addOnImage;
@property (nonatomic, strong) UIImage *addOffImage;
@property (nonatomic) CGFloat plusYPos;
@property (nonatomic) CALayer *line;

@end

@implementation SearchTableCell

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
        _textScrollView.scrollEnabled = NO;
        
        _container = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width * 0.5, CELL_HEIGHT)];
        _container.backgroundColor = [UIColor blackColor];
        
        [_textScrollView addSubview:_container];
        
        _songLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 5, self.frame.size.width - 12, 40)];
        _songLabel.font = [UIFont boldListenFontOfSize: 40];
        _songLabel.textColor = [UIColor whiteColor];
        _songLabel.backgroundColor = [UIColor clearColor];
        
        _artistAlbumLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 50, self.frame.size.width - 12, 20)];
        _artistAlbumLabel.font = [UIFont boldListenFontOfSize:14];
        _artistAlbumLabel.textColor = UIColorFromRGB(0xffffff);
        _artistAlbumLabel.backgroundColor = [UIColor clearColor];

        _albumNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 8, 20, 20)];
        _albumNumberLabel.font = [UIFont lightListenFontOfSize:10];
        _albumNumberLabel.textColor = UIColorFromRGB(0xffffff);
        _albumNumberLabel.backgroundColor = [UIColor clearColor];
        _albumNumberLabel.text = @"";
        
        _cloudImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cloud"]];
        _cloudImage.frame = CGRectMake(12, 53, _cloudImage.frame.size.width, _cloudImage.frame.size.height);
        _cloudImage.hidden = YES;
        
        _textScrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
        
        [_container addSubview:_cloudImage];
        [_container addSubview:_albumNumberLabel];
        [_container addSubview:_songLabel];
        [_container addSubview:_artistAlbumLabel];
        [self.contentView addSubview:_textScrollView];
        
        _addOffImage = [UIImage imageNamed:@"Addto-off"];
        _addOnImage = [UIImage imageNamed:@"Addto-on"];
        
        _plusImageView = [[UIImageView alloc] initWithImage:_addOffImage];
        _plusImageView.frame = CGRectMake(10, CELL_HEIGHT * .5f - _plusImageView.image.size.height * 0.5, _plusImageView.frame.size.width, _plusImageView.frame.size.height);
        [self.contentView insertSubview:_plusImageView belowSubview:_textScrollView];
        
        _isAnimating = YES;
    }
    
    return self;
}

-(void) setAlbumNumberString:(NSString *)albumNumberString
{
    _albumNumberString = albumNumberString;
    _albumNumberLabel.text = _albumNumberString;
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x < self.frame.size.width * 0.5f)
    {
        _plusImageView.image = _addOnImage;
        
        _plusYPos = (self.frame.size.width * 0.5f - scrollView.contentOffset.x) * 2 + 5;
        
        _plusImageView.frame = CGRectMake(_plusYPos, _plusImageView.frame.origin.y, _plusImageView.frame.size.width, _plusImageView.frame.size.height);
    }
    else if (scrollView.contentOffset.x > self.frame.size.width * 0.5f)
    {
        _plusImageView.image = _addOffImage;
    }
    
    if (scrollView.contentOffset.x <= 0)
    {
        [self performAddAnimtations];
        _plusImageView.frame = CGRectMake(10, _plusImageView.frame.origin.y, _plusImageView.frame.size.width, _plusImageView.frame.size.height);
    }
}

-(void) performAddAnimtations
{
    [_delegate songAddedWithCell:self];
    _textScrollView.scrollEnabled = NO;
    _textScrollView.alpha = 0;
    
    _songLabel.textColor = UIColorFromRGB(DARK_GREY_COLOUR);
    _artistAlbumLabel.textColor = UIColorFromRGB(DARK_GREY_COLOUR);
    
    _line.backgroundColor = UIColorFromRGB(DARK_GREY_COLOUR).CGColor;
    
    _plusImageView.alpha = 0;
    
    _textScrollView.contentOffset = CGPointMake(320, 0);
    
    __weak SearchTableCell *weakSelf = self;
    
    [UIView animateWithDuration:1 animations:^
     {
         weakSelf.textScrollView.alpha = 1;
         
     } completion:NULL];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if(_line)
    {
        [_line removeFromSuperlayer];
        _line = nil;
    }
    
    if (_cellType == AlbumAllCellType || _cellType == AlbumTrackCellType)
    {
        _line = [CALayer layer];
        _line.backgroundColor = UIColorFromRGB(0x939597).CGColor;
        _line.frame = CGRectMake(32, CELL_HEIGHT-1, 30, 1);
        [self.layer addSublayer:_line];
    }
    else
    {
        _line = [CALayer layer];
        _line.backgroundColor = UIColorFromRGB(0x939597).CGColor;
        _line.frame = CGRectMake(12, CELL_HEIGHT-1, 30, 1);
        [self.layer addSublayer:_line];
    }
    
    if (_isAdded)
    {
        _songLabel.textColor = UIColorFromRGB(DARK_GREY_COLOUR);
        _artistAlbumLabel.textColor = UIColorFromRGB(DARK_GREY_COLOUR);
        _line.backgroundColor = UIColorFromRGB(DARK_GREY_COLOUR).CGColor;
        _textScrollView.scrollEnabled = NO;
        _textScrollView.contentOffset = CGPointMake(320, 0);
    }
    else
    {
        if (!_isCloud)
        {
            _textScrollView.delegate = self;
            
            if (_cellType != AlbumHeaderCellType) {
                _textScrollView.scrollEnabled = YES;
            }
            
            _songLabel.textColor = UIColorFromRGB(0xffffff);
            _artistAlbumLabel.textColor = UIColorFromRGB(0xffffff);
        }
        else
        {
            _textScrollView.delegate = nil;
            _textScrollView.scrollEnabled = NO;
            _songLabel.textColor = UIColorFromRGB(GREY_COLOUR);
        }
        
        _plusImageView.alpha = 1;
    }
}

-(void) setIsAdded:(BOOL)isAdded
{
    _isAdded = isAdded;
   
    if (_isAdded)
    {
        _songLabel.textColor = UIColorFromRGB(GREY_COLOUR);
        _artistAlbumLabel.textColor = UIColorFromRGB(GREY_COLOUR);
        _textScrollView.scrollEnabled = NO;
        _textScrollView.contentOffset = CGPointMake(320, 0);
    }
    else
    {
        if (!_isCloud && _cellType != AlbumHeaderCellType)
        {
            _textScrollView.delegate = self;
            _textScrollView.scrollEnabled = YES;
            _songLabel.textColor = UIColorFromRGB(0xffffff);
        }
        else
        {
            _textScrollView.delegate = nil;
            _textScrollView.scrollEnabled = NO;
            _songLabel.textColor = UIColorFromRGB(0xffffff);
        }
        
        _plusImageView.alpha = 1;
    }
}

-(void) setIsCloud:(BOOL)isCloud
{
    _isCloud = isCloud;
    
    if (_isCloud)
    {
        _textScrollView.delegate = nil;
        _textScrollView.scrollEnabled = NO;
        _cloudImage.hidden = NO;
        _artistAlbumLabel.frame = CGRectMake(_artistAlbumLabel.frame.origin.x + _cloudImage.frame.size.width + 5, _artistAlbumLabel.frame.origin.y, _artistAlbumLabel.frame.size.width - _cloudImage.frame.size.width - 5, _artistAlbumLabel.frame.size.height);
        
        if (_cellType == (CellType)AlbumTrackCellType)
        {
            _cloudImage.frame = CGRectMake(32, 53, _cloudImage.frame.size.width, _cloudImage.frame.size.height);
            _artistAlbumLabel.frame = CGRectMake(32 + _cloudImage.frame.size.width + 5, 50, self.frame.size.width - 32 - _cloudImage.frame.size.width - 5, 20);
        }
    }
    else
   {
        _textScrollView.delegate = self;
       
       if (_cellType != AlbumHeaderCellType) {
           _textScrollView.scrollEnabled = YES;
       }
       
       _cloudImage.hidden = YES;
    }
}

-(void) setCellType:(CellType)cellType
{
    _cellType = cellType;
    
    if (_cellType ==  (CellType)AlbumHeaderCellType)
    {
        _songLabel.frame = CGRectMake(12, 5, self.frame.size.width - 12, 46);
        _artistAlbumLabel.frame = CGRectMake(12, 50, self.frame.size.width - 12, 20);
        _textScrollView.scrollEnabled = NO;
    }
    else if (_cellType == (CellType)AlbumAllCellType)
    {
        _songLabel.frame = CGRectMake(32, 5, self.frame.size.width - 32, 46);
        _artistAlbumLabel.frame = CGRectMake(32, 50, self.frame.size.width - 32, 20);
    }
    else if (_cellType == (CellType)AlbumTrackCellType)
    {
        _songLabel.frame = CGRectMake(32, 5, self.frame.size.width - 32, 46);
        _artistAlbumLabel.frame = CGRectMake(32, 50, self.frame.size.width - 32, 20);
    }
    else
    {
        _songLabel.frame = CGRectMake(12, 5, self.frame.size.width - 12, 46);
        _artistAlbumLabel.frame = CGRectMake(12, 50, self.frame.size.width - 12, 20);
    }
}

-(void) cellTapped
{
    _textScrollView.delegate = nil;

    _plusImageView.image = _addOnImage;

    [UIView animateWithDuration:0.15 delay:0.15 options:UIViewAnimationOptionTransitionNone animations:^
    {
        _plusImageView.frame = CGRectMake(10 + self.frame.size.width, _plusImageView.frame.origin.y, _plusImageView.frame.size.width, _plusImageView.frame.size.height);
    } completion:^(BOOL finished)
    {
        _plusImageView.frame = CGRectMake(10, _plusImageView.frame.origin.y, _plusImageView.frame.size.width, _plusImageView.frame.size.height);
    }];
    
    [UIView animateWithDuration:0.3 animations:^
    {
        _textScrollView.contentOffset = CGPointMake(0, 0);
    }
     completion:^(BOOL finished)
    {
        if (finished)
        {
            [self performAddAnimtations];
            _textScrollView.delegate = self;
        }
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void) prepareForReuse
{
    [super prepareForReuse];
    
    _textScrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
    _songLabel.text = @"";
    _artistAlbumLabel.text = @"";
    _plusImageView.alpha = 1;
    _cloudImage.hidden = YES;
    [_line removeFromSuperlayer];
    _line = nil;
}

@end
