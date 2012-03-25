//
//  RevealSidebarViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/24/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "RevealSidebarController.h"
#import <objc/runtime.h>

@interface RevealSidebarController ()

@end

@implementation RevealSidebarController

//-(void)viewWillAppear:(BOOL)animated
-(void)viewDidLoad
{
    self.rootViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"Detail Navigation Controller"];
    self.leftViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"Main Navigation Controller"];
    
    self.rootViewController.revealSidebarController = self;
    self.leftViewController.revealSidebarController = self;    
    
    [super viewDidLoad];
}

@end



@implementation UIViewController (UIViewRevealSidebarItem) 

@dynamic revealSidebarController;

static const char* revealSidebarControllerKey = "RevealSidebarViewController";

- (RevealSidebarController*)revealSidebarController_core {
    return objc_getAssociatedObject(self, revealSidebarControllerKey);
}

- (RevealSidebarController*)revealSidebarController {
    id result = [self revealSidebarController_core];
    if (!result && self.navigationController) 
        result = [self.navigationController revealSidebarController];
    
    return result;
}

- (void)setRevealSidebarController:(RevealSidebarController*)revealSidebarController {
    objc_setAssociatedObject(self, revealSidebarControllerKey, revealSidebarController, OBJC_ASSOCIATION_RETAIN);
}

@end
