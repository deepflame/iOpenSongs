//
//  SongViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSSongViewController.h"

#import "OSSongView.h"

#import "OSSupportTableViewController.h"

#import "NSObject+RuntimeAdditions.h"

@interface OSSongViewController () <UIWebViewDelegate, OSSongViewDelegate>

@end

@implementation OSSongViewController

- (id)init
{
    self = [super init];
    if (self) {
    }
    // state restoration (iOS6)
    if ([self respondsToSelector:@selector(restorationIdentifier)]) {
        self.restorationIdentifier = NSStringFromClass([self class]);
    }
    return self;
}

#pragma mark - UIViewController

- (void)loadView
{
    OSSongView *songView = [[OSSongView alloc] init];
    songView.delegate = self;
    songView.song = self.song;
    songView.introPartialName = self.introPartialName;
    self.view = songView;
}

- (void)viewWillAppear:(BOOL)animated
{
    // observe default song style (from settings)
    [[OSSongStyle defaultStyle] bk_addObserverForKeyPaths:[[OSSongStyle defaultStyle] propertyNames]
                                            identifier:NSStringFromClass([self class])
                                               options:NSKeyValueObservingOptionNew
                                                  task:^(OSSongStyle *style, NSString *keyPath, NSDictionary *change) {
        [self.songView.songStyle setValue:[style valueForKey:keyPath] forKey:keyPath];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[OSSongStyle defaultStyle] bk_removeObserversWithIdentifier:NSStringFromClass([self class])];
}

#pragma mark - OSSongViewDelegate

- (void)songView:(OSSongView *)sender didChangeSong:(Song *)song
{
    self.title = song.title;
}

#pragma mark - Private Methods

- (OSSongView *)songView
{
    return (OSSongView *)self.view;
}

#pragma mark - Public Accessors

- (void)setSong:(Song *)song
{
    if (_song != song) {
        _song = song;
    }
    if (self.view) {
        self.songView.song = song;
    }
}

#pragma mark - State Restoration

#define kSongTitleKey @"SongTitle"

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.song.title forKey:kSongTitleKey];
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSString *songTitle = [coder decodeObjectForKey:kSongTitleKey];
    Song *song = [Song MR_findFirstByAttribute:@"title" withValue:songTitle];
    self.song = song;
    
    [super decodeRestorableStateWithCoder:coder];
}

@end
