//
//  OSSetViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 4/8/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSSetViewController.h"
#import <SYPaginator/SYPaginator.h>

#import "OSSongPageView.h"
#import "SetItemSong.h"

#import "NSObject+RuntimeAdditions.h"

@interface OSSetViewController () <SYPaginatorViewDataSource, SYPaginatorViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, readonly) SYPaginatorView *paginatorView;
@end

@implementation OSSetViewController

#pragma mark - UIViewController

- (void)loadView
{
    SYPaginatorView *paginator = [[SYPaginatorView alloc] initWithFrame:CGRectZero];
    paginator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    paginator.dataSource = self;
    paginator.delegate = self;
    paginator.pageGapWidth = 1.0f;
    paginator.numberOfPagesToPreload = 2;
    
    paginator.scrollView.alwaysBounceHorizontal = (paginator.paginationDirection == SYPageViewPaginationDirectionVertical);
    paginator.scrollView.alwaysBounceVertical = (paginator.paginationDirection == SYPageViewPaginationDirectionHorizontal);
    paginator.scrollView.directionalLockEnabled = YES;
    
    self.view = paginator;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // for iOS 7 (view behind navigation bar)
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        //self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    // add single tap to scroll view
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc ]initWithTarget:self action:@selector(handleSingleTapGesture:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    singleTapGestureRecognizer.cancelsTouchesInView = YES;
    singleTapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:singleTapGestureRecognizer];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
    return YES;
}

#pragma mark - SYPaginatorViewDelegate

- (void)paginatorView:(SYPaginatorView *)paginatorView didScrollToPageAtIndex:(NSInteger)pageIndex
{
    // only if pageIndex is valid
    if (pageIndex < 0) {
        self.title = @"";
        return; // <-- !!
    }
    
    // FIXME: setitem positions not consistent...
    NSArray *setItems = [SetItem MR_findAllSortedBy:@"position" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"set == %@", self.set]];
    SetItem *setItem = setItems[pageIndex];
    
    // set the title
    if ([setItem isMemberOfClass:[SetItemSong class]]) {
        SetItemSong *songItem = (SetItemSong *)setItem;
        self.title = songItem.song.title;
    }
}

- (void)paginatorView:(SYPaginatorView *)paginatorView willDisplayView:(UIView *)view atIndex:(NSInteger)pageIndex
{
    // only if pageIndex is valid
    if (pageIndex < 0) {
        return; // <-- !!
    }
    
    if ([view isKindOfClass:[OSSongPageView class]]) {
        // observe default song style (from settings)
        [[OSSongStyle defaultStyle] bk_removeObserversWithIdentifier:NSStringFromClass([self class])];
        [[OSSongStyle defaultStyle] bk_addObserverForKeyPaths:[[OSSongStyle defaultStyle] propertyNames]
                                                identifier:NSStringFromClass([self class])
                                                   options:NSKeyValueObservingOptionInitial
                                                      task:^(OSSongStyle *style, NSString *keyPath, NSDictionary *change) {
            [((OSSongPageView *)view).songView.songStyle setValue:[style valueForKey:keyPath] forKey:keyPath];
        }];
    }
    
    // FIXME: setitem positions not consistent...
    NSArray *setItems = [SetItem MR_findAllSortedBy:@"position" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"set == %@", self.set]];
    SetItem *setItem = setItems[pageIndex];
    
    [self.delegate setViewController:self didChangeToSetItem:setItem atIndex:pageIndex];
}

#pragma mark - SYPaginatorViewDataSource

- (NSInteger)numberOfPagesForPaginatorView:(SYPaginatorView *)paginatorView
{
    return [self.set.items count];
}

- (SYPageView *)paginatorView:(SYPaginatorView *)paginatorView viewForPageAtIndex:(NSInteger)pageIndex
{
    // FIXME: setitem positions not consistent...
    NSArray *setItems = [SetItem MR_findAllSortedBy:@"position" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"set == %@", self.set]];
    SetItem *setItem = setItems[pageIndex];
    
    if ([setItem isMemberOfClass:[SetItemSong class]]) {
        static NSString *songIdentifier = @"songPageView";
        OSSongPageView *songPageView = (OSSongPageView *)[paginatorView dequeueReusablePageWithIdentifier:songIdentifier];
        
        if (!songPageView) {
            songPageView = [[OSSongPageView alloc] initWithReuseIdentifier:songIdentifier];
        }
        
        Song *song = [(SetItemSong *)setItem song];
        songPageView.songView.song = song;
        return songPageView;
    } else {
        // this should never happen (yet)
    }
    
    return nil;
}

#pragma mark - Private Methods

- (void)handleSingleTapGesture:(UITapGestureRecognizer *)sender
{
    CGPoint tapLocation = [sender locationInView:self.view];
    
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat tapSpace = viewWidth * 0.3; // take 30% off the whole width for one tapping area
    
    NSInteger currentPageIndex = self.paginatorView.currentPageIndex;
    
    if (tapLocation.x < tapSpace) {
        // tapped left
        if (currentPageIndex > 0) {
            self.paginatorView.currentPageIndex = currentPageIndex - 1;
        }
    } else if (tapLocation.x > viewWidth - tapSpace) {
        // tapped right
        if (currentPageIndex < self.paginatorView.numberOfPages - 1) {
            self.paginatorView.currentPageIndex = currentPageIndex + 1;
        }
    }
    
}

#pragma mark - Public Methods

- (void)selectPageAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    [self.paginatorView setCurrentPageIndex:index animated:animated];
}

#pragma mark - Public Accessors

- (void)setSet:(Set *)set
{
    if (_set != set) {
        _set = set;

        [self.paginatorView setCurrentPageIndex:0 animated:NO]; // hack to preload first time
        [self.paginatorView reloadData];
        [self.paginatorView setCurrentPageIndex:-1 animated:NO];
    }
}

- (SYPaginatorView *)paginatorView
{
    return (SYPaginatorView *)self.view;
}

@end
