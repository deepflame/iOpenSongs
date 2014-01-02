//
//  UIViewController+GoogleAnalytics.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 1/2/14.
//  Copyright (c) 2014 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GoogleAnalytics-iOS-SDK/GAITracker.h>

#import <StoreKit/SKPaymentTransaction.h>
#import <StoreKit/SKProduct.h>

@interface UIViewController (GoogleAnalytics)

@property (nonatomic, readonly) id<GAITracker> tracker;

@property (nonatomic, readonly) NSString *trackedScreenName;

- (void)trackScreen:(NSString *)name;

- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;

- (void)trackEventWithAction:(NSString *)action label:(NSString *)label value:(NSNumber *)value;

- (void)trackEventWithAction:(NSString *)action;

- (void)trackError:(NSError *)error;

- (void)trackItemWithTransaction:(SKPaymentTransaction *)transaction product:(SKProduct *)product;

@end
