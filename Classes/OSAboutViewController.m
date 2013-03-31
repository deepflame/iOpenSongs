//
//  WebViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/4/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSAboutViewController.h"
#import "OSHtmlView.h"

@interface OSAboutViewController ()
@end

@implementation OSAboutViewController

#pragma mark - UIViewController

- (NSString *)title
{
    return @"About";
}

- (void)loadView
{
    OSHtmlView *htmlView = [[OSHtmlView alloc] init];
    htmlView.resourceURL = [[NSBundle mainBundle] URLForResource:@"about" withExtension:@"html"];
    self.view = htmlView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
