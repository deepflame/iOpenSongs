//
//  OSSongEditorViewControllerDelegate.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/20/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSSongEditorViewController, Song;

@protocol OSSongEditorViewControllerDelegate <NSObject>
- (void)songEditorViewController:(OSSongEditorViewController *)sender finishedEditingSong:(Song *)song;
@end
