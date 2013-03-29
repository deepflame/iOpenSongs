//
//  OSImportTableViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/23/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSFileDescriptor.h"

@interface OSImportTableViewController : UITableViewController

- (id)initWithPath:(NSString *)path;

@property (nonatomic, strong) NSArray *contents;
@property (nonatomic, strong) NSMutableArray *selectedContents;
@property (nonatomic, strong, readonly) NSString *initialPath;

@end