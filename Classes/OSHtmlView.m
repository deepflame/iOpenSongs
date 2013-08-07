//
//  OSHtmlView.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/31/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSHtmlView.h"

@interface OSHtmlView () <UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *webView;
@end

@implementation OSHtmlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.webView = [[UIWebView alloc] initWithFrame:self.bounds];
        self.webView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.webView.delegate = self;
        
        [self addSubview:self.webView];
    }
    return self;
}

#pragma mark - UIWebViewDelegate

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

#pragma mark - Private Methods

- (void) loadHtmlResource
{
    if (self.webView) {
        NSString *rootPath = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:rootPath];
        
        NSString *htmlDoc = [NSString stringWithContentsOfURL:self.resourceURL
                                                     encoding:NSUTF8StringEncoding
                                                        error:NULL];
        [self.webView loadHTMLString:htmlDoc baseURL:baseURL];
    }
}

#pragma mark - Public Accessor Overrides

- (void) setResourceURL:(NSURL *)url
{
    _resourceURL = url;
    [self loadHtmlResource];
}

@end
