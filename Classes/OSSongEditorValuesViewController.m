//
//  OSSongOptionsViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 1/3/14.
//  Copyright (c) 2014 Andreas Boehrnsen. All rights reserved.
//

#import "OSSongEditorValuesViewController.h"


@interface OSSongEditorValuesViewController () <OSSongEditorViewControllerDelegate>
@property (nonatomic, strong) Song *song;
@end

@implementation OSSongEditorValuesViewController

- (id)initWithSong:(Song *)song
{
    self = [super init];
    if (self) {
        UIBarButtonItem *saveBarButton = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemSave handler:^(id sender) {
            //self.song.lyrics = self.textView.text;
            [self.delegate songEditorViewController:self finishedEditingSong:self.song];
        }];
        UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemCancel handler:^(id sender) {
            [self.delegate songEditorViewController:self finishedEditingSong:self.song];
        }];
        self.navigationItem.leftBarButtonItems = @[saveBarButton, cancelBarButton];
        self.song = song;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 

- (void)songEditorViewController:(OSSongEditorLyricsViewController *)sender finishedEditingSong:(Song *)song
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
