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

    NSString *title = self.initialPath.lastPathComponent;
    if ([self.initialPath isEqualToString:[UIApplication documentsDirectoryPath]]) {
        title = @"iTunes";
    }
    self.title = title;
    
    
    NSString *documentsDirectoryPath = [UIApplication documentsDirectoryPath];
    NSArray *documentsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:NULL];
    
    NSMutableArray *fdContents = [NSMutableArray array];
    for (NSString *dirItem in documentsDirectoryContents) {
        OSFileDescriptor *fd = [[OSFileDescriptor alloc] initWithPath:dirItem];
        [fdContents addObject:fd];
    }
    self.contents = fdContents;
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
