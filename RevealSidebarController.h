//
//  RevealSidebarViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/24/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDMenuController.h"

@interface RevealSidebarController : DDMenuController

@end

// category on UIViewController to provide access to the RevealSidebarViewController in the 
// contained viewcontrollers, a la UINavigationController.
@interface UIViewController (UIViewRevealSidebarItem) 

@property(nonatomic ,retain) RevealSidebarController *revealSidebarController; 

@end