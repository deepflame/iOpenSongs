//
//  UIManagedDocument+Use.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/12/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIManagedDocument (Use)

- (void)useWithCompletionHandler:(void (^)(BOOL success))completionHandler;

@end
