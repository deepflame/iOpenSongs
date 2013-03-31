//
//  WebViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/4/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSHtmlViewController.h"
#import "OSHtmlView.h"

@interface OSHtmlViewController ()
@end

@implementation OSHtmlViewController

#pragma mark - UIViewController

- (NSString *)title
{
    return @"About";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    OSHtmlView *htmlView = [[OSHtmlView alloc] initWithFrame:self.view.bounds];
    htmlView.resourceURL = [[NSBundle mainBundle] URLForResource:@"about" withExtension:@"html"];
    htmlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:htmlView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
