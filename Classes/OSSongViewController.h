//
//  ViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Song.h"
#import "OSSongView.h"

@interface OSSongViewController : UIViewController

@property (nonatomic, strong, readonly) OSSongView *songView;

@end
