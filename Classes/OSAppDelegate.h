//
//  AppDelegate.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (OSAppDelegate *)sharedAppDelegate;

@end
