//
//  FRLayeredNavigationController+ExposePrivate.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/17/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "FRLayeredNavigationController.h"

@interface FRLayeredNavigationController (ExposePrivate)

- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer;

@property (nonatomic, readwrite, strong) NSMutableArray *layeredViewControllers;

@end
