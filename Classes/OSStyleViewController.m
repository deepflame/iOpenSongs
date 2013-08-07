//
//  StyleViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/27/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSStyleViewController.h"

#import "OSSongStyle.h"

@interface OSStyleViewController ()
{
    __weak IBOutlet UISwitch *nightModeSwitch;
    __weak IBOutlet UISwitch *headerVisibleSwitch;
    __weak IBOutlet UISwitch *chordsVisibleSwitch;
    __weak IBOutlet UISwitch *lyricsVisibleSwitch;
    __weak IBOutlet UISwitch *commentsVisibleSwitch;
    __weak IBOutlet UISlider *headerSizeSlider;
    __weak IBOutlet UISlider *chordsSizeSlider;
    __weak IBOutlet UISlider *lyricsSizeSlider;
    __weak IBOutlet UISlider *commentsSizeSlider;
}

@end

@implementation OSStyleViewController

- (NSString *)title
{
    return NSLocalizedString(@"Settings", nil);
}

- (void) initSongStyleValues
{
    OSSongStyle *style = [OSSongStyle defaultStyle];
    
    nightModeSwitch.on = style.nightMode;
    
    headerVisibleSwitch.on = style.headerVisible;
    chordsVisibleSwitch.on = style.chordsVisible;
    lyricsVisibleSwitch.on = style.lyricsVisible;
    commentsVisibleSwitch.on = style.commentsVisible;
    
    headerSizeSlider.value = style.headerSize;
    chordsSizeSlider.value = style.chordsSize;
    lyricsSizeSlider.value = style.lyricsSize;
    commentsSizeSlider.value = style.commentsSize;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self initSongStyleValues];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // persist song style
    [[OSSongStyle defaultStyle] saveAsUserDefaults];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ([[[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier] isEqualToString:@"Reset Style Cell"]) {
        [[OSSongStyle defaultStyle] resetStyle];
        [self initSongStyleValues];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions

- (IBAction)nightMode:(UISwitch *)sender 
{
    [OSSongStyle defaultStyle].nightMode = sender.on;
}

- (IBAction)headerVisible:(UISwitch *)sender 
{
    [OSSongStyle defaultStyle].headerVisible = sender.on;
}
- (IBAction)chordsVisible:(UISwitch *)sender 
{
    [OSSongStyle defaultStyle].chordsVisible = sender.on;
}
- (IBAction)lyricsVisible:(UISwitch *)sender 
{
    [OSSongStyle defaultStyle].lyricsVisible = sender.on;
}
- (IBAction)commentsVisible:(UISwitch *)sender 
{
    [OSSongStyle defaultStyle].commentsVisible = sender.on;
}

- (IBAction)headerSize:(UISlider *)sender 
{
    [OSSongStyle defaultStyle].headerSize = sender.value;
}
- (IBAction)chordsSize:(UISlider *)sender 
{
    [OSSongStyle defaultStyle].chordsSize = sender.value;
}
- (IBAction)lyricsSize:(UISlider *)sender 
{
    [OSSongStyle defaultStyle].lyricsSize = sender.value;
}
- (IBAction)commentsSize:(UISlider *)sender 
{
    [OSSongStyle defaultStyle].commentsSize = sender.value;
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
