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

@end

@implementation OSSetViewController

#pragma mark - SYPaginatorViewDelegate

- (void)paginatorView:(SYPaginatorView *)paginatorView didScrollToPageAtIndex:(NSInteger)pageIndex
{
    
}

-(void)paginatorView:(SYPaginatorView *)paginatorView willDisplayView:(UIView *)view atIndex:(NSInteger)pageIndex
{
    NSLog(@"will display view at index: %i", pageIndex + 1);
}


#pragma mark - SYPaginatorViewDataSource

- (NSInteger)numberOfPagesForPaginatorView:(SYPaginatorView *)paginatorView
{
    return [self.set.items count];
}

- (SYPageView *)paginatorView:(SYPaginatorView *)paginatorView viewForPageAtIndex:(NSInteger)pageIndex
{
    SetItem *setItem = [[self.set.items allObjects] objectAtIndex:pageIndex - 1];
    
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



@end
