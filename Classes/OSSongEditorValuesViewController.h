//
//  OSSongOptionsViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 1/3/14.
//  Copyright (c) 2014 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickDialog/QuickDialog.h>

#import "OSSongEditorViewControllerDelegate.h"

#import "Song.h"

@interface OSSongEditorValuesViewController : QuickDialogController

- (id)initWithSong:(Song *)song;

@property (nonatomic, weak) id<OSSongEditorViewControllerDelegate> delegate;

@end
