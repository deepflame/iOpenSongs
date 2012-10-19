//
//  RevealSidebarViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/24/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "RevealSidebarController.h"

@interface RevealSidebarController ()

@end

@implementation RevealSidebarController

-(void)viewDidLoad
{
    [super viewDidLoad];

    self.topViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"TopView"];
    self.underLeftViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"Sidebar"];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.anchorRightRevealAmount = 305.0;
        self.underLeftWidthLayout = ECFixedRevealWidth;
    } else {
        self.anchorRightRevealAmount = 320.0;
        self.underLeftWidthLayout = ECFixedRevealWidth;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // draw shadow
    UIView *topView = self.topViewController.view;
    topView.layer.shadowOffset = CGSizeZero;
    topView.layer.shadowOpacity = 0.8f;
    topView.layer.shadowRadius = 4.0f;
    topView.layer.shadowColor = [UIColor blackColor].CGColor;
    topView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
    topView.clipsToBounds = NO;
    
    [self.topViewController.view addGestureRecognizer:self.panGesture];
}
    
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    return [self.topViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

@end