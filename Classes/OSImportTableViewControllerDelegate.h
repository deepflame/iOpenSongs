//
//  OSImportTableViewControllerDelegate.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 6/1/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSImportTableViewController;

@protocol OSImportTableViewControllerDelegate <NSObject>
- (void)importTableViewController:(OSImportTableViewController *)sender finishedImportWithErrors:(NSArray *)errors;
@end
