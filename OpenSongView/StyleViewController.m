//
//  StyleViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/27/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "StyleViewController.h"
#import "RevealSidebarController.h"
#import "SongViewController.h"


@interface StyleViewController ()
{
    IBOutlet UISwitch *nightModeSwitch;
    IBOutlet UISwitch *headerVisibleSwitch;
    IBOutlet UISwitch *chordsVisibleSwitch;
    IBOutlet UISwitch *lyricsVisibleSwitch;
    __weak IBOutlet UISlider *headerSizeSlider;
    __weak IBOutlet UISlider *chordsSizeSlider;
    __weak IBOutlet UISlider *lyricsSizeSlider;
}

@end

@implementation StyleViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    nightModeSwitch.on = [[self songViewController] nightMode];

    BOOL songAvailable = ([[self songViewController] song] != nil);
    
    headerVisibleSwitch.enabled = songAvailable;
    chordsVisibleSwitch.enabled = songAvailable;
    lyricsVisibleSwitch.enabled = songAvailable;
    
    headerSizeSlider.enabled = songAvailable;
    chordsSizeSlider.enabled = songAvailable;
    lyricsSizeSlider.enabled = songAvailable;  
    
    if (songAvailable) {
        headerVisibleSwitch.on = [[self songViewController] headerVisible];
        chordsVisibleSwitch.on = [[self songViewController] chordsVisible];
        lyricsVisibleSwitch.on = [[self songViewController] lyricsVisible];
        
        headerSizeSlider.value = [[self songViewController] headerSize];
        chordsSizeSlider.value = [[self songViewController] chordsSize];
        lyricsSizeSlider.value = [[self songViewController] lyricsSize];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

// ---

- (SongViewController *)songViewController
{
    id svc = [self.revealSidebarController rootViewController];
    
    if ([svc isKindOfClass:[UINavigationController class]]) {
        svc = ((UINavigationController *) svc).topViewController;
    }
    
    if (![svc isKindOfClass:[SongViewController class]]) {
        svc = nil;
    }
    return svc;
}


#pragma mark - IBActions

- (IBAction)nightMode:(UISwitch *)sender 
{
    [[self songViewController] setNightMode:sender.on];
}

- (IBAction)headerVisible:(UISwitch *)sender 
{
    [[self songViewController] setHeaderVisible:sender.on];
}
- (IBAction)chordsVisible:(UISwitch *)sender 
{
    [[self songViewController] setChordsVisible:sender.on];
}
- (IBAction)lyricsVisible:(UISwitch *)sender 
{
    [[self songViewController] setLyricsVisible:sender.on];
}

- (IBAction)headerSize:(UISlider *)sender 
{
    [[self songViewController] setHeaderSize:sender.value];
}
- (IBAction)chordsSize:(UISlider *)sender 
{
    [[self songViewController] setChordsSize:sender.value];
}
- (IBAction)lyricsSize:(UISlider *)sender 
{
    [[self songViewController] setLyricsSize:sender.value];    
}

- (void)viewDidUnload {
    headerVisibleSwitch = nil;
    chordsVisibleSwitch = nil;
    lyricsVisibleSwitch = nil;
    headerSizeSlider = nil;
    chordsSizeSlider = nil;
    lyricsSizeSlider = nil;
    [super viewDidUnload];
}
@end
