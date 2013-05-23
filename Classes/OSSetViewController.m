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

@interface OSSetViewController () <SYPaginatorViewDataSource, SYPaginatorViewDelegate>
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

#pragma mark - SYPaginatorViewDelegate

- (void)paginatorView:(SYPaginatorView *)paginatorView didScrollToPageAtIndex:(NSInteger)pageIndex
{
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

#pragma mark - Public Methods

- (void)selectPageAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    [self.paginatorView setCurrentPageIndex:index animated:animated];
}

#pragma mark - Public Accessors

- (void)setSet:(Set *)set
{
    if (_set != set) {
        // remove observer from old instance
        if (_set) {
            [_set removeAllBlockObservers];
        }
        
        _set = set;
        
        SYPaginatorView *pv = self.paginatorView;
        [_set addObserverForKeyPath:@"items" task:^(NSObject *receiver) {
            [pv reloadData];
        }];
        [pv reloadData];
    }
}

- (SYPaginatorView *)paginatorView
{
    return (SYPaginatorView *)self.view;
}

@end
