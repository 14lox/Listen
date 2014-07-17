//
//  TitleViewController.m
//  Listen
//
//  Created by Dai Hovey on 22/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import "TitleViewController.h"
#import "PlaylistEngine.h"
#import "UIFont+ListenFont.h"

@interface TitleViewController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *titleTextView;
@property (nonatomic, strong) NSMutableParagraphStyle *paragraphStyle;

@end

@implementation TitleViewController

- (id)init
{
    self = [super init];
    if (self) {}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    
    UIButton *playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playPauseButton.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    playPauseButton.backgroundColor = [UIColor clearColor];
    [playPauseButton addTarget:self action:@selector(playPauseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playPauseButton];
}

-(void) playPauseButtonPressed:(id)sender
{
    [[PlaylistEngine shared] playPauseToggle];
}

-(void) setTitleString:(NSAttributedString *)titleString
{   
    _titleString = titleString;
    
   if (!_titleLabel)
   {
       _titleLabel = [[UILabel alloc] init];
       
        if ([UIScreen mainScreen].bounds.size.height == 568)
            _titleLabel.numberOfLines = 8;
        else
            _titleLabel.numberOfLines = 6;
       
       _titleLabel.backgroundColor = [UIColor clearColor];
       _titleLabel.textAlignment = NSTextAlignmentLeft;
       _titleLabel.alpha = 1;
       [self.view addSubview:_titleLabel];
   }
    
    _titleLabel.attributedText = _titleString;
    _titleLabel.frame = CGRectMake(10, 0, self.view.frame.size.width - 20 , self.view.frame.size.height);
    [_titleLabel sizeToFit];

}

-(void) titleAttributedStringWithFullString:(NSString*)fullString titleString:(NSString*)titleString artist:(NSString*)artistString album:(NSString*)albumString scale:(CGFloat)scale
{
    if (!_paragraphStyle)
    {
        _paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        _paragraphStyle.lineSpacing = -10.0f;
        _paragraphStyle.minimumLineHeight = 44.f;
        _paragraphStyle.maximumLineHeight = 44.f;
        _paragraphStyle.paragraphSpacing = -10;
        _paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping | NSLineBreakByTruncatingTail;
    }
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:fullString];
    
    [string beginEditing];
    [string addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(RED_COLOUR) range:NSMakeRange(0,titleString.length)];
    [string addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(PINK_COLOUR) range:NSMakeRange(titleString.length + 1,artistString.length )];
    [string addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(GREY_COLOUR) range:NSMakeRange(titleString.length + artistString.length + 2 ,albumString.length)];
    [string addAttribute:NSFontAttributeName value:[UIFont boldListenFontOfSize:(40 * scale)] range:NSMakeRange(0, fullString.length)];
    [string addAttribute:NSKernAttributeName value:[NSNumber numberWithFloat:-0.7f] range:NSMakeRange(0, fullString.length)];
    [string addAttribute:NSParagraphStyleAttributeName value:_paragraphStyle range:NSMakeRange(0, fullString.length)];
    [string endEditing];
    
    [self setTitleString:string];
}

-(void) getDataFromMediaItem:(MPMediaItem*)mediaItem
{
    NSString *titleName = [mediaItem valueForKey:MPMediaItemPropertyTitle];
    if (titleName.length == 0 || !titleName) titleName = @"";
    
    NSString *artistName = [mediaItem valueForProperty: MPMediaItemPropertyArtist];
    if (artistName.length == 0 || !artistName) artistName = @"";
    
    NSString *albumName = [mediaItem valueForProperty: MPMediaItemPropertyAlbumTitle];
    if (albumName.length == 0 || !albumName) albumName = @"";

    NSString *songArtistAlbumName = [NSString stringWithFormat:@"%@ %@ %@", titleName , artistName, albumName];
    
    [self titleAttributedStringWithFullString:songArtistAlbumName titleString:titleName artist:artistName album:albumName scale:1];
}

-(void) dealloc
{
    _titleLabel = nil;
    _paragraphStyle = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

@implementation NextTitleViewController

@end

@implementation PreviousTitleViewController

@end
