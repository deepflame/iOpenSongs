//
//  UIAlertView+Error.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/2/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Error)

+ (UIAlertView *)showWithError:(NSError *)error;

@end
