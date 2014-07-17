//
//  TopNavigationViewController.m
//  Listen
//
//  Created by Dai Hovey on 06/12/2012.
//  Copyright (c) 2012 14lox. All rights reserved.
//

#import "TopNavigationViewController.h"
#import "HUDImageView.h"
#import "PlaylistEngine.h"
#import "UIFont+ListenFont.h"

@interface TopNavigationViewController ()

@property (nonatomic, strong) HUDImageView *hudImageView;
@property (nonatomic, strong) UIImage *playlistOn;
@property (nonatomic, strong) UIImage *playlistOff;
@property (nonatomic) BOOL isMoreButtonPressed;
@property (nonatomic) BOOL flashPlaylistIconStopBOOL;

@end

@implementation TopNavigationViewController

- (id)init
{
    self = [super init];
    if (self) { }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _playlistOn = [UIImage imageNamed:@"List-On.png"];
    _playlistOff = [UIImage imageNamed:@"List-Off.png"];
    
    _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_searchButton setImage:[UIImage imageNamed:@"Search-On.png"] forState:UIControlStateNormal];
    [_searchButton addTarget:self action:@selector(searchButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    _searchButton.frame = CGRectMake(0.0f, 0.0f, 110.0f, 44.0f);
    _searchButton.backgroundColor = [UIColor clearColor];
    _searchButton.imageEdgeInsets = UIEdgeInsetsMake(0, -66.0f, 0, 0);
    [self.view addSubview:_searchButton];
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeButton setImage:[UIImage imageNamed:@"Close-On.png"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    _closeButton.frame = CGRectMake(0.0f, -44.0f, 44.0f, 44.0f);
    [self.view addSubview:_closeButton];
    
    _playlistButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playlistButton setImage:[UIImage imageNamed:@"List-Off.png"] forState:UIControlStateNormal];
    _playlistButton.frame = CGRectMake(self.view.bounds.size.width - 110.0f, 0.0f, 110.0f, 44.0f);
    [_playlistButton addTarget:self action:@selector(playlistButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    _playlistButton.imageEdgeInsets = UIEdgeInsetsMake(0, 66.0f, 0, 0);
    _playlistButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_playlistButton];
    
    _scrollTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _scrollTopButton.backgroundColor = [UIColor clearColor];
    [_scrollTopButton addTarget:self action:@selector(scrollTopButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _scrollTopButton.frame = CGRectMake(110.0f, 0.0f, 100.0f, 44.0f);
    [self.view addSubview:_scrollTopButton];

    _textField = [[UITextField alloc] initWithFrame:CGRectMake(50.0f, 3.0f, 0.0f, 44.0f)];
    _textField.font = [UIFont boldListenFontOfSize:38];
    _textField.placeholder = @"";
    _textField.textColor = [UIColor whiteColor];
    _textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textField.delegate = self;
    _textField.returnKeyType = UIReturnKeySearch;
    _textField.backgroundColor = [UIColor clearColor];
    _textField.keyboardAppearance = UIKeyboardAppearanceDark;
    [self.view addSubview:_textField];
    
    _hudImageView = [HUDImageView shared];
    _hudImageView.frame = CGRectMake(50, 0, 220, 44);
    [self.view addSubview:_hudImageView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:@"UITextFieldTextDidChangeNotification" object:_textField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidStartFocus:) name:@"UITextFieldTextDidBeginEditingNotification" object:_textField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchMadeToCloseKeyboard:) name:@"closeSearchKeyboard" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackAdded:) name:NOTIFICATION_TRACK_ADDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playPauseToggle) name:NOTIFICATION_PLAY_PAUSE_TOGGLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackDeleted) name:NOTIFICATION_TRACK_DELETED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flashPlaylistIconStart) name:NOTIFICATION___INSTRUCTION_FLASH_PLAYLIST_ICON object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flashPlaylistIconStop) name:NOTIFICATION___INSTRUCTION__STOP__FLASH_PLAYLIST_ICON object:nil];
}

-(void) searchButtonPressed
{
   [_delegate searchButtonPressed];
}

-(void) updateIconsForSearch
{
    [_searchButton setImage:[UIImage imageNamed:@"Search-On.png"] forState:UIControlStateNormal];
    [_playlistButton setImage:_playlistOff forState:UIControlStateNormal];
}

-(void) updateIconsForSearchTextEntry
{
    [_searchButton setImage:[UIImage imageNamed:@"Search-On.png"] forState:UIControlStateNormal];
    [_playlistButton setImage:_playlistOff forState:UIControlStateNormal];
    
    __block TopNavigationViewController *weakSelf = self;
    
    [_textField becomeFirstResponder];
    
    [UIView animateWithDuration:0.3f animations:^(void)
     {
         self.view.frame = CGRectMake(0.0f, 0.0f , weakSelf.view.frame.size.width, 55.0f);
         weakSelf.searchButton.frame = CGRectMake(-44.0f,  TOP_NAV_ICON_Y_AXIS_DIFF, weakSelf.searchButton.frame.size.width, weakSelf.searchButton.frame.size.height);
         weakSelf.closeButton.frame = CGRectMake(weakSelf.closeButton.frame.origin.x, TOP_NAV_ICON_Y_AXIS_DIFF, weakSelf.closeButton.frame.size.width, weakSelf.closeButton.frame.size.height);
         weakSelf.textField.frame = CGRectMake(weakSelf.textField.frame.origin.x, weakSelf.textField.frame.origin.y , 190.0f, weakSelf.textField.frame.size.height);
     }
        completion:NULL];
}

-(void) scrollTopButtonPressed:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SCROLL_TABLE_TO_TOP object:nil];
}

-(void) closeButtonPressed
{
    [_searchButton setImage:[UIImage imageNamed:@"Search-On.png"] forState:UIControlStateNormal];
    
    _textField.text = @"";
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"" forKey:@"text"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"navSearchTextFieldChangedNotification" object:_textField userInfo:dict];
    
    __block TopNavigationViewController *weakSelf = self;
    
    [UIView animateWithDuration:0.3f animations:^(void)
     {
         self.view.frame = CGRectMake(0.0f, 0.0f , weakSelf.view.frame.size.width, TOP_NAVIGATION_HEIGHT);
         
         weakSelf.searchButton.frame = CGRectMake(0, 0 , weakSelf.searchButton.frame.size.width, weakSelf.searchButton.frame.size.height);
         weakSelf.closeButton.frame = CGRectMake(weakSelf.closeButton.frame.origin.x, -44.0f, weakSelf.closeButton.frame.size.width, weakSelf.closeButton.frame.size.height);
         weakSelf.textField.frame = CGRectMake(weakSelf.textField.frame.origin.x, weakSelf.textField.frame.origin.y , 0.0f, weakSelf.textField.frame.size.height);
     }
      completion:^(BOOL finished)
     {
         [weakSelf.textField resignFirstResponder];
     }];
}

-(void) playlistButtonPressed
{
    [_delegate playlistButtonPressed];
}

-(void) updateIconsForPlaylist
{
    [_playlistButton setImage:_playlistOn forState:UIControlStateNormal];
    [_searchButton setImage:[UIImage imageNamed:@"Search-Off.png"] forState:UIControlStateNormal];
    
    __block TopNavigationViewController *weakSelf = self;
    
    [_textField resignFirstResponder];
    
    [UIView animateWithDuration:0.3f animations:^(void)
     {
         self.view.frame = CGRectMake(0.0f, 0.0f , weakSelf.view.frame.size.width, TOP_NAVIGATION_HEIGHT);
         
         weakSelf.searchButton.frame = CGRectMake(0, 0 , weakSelf.searchButton.frame.size.width, weakSelf.searchButton.frame.size.height);
         weakSelf.closeButton.frame = CGRectMake(weakSelf.closeButton.frame.origin.x, -44.0f, weakSelf.closeButton.frame.size.width, weakSelf.closeButton.frame.size.height);
         weakSelf.textField.frame = CGRectMake(weakSelf.textField.frame.origin.x, weakSelf.textField.frame.origin.y , 0.0f, weakSelf.textField.frame.size.height);
     }
        completion:^(BOOL finished)
     {
     }];
}

-(void) trackAdded:(NSNotification*)note
{
    [_hudImageView showImage:Add_HUDImageType];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_TOP_NAVIGATION object:nil];
   
    [_playlistButton setImage:_playlistOff forState:UIControlStateNormal];

}

-(void) playPauseToggle
{
    if ([PlaylistEngine shared].isPlaying)
    {
        [_hudImageView showImage:Play_ImageType];
    }
    else
    {
        [_hudImageView showImage:Pause_ImageType];
    }
}

-(void) trackDeleted
{
     [_hudImageView showImage:Delete_HUDImageType];
}

-(void) flashPlaylistIconStart
{
    if (![_playlistButton.imageView.image isEqual:_playlistOn] && !_flashPlaylistIconStopBOOL)
    {
        [_playlistButton setImage:_playlistOn forState:UIControlStateNormal];
        
        [self performSelector:@selector(flashPlaylistIconEnded) withObject:nil afterDelay:0.7];
    }
}

-(void) flashPlaylistIconEnded
{
    if (!_flashPlaylistIconStopBOOL)
    {
        [_playlistButton setImage:_playlistOff forState:UIControlStateNormal];
        
        [self performSelector:@selector(flashPlaylistIconStart) withObject:nil afterDelay:0.7];
    }
}

-(void) flashPlaylistIconStop
{
    _flashPlaylistIconStopBOOL = YES;
    
    [_playlistButton setImage:_playlistOn forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION___INSTRUCTION_FLASH_PLAYLIST_ICON object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION___INSTRUCTION__STOP__FLASH_PLAYLIST_ICON object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    [_textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidStartFocus:(NSNotification *)notif
{
    
}

-(void)touchMadeToCloseKeyboard:(NSNotification *)notif
{
    [_textField resignFirstResponder];
}

- (void)textFieldDidChange:(NSNotification *)notif
{
    UITextField *txt = (UITextField*)notif.object;
    
    if (notif.object == _textField)
    {
         NSDictionary *dict = [NSDictionary dictionaryWithObject:txt.text forKey:@"text"];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"navSearchTextFieldChangedNotification" object:_textField userInfo:dict];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:_textField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextFieldTextDidBeginEditingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"closeSearchKeyboard" object:nil];
}

@end