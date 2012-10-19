//
//  WebViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/4/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyTracker.h"

@interface HtmlViewController : TrackedUIViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSURL *resourceURL;

@end