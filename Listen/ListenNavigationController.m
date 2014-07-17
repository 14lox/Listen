//
//  ListenNavigationControllerViewController.m
//  Listen
//
//  Created by David Hovey on 23/04/2012.
//  Copyright (c) 2012 14lox. All rights reserved.
//

#import "ListenNavigationController.h"
#import "SearchViewController.h"
#import "PlaylistViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "PlaylistEngine.h"
#import "ListenPageViewController.h"
#import "InstructionsViewController.h"
#import "InstructionsStepOneView.h"
#import "InstructionsStepTwoView.h"
#import "InstructionsStepThreeView.h"
#import "InstructionsStepFourView.h"

@interface ListenNavigationController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic) BOOL isPlayerViewVisible; // Flag used when we want to hide the PlayerView completely.
@property (nonatomic, strong) ListenPageViewController *pageViewController;
@property (nonatomic) BOOL isSearchVCActive;
@property (nonatomic, strong) UIView *playerViewBackground;
@property (nonatomic, strong) InstructionsStepOneView *instructionsStepOneView;
@property (nonatomic, strong) UIView *instructionsStepOneTopView;
@property (nonatomic, strong) InstructionsStepTwoView *instructionsStepTwoView;
@property (nonatomic, strong) UIView *instructionsStepTwoTopView;
@property (nonatomic, strong) InstructionsStepThreeView *instructionsStepThreeView;
@property (nonatomic, strong) UIView *instructionsStepThreeTopView;
@property (nonatomic, strong) InstructionsStepFourView *instructionsStepFourView;

@end

@implementation ListenNavigationController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.toolbarHidden = YES;
        self.navigationBarHidden = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    
    [[UITextField appearance] setTintColor:UIColorFromRGB(RED_COLOUR)];
    
    NSDictionary * options = [NSDictionary dictionaryWithObject:
                              [NSNumber numberWithInt:UIPageViewControllerSpineLocationNone]
                                               forKey:UIPageViewControllerOptionSpineLocationKey];
    
    _pageViewController = [[ListenPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    _pageViewController.view.backgroundColor = [UIColor clearColor];
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    _pageViewController.doubleSided = NO;
    
    [self.view addSubview:_pageViewController.view];
    
    _topNavigation = [[TopNavigationViewController alloc] init];
    _topNavigation.view.frame = CGRectMake(0, 0, self.view.frame.size.width, TOP_NAVIGATION_HEIGHT);
    _topNavigation.delegate = self;
    [self.view addSubview:_topNavigation.view];

    _topNavigation.delegate = self;
    
    _playerViewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, PLAYER_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - TOP_NAVIGATION_HEIGHT )];
    _playerViewBackground.backgroundColor = [UIColor blackColor];
    _playerViewBackground.userInteractionEnabled = NO;
    _playerViewBackground.alpha = 0;
    [self.view addSubview:_playerViewBackground];
    
    _playerViewController = [[PlayerViewController alloc] init];
    _playerViewController.view.frame = CGRectMake(0, self.view.frame.size.height - PLAYER_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - TOP_NAVIGATION_HEIGHT );
    _playerViewController.view.userInteractionEnabled = YES;

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerViewerTap:)];
    [_playerViewController.view addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *tapCloseGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTap:)];
    [_playerViewController.draggableArea addGestureRecognizer:tapCloseGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [_playerViewController.draggableArea addGestureRecognizer:panGesture];
    [_playerViewController.view addGestureRecognizer:panGesture];
    
    [self addChildViewController:_playerViewController];
    [self.view addSubview:_playerViewController.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollingBegan:) name:SCROLL_START object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollingEnded:) name:SCROLL_END object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationPlayerIsEmpty:) name:NOTIFICATION_PLAYER_IS_EMPTY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationPlayerHasTracks:) name:NOTIFICATION_TRACK_ADDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationShowTopNavigation:) name:SHOW_TOP_NAVIGATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowSearchTable) name:NOTIFICATION_SHOW_SEARCHTABLE object:nil];
    
    _isSearchVCActive = YES;
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:INTRODUCTION_DISPLAYED])
    {
        [PlaylistEngine shared].IN_INSTRUCTIONAL_MODE = YES;

        _pageViewController.dataSource = nil;

        [self instructionsStepOne];

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:INTRODUCTION_DISPLAYED];
    }
    
    [_pageViewController setViewControllers:@[[SearchViewController shared]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    
    if ([PlaylistEngine shared].mutablePlaylistArray.count == 0) [self hidePlayerView];
}

-(void) instructionsStepOne
{
    // Add two tracks (or one if they only have one to add).
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(instructionsStepTwo:) name:NOTIFICATION___INSTRUCTION_FIRST_STEP_COMPLETE object:nil];
    
    _instructionsStepOneTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, PLAYER_HEIGHT)];
    _instructionsStepOneTopView.backgroundColor = UIColorFromRGB(0x000000);
    _instructionsStepOneTopView.alpha = 0.6;
    [self.view addSubview:_instructionsStepOneTopView];
    
    _instructionsStepOneView = [[InstructionsStepOneView alloc] initWithFrame:CGRectMake(0, PLAYER_HEIGHT + (CELL_HEIGHT * 2), self.view.frame.size.width, self.view.frame.size.height - PLAYER_HEIGHT - 150)];
    [self.view addSubview:_instructionsStepOneView];
}

-(void) instructionsStepTwo:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION___INSTRUCTION_FIRST_STEP_COMPLETE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(instructionsStepThree:) name:NOTIFICATION___INSTRUCTION_SECOND_STEP_COMPLETE object:nil];
    
    [_instructionsStepOneTopView removeFromSuperview];
    [_instructionsStepOneView removeFromSuperview];
    
    _instructionsStepTwoTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 110.0f, PLAYER_HEIGHT)];
    _instructionsStepTwoTopView.backgroundColor = UIColorFromRGB(0x000000);
    _instructionsStepTwoTopView.alpha = 0.9;
    [self.view addSubview:_instructionsStepTwoTopView];

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION___INSTRUCTION_FLASH_PLAYLIST_ICON object:nil];
    
    _instructionsStepTwoView = [[InstructionsStepTwoView alloc] initWithFrame:CGRectMake(0, PLAYER_HEIGHT, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:_instructionsStepTwoView];
}

-(void) instructionsStepThree:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION___INSTRUCTION_SECOND_STEP_COMPLETE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(instructionsStepFour:) name:NOTIFICATION___INSTRUCTION_THIRD_STEP_COMPLETE object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION___INSTRUCTION__STOP__FLASH_PLAYLIST_ICON object:nil userInfo:nil];
    
    [_instructionsStepTwoTopView removeFromSuperview];
    [_instructionsStepTwoView removeFromSuperview];
    
    _instructionsStepThreeTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, PLAYER_HEIGHT)];
    _instructionsStepThreeTopView.backgroundColor = UIColorFromRGB(0x000000);
    _instructionsStepThreeTopView.alpha = 0.6;
    [self.view addSubview:_instructionsStepThreeTopView];
    
    _instructionsStepThreeView = [[InstructionsStepThreeView alloc] initWithFrame:CGRectMake(0, PLAYER_HEIGHT + CELL_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - PLAYER_HEIGHT - CELL_HEIGHT)];
    [self.view addSubview:_instructionsStepThreeView];
}

-(void) instructionsStepFour:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION___INSTRUCTION_THIRD_STEP_COMPLETE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(instructionsStepFive) name:NOTIFICATION___INSTRUCTION_FOURTH_STEP_COMPLETE object:nil];
    
    [_instructionsStepThreeTopView removeFromSuperview];
    [_instructionsStepThreeView removeFromSuperview];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(instructionsStepFive)];
    
    _instructionsStepFourView = [[InstructionsStepFourView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [_instructionsStepFourView addGestureRecognizer:tapGesture];
    [self.view addSubview:_instructionsStepFourView];
}

-(void) instructionsStepFive
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION___INSTRUCTION_FOURTH_STEP_COMPLETE object:nil];
    
    [_instructionsStepFourView removeFromSuperview];
    
    _pageViewController.dataSource = self;
    
    [PlaylistEngine shared].IN_INSTRUCTIONAL_MODE = NO;
}

-(void) playerViewerTap:(UITapGestureRecognizer *)recognizer
{
    if (_isPlayerOpen)
        [[PlaylistEngine shared] playPauseToggle];
    else
        [self openPlayerView];
}

-(void) closeTap:(UITapGestureRecognizer *)recognizer
{
    if (!_isPlayerOpen)
        [[PlaylistEngine shared] playPauseToggle];
    else
        [self closePlayerView];
}

-(void)scrollingBegan:(NSNotification*)note
{
    BOOL isInSearch = NO;
    if (note.userInfo)
    {
       isInSearch = [[note.userInfo objectForKey:@"isInSearch"] boolValue];
    }
    
    [self hideControlPanels:isInSearch];
}

-(void)scrollingEnded:(NSNotification*)note
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showControlPanels) object:nil];
    
    if (note.userInfo)
    {        
        [self performSelector:@selector(showControlPanels) withObject:nil afterDelay:0.7f inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    }
    else
    {
        [self showControlPanels];
    }
}

-(void) notificationShowTopNavigation:(NSNotification*)notification
{
    [self makeControlsVisible];
}

-(void) notificationPlayerHasTracks:(NSNotification*)notification
{
    [self showPlayerView];
}

-(void) notificationPlayerIsEmpty:(NSNotification*)notification
{
    [self hidePlayerView];
}

-(void) hidePlayerView
{
 
    [UIView animateWithDuration:0.3f animations:^
     {
         _playerViewController.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, _playerViewController.view.frame.size.height);
         
     } completion:^(BOOL finished)
     {
        
     }];
}

-(void) showPlayerView
{
    if (_playerViewController.view.frame.origin.y == self.view.frame.size.height && [PlaylistEngine shared].mutablePlaylistArray.count > 0)
    {
        [UIView animateWithDuration:0.3f animations:^
         {
             _playerViewController.view.frame = CGRectMake(0, self.view.frame.size.height - PLAYER_HEIGHT, self.view.frame.size.width, _playerViewController.view.frame.size.height);
         }
          completion:^(BOOL finished)
         {

         }];
    }
}

-(void) showControlPanels
{
    [self makeControlsVisible];
}

-(void) makeControlsVisible
{
    [UIView animateWithDuration:0.3f animations:^
     {
         _topNavigation.view.frame = CGRectMake(0, 0, self.view.frame.size.width, TOP_NAVIGATION_HEIGHT);
         
     } completion:NULL];
    
    [self showPlayerView];
}

-(void) hideControlPanels:(BOOL)hideJustBottom
{
    [UIView animateWithDuration:0.3f animations:^
     {
         if (!hideJustBottom) _topNavigation.view.frame = CGRectMake(0, - CELL_HEIGHT, self.view.frame.size.width, CELL_HEIGHT);
     }
        completion:NULL];
    
    [self hidePlayerView];
}

-(void) searchButtonPressed
{
    [self handleShowSearchTable];
}

-(void) handleShowSearchTable
{
    if (_isPlayerOpen) [self closePlayerView];
    
    // If coming from Playlist and no text in search field - show search icon, other wise show the search field
    if(!_isSearchVCActive)
    {
        __weak ListenNavigationController *weakSelf = self;
        
        if (!_isSearchVCActive)
        {
            [_pageViewController setViewControllers:@[[SearchViewController shared]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished)
             {
                 weakSelf.isSearchVCActive = YES;
             }];
        }
        
        if (_topNavigation.textField.text.length == 0)
        {
            [_topNavigation updateIconsForSearch];
        }
        else
        {
            [_topNavigation updateIconsForSearchTextEntry];
        }
    }
    else
    {
        [_topNavigation updateIconsForSearchTextEntry];
    }
}

-(void)handleShowPlaylistTable
{    
    if (_isPlayerOpen) [self closePlayerView];

    [_topNavigation updateIconsForPlaylist];
    
    if (_isSearchVCActive)
    {
        __weak ListenNavigationController *weakSelf = self;
        
        [_pageViewController setViewControllers:@[[PlaylistViewController shared]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished)
         {
            if (finished)
            {
                weakSelf.isSearchVCActive = NO;
                
                if ([PlaylistEngine shared].IN_INSTRUCTIONAL_MODE)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION___INSTRUCTION_SECOND_STEP_COMPLETE object:nil];
                }
            }
         }];
    }
}

////// Animations

-(void) animateUp
{
    [self openPlayerView];
}

-(void) panGesture:(UIPanGestureRecognizer*)gesture
{
    CGPoint translation = [gesture translationInView:[_playerViewController.view superview]];
    
    CGFloat yPos = _playerViewController.view.frame.origin.y + translation.y;
    
    if (yPos < TOP_NAVIGATION_HEIGHT)
    {
        yPos = TOP_NAVIGATION_HEIGHT;
    }
    
    CGFloat percent = 1 - (yPos - TOP_NAVIGATION_HEIGHT) / self.view.frame.size.height;
  
    _playerViewBackground.alpha = percent;
    
    if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged)
    {
        _playerViewController.view.frame = CGRectMake(0, yPos, _playerViewController.view.frame.size.width, _playerViewController.view.frame.size.height);

        [gesture setTranslation:CGPointZero inView:[_playerViewController.view superview]];
    }
    else if ([gesture state] == UIGestureRecognizerStateEnded)
    {
        CGPoint velocity = [gesture velocityInView:[_playerViewController.view superview]];
        
        if (velocity.y > 0) // down
        {
            [self closePlayerView];
        }
        else // up
        {
            [self openPlayerView];
        }
    }
}

-(void) playlistButtonPressed
{
   [self handleShowPlaylistTable];
}

-(void) playPauseButtonPressed
{
   // [[PlaylistEngine shared] playPauseToggle];
}

-(void) skipNextButtonPressed
{
   // [[PlaylistEngine shared] gotoNextTrack];
}

-(void) skipPreviousButtonPressed
{
   // [[PlaylistEngine shared] gotoPreviousTrack];
}

-(void) openPlayerView
{
    [UIView animateWithDuration:0.3f animations:^
     {
         _playerViewBackground.alpha = 1;
         
         _playerViewController.view.frame = CGRectMake(0, TOP_NAVIGATION_HEIGHT, _playerViewController.view.frame.size.width, _playerViewController.view.frame.size.height);
         
         if (_playerViewController.playerViewState != PlayerViewStateOpen) _playerViewController.playerViewState = PlayerViewStateWillOpen;
         
     }
      completion:^(BOOL finished)
     {
         if (finished)
         {
             [SearchViewController shared].view.userInteractionEnabled = NO;
             [PlaylistViewController shared].view.userInteractionEnabled = NO;
             
             _playerViewController.playerViewState = PlayerViewStateOpen;
             
             _isPlayerOpen = YES;
         }
     }];
}

-(void) closePlayerView
{
    [UIView animateWithDuration:0.3f animations:^
     {
         _playerViewBackground.alpha = 0;
         
         _playerViewController.view.frame = CGRectMake(0, self.view.frame.size.height - PLAYER_HEIGHT, _playerViewController.view.frame.size.width, _playerViewController.view.frame.size.height);
         
        _playerViewController.playerViewState = PlayerViewStateWillClose;
     }
        completion:^(BOOL finished)
     {
        if (finished)
        {
            [SearchViewController shared].view.userInteractionEnabled = YES;
            [PlaylistViewController shared].view.userInteractionEnabled = YES;
            
            _playerViewController.playerViewState = PlayerViewStateClosed;
            
            _isPlayerOpen = NO;
        }
     }];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController;
{
    if ([viewController isEqual:[SearchViewController shared]])
    {
        return nil;
    }
    else if ([viewController isEqual:[PlaylistViewController shared]])
    {
        return [SearchViewController shared];
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if ([viewController isEqual:[SearchViewController shared]])
    {
        return [PlaylistViewController shared];
    }
    else if ([viewController isEqual:[PlaylistViewController shared]])
    {
        return nil;
    }
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (!completed) return;
    
    if ([previousViewControllers containsObject:[PlaylistViewController shared]])
    {
        if (_topNavigation.textField.text.length == 0)
            [_topNavigation updateIconsForSearch];
        else
            [_topNavigation updateIconsForSearchTextEntry];
        
        _isSearchVCActive = YES;
    }
    else if ([previousViewControllers containsObject:[SearchViewController shared]])
    {
        [_topNavigation updateIconsForPlaylist];
        _isSearchVCActive = NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCROLL_START object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCROLL_END object:nil];
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
