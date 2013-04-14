//
//  OSSongPageView.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 4/8/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "SYPageView.h"
#import "OSSongView.h"

@interface OSSongPageView : SYPageView

@property (nonatomic, strong, readonly) OSSongView *songView;

@end
