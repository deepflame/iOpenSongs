//
//  OSSongView.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/31/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSSongView.h"

#import "NSString+JavaScript.h"

@interface OSSongView () <UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *songWebView;
@end

@implementation OSSongView

@synthesize songStyle = _songStyle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code        
        self.songWebView = [[UIWebView alloc] initWithFrame:self.bounds];
        self.songWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.songWebView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        self.songWebView.delegate = self;
        
        [self addSubview:self.songWebView];
        
        [self loadHtmlTemplate];
    }
    return self;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (self.song) {
        [self displaySong];
        return; // <-- !!
    }
    
    if ([self introPartialString]) {
        [self displayIntro];
        return; // <-- !!
    }
    
    self.songWebView.hidden = YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

#pragma mark - Private Methods

- (void)displaySong
{    
    NSString* jsString = [NSString stringWithFormat:@"new opensong.Song($('#lyrics'), \"%@\");", [self.song.lyrics escapeJavaScript]];
    [self.songWebView stringByEvaluatingJavaScriptFromString:jsString];
    
    [self applySongStyle];
    
    self.songWebView.hidden = NO; // unhide webview
}

- (void)displayIntro
{
    NSString* jsString = [NSString stringWithFormat:@"$('#intro').append(\"%@\");", [[self introPartialString] escapeJavaScript]];
    [self.songWebView stringByEvaluatingJavaScriptFromString:jsString];
    
    self.songWebView.hidden = NO; // unhide webview
}

- (void)loadHtmlTemplate
{
    NSURL *templateUrl = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:templateUrl];
    [self.songWebView loadRequest:request];
}

- (NSString *)introPartialString
{
    NSString *partialFileBase = [NSString stringWithFormat:@"_%@", self.introPartialName];
    
    NSURL *templateUrl = [[NSBundle mainBundle] URLForResource:partialFileBase withExtension:@"html"];
    NSString *htmlPartial = [NSString stringWithContentsOfURL:templateUrl
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    return htmlPartial;
}

- (void)setNightMode:(BOOL)state
{
    if (state == YES) {
        [self.songWebView stringByEvaluatingJavaScriptFromString:@"$('body').addClass('nightmode');"];
    } else {
        [self.songWebView stringByEvaluatingJavaScriptFromString:@"$('body').removeClass('nightmode');"];
    }
}

-(void)setStyleVisible:(BOOL)isVisible withCSSSelector:(NSString *)cssSel
{
    if (isVisible) {
        [self.songWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"$('%@').show();", cssSel]];
    } else {
        [self.songWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"$('%@').hide();", cssSel]];
    }
}

-(void)setStyleSize:(int)size withCSSSelector:(NSString *)cssSel
{
    NSString *js = [NSString stringWithFormat:@"$('%@').css('font-size', '%dpx');", cssSel, size];
    [self.songWebView stringByEvaluatingJavaScriptFromString:js];
}

- (void) applySongStyle
{
    OSSongStyle *songStyle = self.songStyle;
    
    [songStyle bk_removeAllBlockObservers];
    
    // night mode
    [songStyle bk_addObserverForKeyPath:@"nightMode"
                          identifier:@"nightMode"
                             options:NSKeyValueObservingOptionInitial
                                task:^(OSSongStyle *style, NSDictionary *change) {
        [self setNightMode:style.nightMode];
    }];

    // visibility and size
    [@[@"header", @"chords", @"lyrics", @"comments"] bk_each:^(NSString *part) {
        NSString *cssSel = [@".opensong ." stringByAppendingString:part];

        // visible
        NSString* key = [part stringByAppendingString:@"Visible"];
        [songStyle bk_addObserverForKeyPath:key
                              identifier:key
                                 options:NSKeyValueObservingOptionInitial
                                    task:^(OSSongStyle *style, NSDictionary *change) {
                                        BOOL isVisible = [[style valueForKey:key] boolValue];
                                        [self setStyleVisible:isVisible withCSSSelector:cssSel];
                                    }];
        
        // size
        key = [part stringByAppendingString:@"Size"];
        [songStyle bk_addObserverForKeyPath:key
                              identifier:key
                                 options:NSKeyValueObservingOptionInitial
                                    task:^(OSSongStyle *style, NSDictionary *change) {
                                        int size = [[style valueForKey:key] intValue];
                                        [self setStyleSize:size withCSSSelector:cssSel];
                                    }];
    }];
}

#pragma mark - Public Accessors

- (void)setSong:(Song *)song
{
    if (_song != song) {
        _song = song;
        
        [self.delegate songView:self didChangeSong:_song];
        
        [self displaySong];
    }
}

- (OSSongStyle *)songStyle
{
    if (! _songStyle) {
        _songStyle = [[OSSongStyle defaultStyle] copy];
    }
    return _songStyle;
}

@end
