//
//  UIAlertView+Error.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/2/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "UIAlertView+Error.h"

@implementation UIAlertView (Error)

+ (UIAlertView *)showWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                    message:[error localizedRecoverySuggestion]
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
                                          otherButtonTitles:nil];
    
    [alert show];
    return alert;
}

@end
