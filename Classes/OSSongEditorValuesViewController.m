//
//  OSSongOptionsViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 1/3/14.
//  Copyright (c) 2014 Andreas Boehrnsen. All rights reserved.
//

#import "OSSongEditorValuesViewController.h"

#import "OSSongEditorLyricsViewController.h"

#import "NSString+Additions.h"

@interface OSSongEditorValuesViewController () <OSSongEditorViewControllerDelegate>
@property (nonatomic, strong) Song *song;

@property (nonatomic, strong) QEntryElement *titleElement;
@property (nonatomic, strong) QEntryElement *authorElement;
@property (nonatomic, strong) QTextElement *lyricsElement;
@end

@implementation OSSongEditorValuesViewController

- (id)initWithSong:(Song *)song
{
    self = [super init];
    if (self) {
        UIBarButtonItem *saveBarButton = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemSave handler:^(id sender) {
            if ([NSString isBlank:self.titleElement.textValue]) {
                UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Notice" message:@"Please give a title"];
                [alertView bk_setCancelButtonWithTitle:NSLocalizedString(@"Dismiss", nil) handler:nil];
                [alertView show];
                return; // <- !!
            }
            
            self.song.title = self.titleElement.textValue;
            self.song.author = self.authorElement.textValue;
            
            [self.delegate songEditorViewController:self finishedEditingSong:self.song];
        }];
        UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemCancel handler:^(id sender) {
            [self.delegate songEditorViewController:self finishedEditingSong:self.song];
        }];
        self.navigationItem.leftBarButtonItems = @[saveBarButton, cancelBarButton];
        
        QRootElement *root = [[QRootElement alloc] init];
        root.title = NSLocalizedString(@"Edit Song", nil);
        root.grouped = YES;
        root.appearance.entryAlignment = NSTextAlignmentRight;
        
        self.titleElement = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Title", @"Song title") Value:song.title Placeholder:@"title"];
        self.authorElement = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Author", @"Song title") Value:song.author Placeholder:@"title"];
        QEntryElement *copyrightElement = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Copyright", @"Song title") Value:song.copyright Placeholder:@"title"];
        
        QEntryElement *ccliElement = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"CCLI", @"Song title") Value:song.ccli Placeholder:@"title"];
        self.lyricsElement = [[QTextElement alloc] initWithText:song.lyrics];
        self.lyricsElement.appearance.valueFont = [UIFont fontWithName:@"CourierNewPSMT" size:14.0];
        self.lyricsElement.onSelected = ^ {
            OSSongEditorLyricsViewController *lyricsViewController = [[OSSongEditorLyricsViewController alloc] initWithSong:self.song];
            lyricsViewController.delegate = self;
            
            UIViewController *viewController = [[UINavigationController alloc] initWithRootViewController:lyricsViewController];
            viewController.modalPresentationStyle = UIModalPresentationFullScreen;
            viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentModalViewController:viewController animated:YES];
        };
        
        QSection *section1 = [[QSection alloc] initWithTitle:@"General"];
        [section1 addElement:self.titleElement];
        [section1 addElement:self.authorElement];
        [section1 addElement:copyrightElement];
        
        QSection *section2 = [[QSection alloc] initWithTitle:nil];
        [section2 addElement:ccliElement];

        QSection *section3 = [[QSection alloc] initWithTitle:@"Lyrics"];
        [section3 addElement:self.lyricsElement];
        
        [root addSection:section1];
        [root addSection:section2];
        [root addSection:section3];
        
        self.root = root;
        self.song = song;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 

- (void)songEditorViewController:(OSSongEditorLyricsViewController *)sender finishedEditingSong:(Song *)song
{
    self.lyricsElement.text = song.lyrics;

    [self dismissModalViewControllerAnimated:YES];
}

@end
