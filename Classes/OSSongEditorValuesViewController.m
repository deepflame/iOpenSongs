//
//  OSSongOptionsViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 1/3/14.
//  Copyright (c) 2014 Andreas Boehrnsen. All rights reserved.
//

#import "OSSongOptionsViewController.h"

@interface OSSongOptionsViewController ()

@end

@implementation OSSongOptionsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
