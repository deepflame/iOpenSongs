//
//  OSSongEditorViewControllerDelegate.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/20/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Song;

@protocol OSSongEditorViewControllerDelegate <NSObject>
- (void)songEditorViewController:(id)sender finishedEditingSong:(Song *)song;
@end
