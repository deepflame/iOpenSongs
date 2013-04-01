//
//  OSSupportViewControllerDelegate.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 4/1/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OSSupportViewControllerDelegate <NSObject>
- (void)dismissSupportPopoverAnimated:(BOOL)animated;
@end
