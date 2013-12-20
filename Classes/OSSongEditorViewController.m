//
//  OSSongEditorViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/20/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSSongEditorViewController.h"

@interface OSSongEditorViewController ()
@property (nonatomic, strong) UITextView *textView;
@end

@implementation OSSongEditorViewController

- (id)init
{
    self = [super init];
    if (self) {
        
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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Accessor Implementations

- (void)setSong:(Song *)song
{
    if (_song != song) {
        _song = song;
        self.textView.text = _song.lyrics;
    }
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
