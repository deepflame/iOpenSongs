//
//  WebViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/4/12.
//  Copyright (c) 2012 Open iT Norge AS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HtmlViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSURL *resourceURL;

@end