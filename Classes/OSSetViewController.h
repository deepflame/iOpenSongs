//
//  OSSetViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 4/8/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSDetailViewController.h"

#import "OSSetViewControllerDelegate.h"
#import "Set.h"

@interface OSSetViewController : OSDetailViewController

- (void)selectPageAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)reloadSet;

@property (nonatomic, strong) Set *set;
@property (nonatomic, weak) id<OSSetViewControllerDelegate>delegate;

@end
