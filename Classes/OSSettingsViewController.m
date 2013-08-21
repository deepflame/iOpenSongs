//
//  OSSettingsViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 8/21/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSSettingsViewController.h"

#import "OSSongStyle.h"

@interface OSSettingsViewController ()

@end

@implementation OSSettingsViewController

- (OSSettingsViewController *)init
{
    self = [super init];
    if (self) {
        OSSongStyle *style = [OSSongStyle defaultStyle];
        
        // Section 1: Night Mode
        QBooleanElement *nightModeElem = [[QBooleanElement alloc] initWithTitle:NSLocalizedString(@"Night Mode", nil) BoolValue:style.nightMode];
        nightModeElem.onValueChanged = ^(QRootElement *elem) {
            QBooleanElement *boolElem = (QBooleanElement *)elem;
            style.nightMode = boolElem.boolValue;
        };
        QSection *section1 = [[QSection alloc] init];
        [section1 addElement:nightModeElem];
        
        // Section 2: Song Style
        void (^visibilityBlock)(QRootElement *) = ^(QRootElement *elem) {
            QBooleanElement *boolElem = (QBooleanElement *)elem;
            [style setValue:@(boolElem.boolValue) forKey:elem.key];
        };
        QBooleanElement *headeBoolElem = [[QBooleanElement alloc] initWithTitle:NSLocalizedString(@"Header", nil) BoolValue:style.headerVisible];
        QBooleanElement *chordBoolElem = [[QBooleanElement alloc] initWithTitle:NSLocalizedString(@"Chords", nil) BoolValue:style.chordsVisible];
        QBooleanElement *lyricBoolElem = [[QBooleanElement alloc] initWithTitle:NSLocalizedString(@"Lyrics", nil) BoolValue:style.lyricsVisible];
        QBooleanElement *commeBoolElem = [[QBooleanElement alloc] initWithTitle:NSLocalizedString(@"Comments", nil) BoolValue:style.commentsVisible];
        headeBoolElem.key = @"headerVisible";
        headeBoolElem.onValueChanged = visibilityBlock;
        chordBoolElem.key = @"chordsVisible";
        chordBoolElem.onValueChanged = visibilityBlock;
        lyricBoolElem.key = @"lyricsVisible";
        lyricBoolElem.onValueChanged = visibilityBlock;
        commeBoolElem.key = @"commentsVisible";
        commeBoolElem.onValueChanged = visibilityBlock;
        
        void (^sizeBlock)(QRootElement *) = ^(QRootElement *elem) {
            QFloatElement *floatElem = (QFloatElement *)elem;
            [style setValue:@(floatElem.floatValue) forKey:elem.key];
        };
        QFloatElement *headeFloatElem = [[QFloatElement alloc] initWithTitle:nil value:style.headerSize];
        QFloatElement *chordFloatElem = [[QFloatElement alloc] initWithTitle:nil value:style.chordsSize];
        QFloatElement *lyricFloatElem = [[QFloatElement alloc] initWithTitle:nil value:style.lyricsSize];
        QFloatElement *commeFloatElem = [[QFloatElement alloc] initWithTitle:nil value:style.commentsSize];
        headeFloatElem.key = @"headerSize";
        headeFloatElem.minimumValue = 8.0;
        headeFloatElem.maximumValue = 48.0;
        headeFloatElem.onValueChanged = sizeBlock;
        chordFloatElem.key = @"chordsSize";
        chordFloatElem.minimumValue = 8.0;
        chordFloatElem.maximumValue = 48.0;
        chordFloatElem.onValueChanged = sizeBlock;
        lyricFloatElem.key = @"lyricsSize";
        lyricFloatElem.minimumValue = 8.0;
        lyricFloatElem.maximumValue = 48.0;
        lyricFloatElem.onValueChanged = sizeBlock;
        commeFloatElem.key = @"commentSize";
        commeFloatElem.minimumValue = 8.0;
        commeFloatElem.maximumValue = 48.0;
        commeFloatElem.onValueChanged = sizeBlock;
        
        QSection *section2 = [[QSection alloc] init];
        section2.title = NSLocalizedString(@"Song Style", nil);
        [section2 addElement:headeBoolElem];
        [section2 addElement:headeFloatElem];
        [section2 addElement:chordBoolElem];
        [section2 addElement:chordFloatElem];
        [section2 addElement:lyricBoolElem];
        [section2 addElement:lyricFloatElem];
        [section2 addElement:commeBoolElem];
        [section2 addElement:commeFloatElem];
        
        QRootElement *root = [[QRootElement alloc] init];
        root.title = NSLocalizedString(@"Settings", nil);
        root.grouped = YES;
        [root addSection:section1];
        [root addSection:section2];
        
        self.root = root;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // persist song style
    [[OSSongStyle defaultStyle] saveAsUserDefaults];
}

@end
