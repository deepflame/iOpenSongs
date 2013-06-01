//
//  OSImportTableViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/23/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD.h>

#import "Song+Import.h"
#import "OSFileDescriptor.h"

#import "OSImportTableViewControllerDelegate.h"

@interface OSImportTableViewController : UITableViewController

- (id)initWithPath:(NSString *)path;
- (void)importAllSelectedItems;
- (void)handleImportErrors;

@property (nonatomic, weak) id<OSImportTableViewControllerDelegate> delegate;

@property (nonatomic, strong) NSArray *contents;
@property (nonatomic, strong, readonly) NSSet *selectedContents;
@property (nonatomic, strong) NSMutableArray *importErrors;
@property (nonatomic, strong, readonly) NSString *initialPath;

@property (nonatomic, strong) MBProgressHUD *hud;

@end
