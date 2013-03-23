//
//  OSITunesImportTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/23/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSITunesImportTableViewController.h"

#import "UIApplication+Directories.h"

@interface OSITunesImportTableViewController ()

@end

@implementation OSITunesImportTableViewController

- (id)init
{
    return [self initWithPath:[UIApplication documentsDirectoryPath]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
