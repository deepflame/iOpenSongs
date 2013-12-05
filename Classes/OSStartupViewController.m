//
//  CoreDataSetupViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/10/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSStartupViewController.h"
#import "MBProgressHUD.h"

#import "Song.h"

#import "OSMainViewController.h"

@interface OSStartupViewController ()

@property (nonatomic, assign) BOOL isMigratingInBackground;

@end

@implementation OSStartupViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
        
    if (!self.isMigratingInBackground) {
        [self showMainUI];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark Private Methods

- (void) showMainUI
{
    UIWindow *window = [[UIApplication sharedApplication] windows][0];
    window.rootViewController = [[OSMainViewController alloc] init];
}

- (void) fillSongTitleSectionIndex
{
    NSArray *songsNeedUpdate = [Song MR_findByAttribute:@"titleSectionIndex" withValue:nil];
    
    // return if no update needed
    if (songsNeedUpdate.count == 0) {
        return;
    }
    
    self.isMigratingInBackground = YES;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = NSLocalizedString(@"Updating Database", nil);
    hud.detailsLabelText = NSLocalizedString(@"please wait...", nil);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        
        [songsNeedUpdate enumerateObjectsUsingBlock:^(Song *song, NSUInteger idx, BOOL *stop) {
            hud.progress = (float)idx / (float)songsNeedUpdate.count;
            
            Song *songInContext = [song MR_inContext:context];
            
            // also sets other title properties
            songInContext.title = songInContext.title;
            
            // save every 100 songs
            if (idx % 100 == 0) {
                [context MR_saveToPersistentStoreAndWait];
            }
        }];
        [context MR_saveToPersistentStoreAndWait];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            [self showMainUI];
        });
        
    });
    
}

@end
