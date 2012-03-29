//
//  SongViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "SongViewController.h"
#import "NSString+JavaScript.h"
#import "Song.h"

#import "SongMasterViewController.h"
#import "RevealSidebarController.h"
#import "ExtrasTableViewController.h"

#pragma mark SongViewController () 

// private interface
@interface SongViewController () <ExtrasTableViewControllerDelegate, SongMasterViewControllerDelegate, UIWebViewDelegate>
{
    IBOutlet UIWebView *songWebView;
    IBOutlet UIBarButtonItem *extrasBarButtonItem;
}

@property (strong, nonatomic) UIPopoverController *extrasPopoverController;
@property (strong, nonatomic) NSMutableDictionary *songStyle;

- (void)displaySong;
- (void)loadHtmlTemplate;
@end

#define USER_DEFAULTS_KEY_NIGHT_MODE @"SongViewController.nightMode"
#define USER_DEFAULTS_KEY_SONG_STYLE @"SongViewController.songStyle"

@implementation SongViewController

@synthesize extrasPopoverController = _extrasPopoverController;
@synthesize songStyle =_songStyle;
@synthesize song = _song;

- (void) resetSongStyle
{
    [self setSongStyle:nil];
}

#pragma mark - Managing the song

- (void)setSong:(Song *)song
{
    if (_song != song) {
        _song = song;
        
        // Update the view.
        [self displaySong];
    }
}

- (void)displaySong 
{
    if (self.song) {
        NSString* jsString = [NSString stringWithFormat:@"$('#lyrics').openSongLyrics(\"%@\");", [self.song.lyrics escapeJavaScript]];
        [songWebView stringByEvaluatingJavaScriptFromString:jsString];
        self.navigationItem.title = self.song.title;
        
        // reset style
        [self setSongStyle:self.songStyle];
    }
}

- (void)loadHtmlTemplate 
{
    NSString *rootPath = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:rootPath];
    
    NSURL *templateUrl = [[NSBundle mainBundle] URLForResource:@"SongTemplate" withExtension:@"html"];
    NSString *htmlDoc = [NSString stringWithContentsOfURL:templateUrl 
                                                 encoding:NSUTF8StringEncoding
                                                    error:NULL];
    [songWebView loadHTMLString:htmlDoc baseURL:baseURL];
}

// ---

- (void)setNightMode:(BOOL)state
{
    if (state == YES) {
        [songWebView stringByEvaluatingJavaScriptFromString:@"$('body').addClass('nightmode');"];        
    } else {
        [songWebView stringByEvaluatingJavaScriptFromString:@"$('body').removeClass('nightmode');"];        
    }
    
    // save user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:self.nightMode] forKey:USER_DEFAULTS_KEY_NIGHT_MODE];
    [defaults synchronize];
}

- (BOOL)nightMode
{
    return [[songWebView stringByEvaluatingJavaScriptFromString:@"$('body').hasClass('nightmode');"] isEqualToString:@"true"];
}

// -- Song Style: Visibiliy

-(void)setStyleVisible:(BOOL)isVisible forKey:(NSString *)key withCSSSelector:(NSString *)cssSel
{
    if (isVisible) {
        [songWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"$('%@').show();", cssSel]];
    } else {
        [songWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"$('%@').hide();", cssSel]];
    }
    [self.songStyle setObject:[NSNumber numberWithBool:isVisible] forKey:key];
    
    // save user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.songStyle forKey:USER_DEFAULTS_KEY_SONG_STYLE];
    [defaults synchronize];
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
    NSString *js = [NSString stringWithFormat:@"$('%@').css('font-size', '%dpx');", cssSel, size];
    [songWebView stringByEvaluatingJavaScriptFromString:js];
    [self.songStyle setObject:[NSNumber numberWithInt:size] forKey:key];
    
    // save user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.songStyle forKey:USER_DEFAULTS_KEY_SONG_STYLE];
    [defaults synchronize];
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
    if (songStyle) {
        _songStyle = songStyle;
    } else {
        _songStyle = [[NSMutableDictionary alloc] init];
    }
        
    self.headerVisible = self.headerVisible;
    self.chordsVisible = self.chordsVisible;
    self.lyricsVisible = self.lyricsVisible;
    self.commentsVisible = self.commentsVisible;
    
    self.headerSize = self.headerSize;
    self.chordsSize = self.chordsSize;
    self.lyricsSize = self.lyricsSize;
    self.commentsSize = self.commentsSize;
}

#pragma mark - UIView (view lifecycle)

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    songWebView.delegate = self;
    
    [self loadHtmlTemplate];
}

- (void)viewDidUnload
{
    extrasBarButtonItem = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - ExtrasTableViewControllerDelegate

- (void)extrasTableViewControllerDelegate:(ExtrasTableViewController *)sender dismissMyPopoverAnimated:(BOOL)animated
{
    [self.extrasPopoverController dismissPopoverAnimated:animated];
}

#pragma mark - SongMasterViewControllerDelegate

- (void)songMasterViewControllerDelegate:(SongMasterViewController *)sender choseSong:(Song *)song
{
    self.song = song;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.nightMode = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_NIGHT_MODE] boolValue];
    self.songStyle = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_SONG_STYLE];
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

#pragma mark - IBActions

- (IBAction)showExtrasPopup:(UIBarButtonItem *)sender 
{
    if (self.extrasPopoverController.popoverVisible) {
        [self.extrasPopoverController dismissPopoverAnimated:YES];
    } else {
        [self performSegueWithIdentifier:@"Show Extras Popup" sender:self];
    }
}
- (IBAction)revealSideMenu:(id)sender 
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Extras Popup"]) {
        ExtrasTableViewController *etvCon;
        
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
            [self.extrasPopoverController dismissPopoverAnimated:NO];
            self.extrasPopoverController = popoverSegue.popoverController; // might want to be popover's delegate and self.popoverController = nil on dismiss?

            UINavigationController *navCon = segue.destinationViewController;
            etvCon = (ExtrasTableViewController *) navCon.topViewController;
        } else {
            etvCon = (ExtrasTableViewController *) segue.destinationViewController;
        }
        
        etvCon.delegate = self;        
    }
}

@end
