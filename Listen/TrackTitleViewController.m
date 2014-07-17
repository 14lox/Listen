//
//  TrackTitleViewController.m
//  Listen
//
//  Created by Dai Hovey on 22/09/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import "TrackTitleViewController.h"
#import "TitleViewController.h"
#import "PlaylistEngine.h"
#import "TitlePageViewController.h"

@interface TrackTitleViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) TitlePageViewController *pageVC;
@property (nonatomic, strong) TitleViewController *titleViewController;
@property (nonatomic) PlayDirectionState playDirectionState;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic) BOOL isAnimating;
@property (nonatomic, strong) NSMutableArray *viewControllersArray;

@end

@implementation TrackTitleViewController

- (id)init
{
    self = [super init];
    if (self) { }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _viewControllersArray = [NSMutableArray array];
    
    NSDictionary * options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:UIPageViewControllerSpineLocationNone]
                                                         forKey:UIPageViewControllerOptionSpineLocationKey];
    
    _pageVC = [[TitlePageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    _pageVC.view.backgroundColor = [UIColor clearColor];
    _pageVC.delegate = self;
    _pageVC.dataSource = self;
    _pageVC.doubleSided = NO;

    [self addChildViewController:_pageVC];
    [self.view addSubview:_pageVC.view];
    
    _pageVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [_pageVC didMoveToParentViewController:self];
    
    self.view.gestureRecognizers = _pageVC.gestureRecognizers;
    
#warning What was this for??
    // [_pageVC.view.subviews[0] setDelegate:self];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = [_viewControllersArray indexOfObject:viewController];
    if(currentIndex == 0)
        return nil;

    SongObject *songObject = [[PlaylistEngine shared].mutablePlaylistArray objectAtIndex:currentIndex - 1];
    
    TitleViewController *tVC = [_viewControllersArray objectAtIndex:currentIndex - 1];
    [tVC getDataFromMediaItem:songObject.mediaItem];
    
    return tVC;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = [_viewControllersArray indexOfObject:viewController];
    if(currentIndex == _viewControllersArray.count - 1)
        return nil;
    
    TitleViewController *tVC = [_viewControllersArray objectAtIndex:currentIndex + 1];
    
    SongObject *songObject = [[PlaylistEngine shared].mutablePlaylistArray objectAtIndex:currentIndex + 1];
    
    [tVC getDataFromMediaItem:songObject.mediaItem];
    
    return tVC;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (!completed || !finished)
    {
        return;
    }
    else
    {
        if ((unsigned long)((TitleViewController*)[pageViewController.viewControllers objectAtIndex:0]).titleIndex > _currentIndex)
        {
            [[PlaylistEngine shared] gotoNextTrack];
        }
        else if ((unsigned long)((TitleViewController*)[pageViewController.viewControllers objectAtIndex:0]).titleIndex < _currentIndex)
        {
            [[PlaylistEngine shared] gotoPreviousTrack];
        }
    }
}

-(void) populateWithCurrentIndex:(NSInteger)currentIndex didReachEnd:(BOOL)didReachEnd
{
    _currentIndex = currentIndex;
    
    //NSLog(@"populateWithCurrentIndex currentIndex = %li", (long)_currentIndex);
    
    if (didReachEnd)
    {
        [self playNextDidReachEnd:didReachEnd];
    }
    else
    {
        SongObject *songObject = [[PlaylistEngine shared].mutablePlaylistArray objectAtIndex:_currentIndex];
    
        if (_viewControllersArray.count > 0)
            [_viewControllersArray[_currentIndex] getDataFromMediaItem:songObject.mediaItem];
    }
}

-(void) playPrevious
{
    if (_currentIndex > 0 && !_isAnimating)
    {
        _isAnimating = YES;
        
        SongObject *songObject = [[PlaylistEngine shared].mutablePlaylistArray objectAtIndex:_currentIndex - 1];
        
        [_viewControllersArray[_currentIndex - 1]  getDataFromMediaItem:songObject.mediaItem];
        
        __block __weak TrackTitleViewController *weakSelf = self;
        
        [_pageVC setViewControllers:@[_viewControllersArray[_currentIndex - 1] ] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished)
         {
             if (finished)
             {
                 dispatch_async(dispatch_get_main_queue(), ^
                 {
                      // bug fix for uipageview controller
                     [weakSelf.pageVC setViewControllers:@[weakSelf.viewControllersArray[weakSelf.currentIndex - 1] ]
                                               direction:UIPageViewControllerNavigationDirectionReverse
                                                animated:NO
                                              completion:NULL];
                     [[PlaylistEngine shared] gotoPreviousTrack];
                     weakSelf.isAnimating = NO;
                 });
             }
         }];
    }
}

-(void) playNextDidReachEnd:(BOOL)didReachEnd
{
    if (didReachEnd)
    {
        SongObject *songObject = [[PlaylistEngine shared].mutablePlaylistArray objectAtIndex:_currentIndex];
        
        [_viewControllersArray[_currentIndex] getDataFromMediaItem:songObject.mediaItem];
        
        __block __weak TrackTitleViewController *weakSelf = self;
        
        [_pageVC setViewControllers:@[_viewControllersArray[_currentIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished)
         {
             if (finished)
             {
                 dispatch_async(dispatch_get_main_queue(), ^
                {
                    // bug fix for uipageview controller
                    [weakSelf.pageVC setViewControllers:@[weakSelf.viewControllersArray[weakSelf.currentIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
                });
             }
         }];
    }
    
    if (!didReachEnd && !_isAnimating)
    {
        if (_currentIndex + 1  < [PlaylistEngine shared].mutablePlaylistArray.count -1)
        {
            _isAnimating = YES;
            
            SongObject *songObject = [[PlaylistEngine shared].mutablePlaylistArray objectAtIndex:_currentIndex +1];
            
            [_viewControllersArray[_currentIndex] getDataFromMediaItem:songObject.mediaItem];
            
            __block __weak TrackTitleViewController *weakSelf = self;
            
            [_pageVC setViewControllers:@[_viewControllersArray[_currentIndex+1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished)
             {
                if (finished)
                {
                    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       // bug fix for uipageview controller
                       [weakSelf.pageVC setViewControllers:@[weakSelf.viewControllersArray[weakSelf.currentIndex +1]]
                                                 direction:UIPageViewControllerNavigationDirectionForward
                                                  animated:NO
                                                completion:NULL];
                       
                       [[PlaylistEngine shared] gotoNextTrack];
                       weakSelf.isAnimating = NO;
                   });
                }
             }];
        }
    }    
}

-(void) updateViewControllers
{
    [_viewControllersArray removeAllObjects];
    
    [[PlaylistEngine shared].mutablePlaylistArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         _titleViewController = [[TitleViewController alloc] init];
         _titleViewController.titleIndex = idx;
         [_viewControllersArray addObject:_titleViewController];
     }];
}

-(void) refreshWithCurrentIndex:(NSInteger)currentIndex
{
    [self updateViewControllers];
    
    SongObject *songObject = [[PlaylistEngine shared].mutablePlaylistArray objectAtIndex:currentIndex];
    
    // NSLog(@"[PlaylistEngine shared].mutablePlaylistArray = %@", [PlaylistEngine shared].mutablePlaylistArray);
    // NSLog(@"_currentIndex                                = %i", _currentIndex);
    
    [_viewControllersArray[currentIndex] getDataFromMediaItem:songObject.mediaItem];
    
    [_pageVC setViewControllers:@[_viewControllersArray[currentIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end