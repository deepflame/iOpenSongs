//
//  ViewController.m
//  OpenSongView
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2011 Open iT Norge AS. All rights reserved.
//

#import "SongViewController.h"
#import "OpenSongParseOperation.h"
#import "Song.h"

#pragma mark ViewController () 

// forward declarations
@interface SongViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (nonatomic, retain) NSOperationQueue *operationQueue;     // the queue that manages our NSOperation for parsing song data

- (void)displaySong;
- (NSString *) convertLyricsToHtml;
- (void)handleError:(NSError *)error;
@end

@implementation SongViewController

@synthesize masterPopoverController;
@synthesize song = _song;
@synthesize operationQueue;

#pragma mark - Managing the song

- (void)setSong:(id)newSong
{
    if (_song != newSong) {
        _song = newSong;
        
        // Update the view.
        [self displaySong];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)displaySong {
    if (self.song) {
        NSString *rootPath = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:rootPath];
        
        [songLyrics loadHTMLString:[self convertLyricsToHtml] baseURL:baseURL];
        
        self.navigationItem.title = _song.title; 
    }
}

- (NSString *)convertLyricsToHtml
{    
    NSArray *lyricsLines = [_song.lyrics componentsSeparatedByString:@"\n"];
    NSMutableArray *htmlLyricsLines = [NSMutableArray arrayWithCapacity:[lyricsLines count]];
    
    for (NSString *lyricsLine in lyricsLines) {
        NSString *htmlLine = lyricsLine;
        
        if ([lyricsLine hasPrefix:@"["]) {
            NSString *sectionType;
            
            // parse the section header
            NSScanner *scanner = [NSScanner scannerWithString:lyricsLine];
            if ([scanner scanString:@"[" intoString:NULL] &&
                [scanner scanUpToString:@"]" intoString:&sectionType]) {
                
                // parse 
                NSInteger sectionNumber = 0;
                if ([sectionType length] == 2) {
                    sectionNumber = [[sectionType substringFromIndex:1] integerValue];
                    // cut off the number if it is non zero
                    if (sectionNumber != 0) {
                        sectionType = [sectionType substringToIndex:1];
                    }
                }
                
                // replace section header
                if ([sectionType isEqualToString:@"C"]) {
                    htmlLine = @"Chorus";
                } else if ([sectionType isEqualToString:@"V"]) {
                    htmlLine = @"Verse";
                } else if ([sectionType isEqualToString:@"B"]) {
                    htmlLine = @"Bridge";
                } else if ([sectionType isEqualToString:@"T"]) {
                    htmlLine = @"Tag";
                } else if ([sectionType isEqualToString:@"P"]) {
                    htmlLine = @"Pre Chorus";
                } else if ([sectionType isEqualToString:@"I"]) {
                    htmlLine = @"Intro";
                } else if ([sectionType isEqualToString:@"O"]) {
                    htmlLine = @"Outro";
                }
                
                // adding section number
                if (sectionNumber > 0) {
                    htmlLine = [htmlLine stringByAppendingFormat:@" %u", sectionNumber];
                }
            }
            
            htmlLine = [NSString stringWithFormat:@"<div class='heading'>%@</div>", htmlLine];
        } else if ([lyricsLine hasPrefix:@"."]) {
            htmlLine = [NSString stringWithFormat:@"<div class='chords'>%@</div>", htmlLine];
        } else if ([lyricsLine hasPrefix:@";"]) {
            htmlLine = [NSString stringWithFormat:@"<div class='comment'>%@</div>", htmlLine];
        } else {
            htmlLine = [NSString stringWithFormat:@"<div class='lyrics'>%@</div>", htmlLine];
        }
        
        [htmlLyricsLines addObject:htmlLine];
    }
    
    NSString *htmlLyrics = [htmlLyricsLines componentsJoinedByString:@"\n"];
    NSURL *templateUrl = [[NSBundle mainBundle] URLForResource:@"SongTemplate" withExtension:@"html"];
    NSString *htmlDoc = [NSString stringWithContentsOfURL:templateUrl 
                                                 encoding:NSUTF8StringEncoding
                                                    error:NULL];
    return [NSString stringWithFormat:htmlDoc, htmlLyrics];
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(songParseCallback:)
                                                 name:kSongSuccessNotif
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(songParseErrback:)
                                                 name:kSongErrorNotif
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark -
#pragma mark OpenSong File Parsing

- (void)parseSongFromUrl:(NSURL *)songFileUrl
{    
    NSData *songData = [[NSData alloc] initWithContentsOfURL:songFileUrl];
    [self parseSongData:songData];
}

- (void)parseSongData:(NSData *)songData
{    
    // Spawn an NSOperation to parse the earthquake data so that the UI is not blocked while the
    // application parses the XML data.
    //
    // IMPORTANT! - Don't access or affect UIKit objects on secondary threads.
    //
    OpenSongParseOperation *parseOperation = [[OpenSongParseOperation alloc] initWithData:songData];
    //operationQueue = [NSOperationQueue new];
    //[self.operationQueue addOperation:parseOperation];
    [parseOperation start];
}

// Our NSNotification callback from the running NSOperation to add the earthquakes
//
- (void)songParseCallback:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    
    self.song = [[notif userInfo] valueForKey:kSongSuccessKey];
}

// Our NSNotification callback from the running NSOperation when a parsing error has occurred
//
- (void)songParseErrback:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    
    [self handleError:[[notif userInfo] valueForKey:kSongErrorKey]];
}

#pragma mark -

// Handle errors in the download by showing an alert to the user. This is a very
// simple way of handling the error, partly because this application does not have any offline
// functionality for the user. Most real applications should handle the error in a less obtrusive
// way and provide offline functionality to the user.
//
- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:
     NSLocalizedString(@"Error Title",
                       @"Title for alert displayed when download or parse error occurs.")
                               message:errorMessage
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Songs", @"Songs");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
