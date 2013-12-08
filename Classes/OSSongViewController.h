//
//  ViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSDetailViewController.h"

#import "Song.h"

@interface OSSongViewController : OSDetailViewController

@property (nonatomic, copy) Song *song;
@property (nonatomic, strong) NSString *introPartialName;

@end
