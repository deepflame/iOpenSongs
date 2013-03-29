//
//  WebViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/4/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSHtmlViewController.h"

@interface OSHtmlViewController ()
{
}

@property (strong, nonatomic) IBOutlet UIWebView *webView;

- (void) loadHtmlResource;

@end


@implementation OSHtmlViewController

@synthesize resourceURL = _url;
@synthesize webView = _webView;

- (void) setResourceURL:(NSURL *)url
{
    _url = url;
    [self loadHtmlResource];
}

- (void) loadHtmlResource
{
    if (self.webView) {
        NSString *rootPath = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:rootPath];
        
        NSString *htmlDoc = [NSString stringWithContentsOfURL:self.resourceURL 
                                                     encoding:NSUTF8StringEncoding
                                                        error:NULL];
        NSLog(@"%@", htmlDoc);
        [self.webView loadHTMLString:htmlDoc baseURL:baseURL];
    }
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadHtmlResource];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.webView.delegate = self; // setup the delegate as the web view is shown
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.webView stopLoading];   // in case the web view is still loading its content
    self.webView.delegate = nil;  // disconnect the delegate as the webview is hidden
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // we support rotation in this view controller
    return YES;
}


#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // starting the load, show the activity indicator in the status bar
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // finished loading, hide the activity indicator in the status bar
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // load error, hide the activity indicator in the status bar
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // report the error inside the webview
    NSString* errorString = [NSString stringWithFormat:
                             @"<html><center><font size=+5 color='red'>An error occurred:<br>%@</font></center></html>",
                             error.localizedDescription];
    [self.webView loadHTMLString:errorString baseURL:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

@end
