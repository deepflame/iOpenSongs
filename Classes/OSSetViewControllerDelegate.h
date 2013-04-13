//
//  OSSetViewControllerDelegate.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 4/13/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSSetViewController;
@class SetItem;

@protocol OSSetViewControllerDelegate <NSObject>
- (void)setViewController:(OSSetViewController *)sender didChangeToSetItem:(SetItem *)setItem atIndex:(NSUInteger)index;
@end
