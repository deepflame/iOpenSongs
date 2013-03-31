//
//  OSSongView.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/31/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSSongView.h"

#import "NSString+JavaScript.h"

#define USER_DEFAULTS_KEY_NIGHT_MODE @"SongViewController.nightMode"
#define USER_DEFAULTS_KEY_SONG_STYLE @"SongViewController.songStyle"

@interface OSSongView () <UIWebViewDelegate>
@property (nonatomic, strong) NSMutableDictionary *songStyle;
@property (nonatomic, strong) UIWebView *songWebView;
@end

@implementation OSSongView

@synthesize song = _song;
@synthesize songStyle =_songStyle;
@synthesize songWebView = _songWebView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.songWebView = [[UIWebView alloc] initWithFrame:self.bounds];
        self.songWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.songWebView.delegate = self;
        
        [self addSubview:self.songWebView];
        
        [self loadHtmlTemplate];
    }
    return self;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.nightMode = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_NIGHT_MODE] boolValue];
    self.songStyle = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_SONG_STYLE];
    [self displaySong]; // if song present
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

#pragma mark - Public Methods

- (void) resetSongStyle
{
    [self setSongStyle:nil];
}

#pragma mark - Private Methods

- (void)displaySong
{
    if (self.song) {
        NSString *songLyrics = self.song.lyrics;
        NSString* jsString = [NSString stringWithFormat:@"$('#lyrics').openSongLyrics(\"%@\");", [self.song.lyrics escapeJavaScript]];
        [self.songWebView stringByEvaluatingJavaScriptFromString:jsString];
        
        // FIXME
        //self.navigationItem.title = self.song.title;
        
        // reset style
        //[self setSongStyle:self.songStyle];
    }
}

- (void)loadHtmlTemplate
{
    NSString *rootPath = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:rootPath];
    
    NSURL *templateUrl = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
    NSString *htmlDoc = [NSString stringWithContentsOfURL:templateUrl
                                                 encoding:NSUTF8StringEncoding
                                                    error:NULL];
    [self.songWebView loadHTMLString:htmlDoc baseURL:baseURL];
}

#pragma mark - Public Accessor Overrides

- (void)setSong:(Song *)song
{
    if (_song != song) {
        _song = song;
        
        // Update the view.
        [self displaySong];
    }
}

- (void)setNightMode:(BOOL)state
{
    if (state == YES) {
        [self.songWebView stringByEvaluatingJavaScriptFromString:@"$('body').addClass('nightmode');"];
    } else {
        [self.songWebView stringByEvaluatingJavaScriptFromString:@"$('body').removeClass('nightmode');"];
    }
    
    // save user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:self.nightMode] forKey:USER_DEFAULTS_KEY_NIGHT_MODE];
    [defaults synchronize];
}

- (BOOL)nightMode
{
    return [[self.songWebView stringByEvaluatingJavaScriptFromString:@"$('body').hasClass('nightmode');"] isEqualToString:@"true"];
}

// -- Song Style: Visibiliy

-(void)setStyleVisible:(BOOL)isVisible forKey:(NSString *)key withCSSSelector:(NSString *)cssSel
{
    BOOL valueChanged = NO;
    if (isVisible != [self styleVisibleForKey:key]) {
        valueChanged = YES;
    }
    
    if (isVisible) {
        [self.songWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"$('%@').show();", cssSel]];
    } else {
        [self.songWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"$('%@').hide();", cssSel]];
    }
    [self.songStyle setObject:[NSNumber numberWithBool:isVisible] forKey:key];
    
    // save user defaults if changed
    if (valueChanged) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.songStyle forKey:USER_DEFAULTS_KEY_SONG_STYLE];
        [defaults synchronize];
    }
}

-(BOOL)styleVisibleForKey:(NSString *)key
{
    NSNumber *isVisibleNum = [self.songStyle objectForKey:key];
    if (isVisibleNum) {
        return isVisibleNum.boolValue;
    }
    return YES; // visible by default
}

-(void)setHeaderVisible:(BOOL)headerVisible
{
    [self setStyleVisible:headerVisible forKey:@"headerVisible" withCSSSelector:@"body .opensong h2"];
}

-(BOOL)headerVisible
{
    return [self styleVisibleForKey:@"headerVisible"];
}

-(void)setChordsVisible:(BOOL)chordsVisible
{
    [self setStyleVisible:chordsVisible forKey:@"chordsVisible" withCSSSelector:@"body .opensong .chords"];
}

-(BOOL)chordsVisible
{
    return [self styleVisibleForKey:@"chordsVisible"];
}

-(void)setLyricsVisible:(BOOL)lyricsVisible
{
    [self setStyleVisible:lyricsVisible forKey:@"lyricsVisible" withCSSSelector:@"body .opensong .lyrics"];
}

-(BOOL)lyricsVisible
{
    return [self styleVisibleForKey:@"lyricsVisible"];
}

-(void)setCommentsVisible:(BOOL)commentsVisible
{
    [self setStyleVisible:commentsVisible forKey:@"commentsVisible" withCSSSelector:@"body .opensong .comments"];
}

-(BOOL)commentsVisible
{
    return [self styleVisibleForKey:@"commentsVisible"];
}

// -- Song Style: Size

-(void)setStyleSize:(int)size forKey:(NSString *)key withCSSSelector:(NSString *)cssSel
{
    BOOL valueChanged = NO;
    if (size != [self styleSizeForKey:key defaultsTo:size]) {
        valueChanged = YES;
    }
    
    NSString *js = [NSString stringWithFormat:@"$('%@').css('font-size', '%dpx');", cssSel, size];
    [self.songWebView stringByEvaluatingJavaScriptFromString:js];
    [self.songStyle setObject:[NSNumber numberWithInt:size] forKey:key];
    
    // save user defaults if changed
    if (valueChanged) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.songStyle forKey:USER_DEFAULTS_KEY_SONG_STYLE];
        [defaults synchronize];
    }
}

-(int)styleSizeForKey:(NSString *)key defaultsTo:(int)defaultSize
{
    NSNumber *fontSizeNum = [self.songStyle objectForKey:key];
    if (fontSizeNum) {
        return fontSizeNum.intValue;
    }
    
    return defaultSize;
}

-(void)setHeaderSize:(int)headerSize
{
    [self setStyleSize:headerSize forKey:@"headerSize" withCSSSelector:@"body .opensong h2"];
}

-(int)headerSize
{
    return [self styleSizeForKey:@"headerSize" defaultsTo:24];
}

- (void)setChordsSize:(int)chordsSize
{
    [self setStyleSize:chordsSize forKey:@"chordsSize" withCSSSelector:@"body .opensong .chords"];
}

- (int)chordsSize
{
    return [self styleSizeForKey:@"chordsSize" defaultsTo:16];
}

- (void)setLyricsSize:(int)lyricsSize
{
    [self setStyleSize:lyricsSize forKey:@"lyricsSize" withCSSSelector:@"body .opensong .lyrics"];
}

- (int)lyricsSize
{
    return [self styleSizeForKey:@"lyricsSize" defaultsTo:16];
}

- (void)setCommentsSize:(int)commentsSize
{
    [self setStyleSize:commentsSize forKey:@"commentsSize" withCSSSelector:@"body .opensong .comments"];
}

- (int)commentsSize
{
    return [self styleSizeForKey:@"commentsSize" defaultsTo:10];
}

- (void) setSongStyle:(NSMutableDictionary *)songStyle
{
    return;
    
    if (songStyle) {
        _songStyle = songStyle;
    } else {
        _songStyle = [[NSMutableDictionary alloc] init];
    }
    
    // FIXME: return if not changed
    if ([songStyle isEqual:self.songStyle]) {
        //return;
    }
    
    self.headerVisible = self.headerVisible;
    self.chordsVisible = self.chordsVisible;
    self.lyricsVisible = self.lyricsVisible;
    self.commentsVisible = self.commentsVisible;
    
    self.headerSize = self.headerSize;
    self.chordsSize = self.chordsSize;
    self.lyricsSize = self.lyricsSize;
    self.commentsSize = self.commentsSize;
    
    // save user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.songStyle forKey:USER_DEFAULTS_KEY_SONG_STYLE];
    [defaults synchronize];
}

@end
