//
//  StyleViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/27/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSStyleViewController.h"
#import "OSRevealSidebarController.h"
#import "OSSongViewController.h"


@interface OSStyleViewController ()
{
    IBOutlet UISwitch *nightModeSwitch;
    IBOutlet UISwitch *headerVisibleSwitch;
    IBOutlet UISwitch *chordsVisibleSwitch;
    IBOutlet UISwitch *lyricsVisibleSwitch;
    IBOutlet UISwitch *commentsVisibleSwitch;
    __weak IBOutlet UISlider *headerSizeSlider;
    __weak IBOutlet UISlider *chordsSizeSlider;
    __weak IBOutlet UISlider *lyricsSizeSlider;
    __weak IBOutlet UISlider *commentsSizeSlider;
}

@end

@implementation OSStyleViewController

- (void) initSongStyleValues
{
    headerVisibleSwitch.on = [[self songView] headerVisible];
    chordsVisibleSwitch.on = [[self songView] chordsVisible];
    lyricsVisibleSwitch.on = [[self songView] lyricsVisible];
    commentsVisibleSwitch.on = [[self songView] commentsVisible];
    
    headerSizeSlider.value = [[self songView] headerSize];
    chordsSizeSlider.value = [[self songView] chordsSize];
    lyricsSizeSlider.value = [[self songView] lyricsSize];
    commentsSizeSlider.value = [[self songView] commentsSize];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    nightModeSwitch.on = [[self songView] nightMode];

    [self initSongStyleValues];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

# pragma mark - Private Methods

- (OSSongViewController *)songViewController
{
    id svc = [self.slidingViewController topViewController];
    
    if ([svc isKindOfClass:[UINavigationController class]]) {
        svc = ((UINavigationController *) svc).topViewController;
    }
    
    if (![svc isKindOfClass:[OSSongViewController class]]) {
        svc = nil;
    }
    return svc;
}

- (OSSongView *)songView
{
    return [self songViewController].songView;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ([[[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier] isEqualToString:@"Reset Style Cell"]) {
        [[self songView] resetSongStyle];
        [self initSongStyleValues];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - IBActions

- (IBAction)nightMode:(UISwitch *)sender 
{
    [[self songView] setNightMode:sender.on];
}

- (IBAction)headerVisible:(UISwitch *)sender 
{
    [[self songView] setHeaderVisible:sender.on];
}
- (IBAction)chordsVisible:(UISwitch *)sender 
{
    [[self songView] setChordsVisible:sender.on];
}
- (IBAction)lyricsVisible:(UISwitch *)sender 
{
    [[self songView] setLyricsVisible:sender.on];
}
- (IBAction)commentsVisible:(UISwitch *)sender 
{
    [[self songView]setCommentsVisible:sender.on];
}

- (IBAction)headerSize:(UISlider *)sender 
{
    [[self songView] setHeaderSize:sender.value];
}
- (IBAction)chordsSize:(UISlider *)sender 
{
    [[self songView] setChordsSize:sender.value];
}
- (IBAction)lyricsSize:(UISlider *)sender 
{
    [[self songView] setLyricsSize:sender.value];    
}
- (IBAction)commentsSize:(UISlider *)sender 
{
    [[self songView] setCommentsSize:sender.value];
}

- (void)viewDidUnload {
    headerVisibleSwitch = nil;
    chordsVisibleSwitch = nil;
    lyricsVisibleSwitch = nil;
    headerSizeSlider = nil;
    chordsSizeSlider = nil;
    lyricsSizeSlider = nil;
    commentsSizeSlider = nil;
    commentsVisibleSwitch = nil;
    [super viewDidUnload];
}
@end
