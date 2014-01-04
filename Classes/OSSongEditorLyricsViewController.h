//
//  OSSongEditorViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/20/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OSSongEditorViewControllerDelegate.h"

#import "Song.h"

@interface OSSongEditorViewController : UIViewController

- (id)initWithSong:(Song *)song;

@property (nonatomic, weak) id<OSSongEditorViewControllerDelegate> delegate;

@end
