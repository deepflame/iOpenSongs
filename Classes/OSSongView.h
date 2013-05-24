//
//  OSSongView.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/31/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OSSongViewDelegate.h"
#import "Song.h"
#import "OSSongStyle.h"

@interface OSSongView : UIView

@property (nonatomic, weak) id<OSSongViewDelegate> delegate;

@property (nonatomic, copy) Song *song;
@property (nonatomic, readonly) OSSongStyle *songStyle;

@property (nonatomic, strong) NSString *introPartialName;

@end
