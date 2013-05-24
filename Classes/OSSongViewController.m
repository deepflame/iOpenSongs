//
//  SongViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSSongViewController.h"

#import "OSSupportTableViewController.h"

@interface OSSongViewController () <UIWebViewDelegate, OSSongViewDelegate>
@property (nonatomic, strong) Song *song;
@end

@implementation OSSongViewController

- (id)initWithSong:(Song *)song
{
    self = [super init];
    if (self) {
        _song = song;
    }
    return self;
}

#pragma mark - UIViewController

- (void)loadView
{
    OSSongView *songView = [[OSSongView alloc] init];
    songView.delegate = self;
    songView.song = self.song;
    self.view = songView;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSArray *properties = @[@"nightMode",
                            @"headerVisible", @"chordsVisible", @"lyricsVisible", @"commentsVisible",
                            @"headerSize", @"chordsSize", @"lyricsSize", @"commentsSize"];
    
    [[OSSongStyle defaultStyle] addObserverForKeyPaths:properties
                                            identifier:NSStringFromClass([self class])
                                               options:NSKeyValueObservingOptionNew
                                                  task:^(OSSongStyle *style, NSString *keyPath, NSDictionary *change) {
        [self.songView.songStyle setValue:[style valueForKey:keyPath] forKey:keyPath];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[OSSongStyle defaultStyle] removeObserversWithIdentifier:NSStringFromClass([self class])];
}

#pragma mark - OSSongViewDelegate

- (void)songView:(OSSongView *)sender didChangeSong:(Song *)song
{
    self.title = song.title;
}

#pragma mark - Public Accessors

- (OSSongView *)songView
{
    return (OSSongView *)self.view;
}

@end
