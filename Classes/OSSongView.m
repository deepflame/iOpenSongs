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
    } else {
        [self displayIntro];
    }
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
    NSString* jsString = [NSString stringWithFormat:@"$('#lyrics').openSongLyrics(\"%@\");", [self.song.lyrics escapeJavaScript]];
    [self.songWebView stringByEvaluatingJavaScriptFromString:jsString];
    
    [self applySongStyle];
}

- (void)displayIntro
{
    if (! [self introPartialString]) {
        return; // no partial found
    }
    
    NSString* jsString = [NSString stringWithFormat:@"$('#intro').append(\"%@\");", [[self introPartialString] escapeJavaScript]];
    [self.songWebView stringByEvaluatingJavaScriptFromString:jsString];
}

- (void)loadHtmlTemplate
{
    NSString *rootPath = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:rootPath];
    
    NSURL *templateUrl = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
    NSString *htmlDoc = [NSString stringWithContentsOfURL:templateUrl
                                                 encoding:NSUTF8StringEncoding
                                                    error:nil];
    [self.songWebView loadHTMLString:htmlDoc baseURL:baseURL];
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
    
    [songStyle removeAllBlockObservers];
    
    // night mode
    [songStyle addObserverForKeyPath:@"nightMode"
                          identifier:@"nightMode"
                             options:NSKeyValueObservingOptionInitial
                                task:^(OSSongStyle *style, NSDictionary *change) {
        [self setNightMode:style.nightMode];
    }];
    // visibility
    [songStyle addObserverForKeyPath:@"headerVisible"
                          identifier:@"headerVisible"
                             options:NSKeyValueObservingOptionInitial
                                task:^(OSSongStyle *style, NSDictionary *change) {
        [self setStyleVisible:style.headerVisible withCSSSelector:@".opensong h2"];
    }];
    [songStyle addObserverForKeyPath:@"chordsVisible"
                          identifier:@"chordsVisible"
                             options:NSKeyValueObservingOptionInitial
                                task:^(OSSongStyle *style, NSDictionary *change) {
        [self setStyleVisible:style.chordsVisible withCSSSelector:@".opensong .chords"];
    }];
    [songStyle addObserverForKeyPath:@"lyricsVisible"
                          identifier:@"lyricsVisible"
                             options:NSKeyValueObservingOptionInitial
                                task:^(OSSongStyle *style, NSDictionary *change) {
        [self setStyleVisible:style.lyricsVisible withCSSSelector:@".opensong .lyrics"];
    }];
    [songStyle addObserverForKeyPath:@"commentsVisible"
                          identifier:@"commentsVisible"
                             options:NSKeyValueObservingOptionInitial
                                task:^(OSSongStyle *style, NSDictionary *change) {
        [self setStyleVisible:style.commentsVisible withCSSSelector:@".opensong .comments"];
    }];
    // size
    [songStyle addObserverForKeyPath:@"headerSize"
                          identifier:@"headerSize"
                             options:NSKeyValueObservingOptionInitial
                                task:^(OSSongStyle *style, NSDictionary *change) {
        [self setStyleSize:style.headerSize withCSSSelector:@".opensong h2"];
    }];
    [songStyle addObserverForKeyPath:@"chordsSize"
                          identifier:@"chordsSize"
                             options:NSKeyValueObservingOptionInitial
                                task:^(OSSongStyle *style, NSDictionary *change) {
        [self setStyleSize:style.chordsSize withCSSSelector:@".opensong .chords"];
    }];
    [songStyle addObserverForKeyPath:@"lyricsSize"
                          identifier:@"lyricsSize"
                             options:NSKeyValueObservingOptionInitial
                                task:^(OSSongStyle *style, NSDictionary *change) {
        [self setStyleSize:style.lyricsSize withCSSSelector:@".opensong .lyrics"];
    }];
    [songStyle addObserverForKeyPath:@"commentsSize"
                          identifier:@"commentsSize"
                             options:NSKeyValueObservingOptionInitial
                                task:^(OSSongStyle *style, NSDictionary *change) {
        [self setStyleSize:style.commentsSize withCSSSelector:@".opensong .comments"];
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
        _songStyle = [[OSSongStyle alloc] init];
    }
    return _songStyle;
}

@end
