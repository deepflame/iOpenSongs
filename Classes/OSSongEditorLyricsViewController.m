//
//  OSSongEditorViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/20/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSSongEditorLyricsViewController.h"

@interface OSSongEditorLyricsViewController ()
@property (nonatomic, strong) Song *song;
@property (nonatomic, strong) UITextView *textView;
@end

@implementation OSSongEditorLyricsViewController

- (id)initWithSong:(Song *)song
{
    self = [super init];
    if (self) {
        self.song = song;
        
        UIBarButtonItem *saveBarButton = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemSave handler:^(id sender) {
            self.song.lyrics = self.textView.text;
            [self.delegate songEditorViewController:self finishedEditingSong:self.song];
        }];
        UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemCancel handler:^(id sender) {
            [self.delegate songEditorViewController:self finishedEditingSong:self.song];
        }];
        
        self.navigationItem.leftBarButtonItems = @[saveBarButton, cancelBarButton];
    }
    return self;
}

- (void)loadView
{
    self.view = self.textView;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.song.title;
    self.textView.text = self.song.lyrics;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Accessor Implementations

- (UITextView *)textView
{
    if (! _textView) {
        _textView = [[UITextView alloc] init];
    }
    return _textView;
}

@end
