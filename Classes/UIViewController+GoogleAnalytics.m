//
//  UIViewController+GoogleAnalytics.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 1/2/14.
//  Copyright (c) 2014 Andreas Boehrnsen. All rights reserved.
//

#import "UIViewController+GoogleAnalytics.h"

#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAIFields.h>
#import <GoogleAnalytics/GAIDictionaryBuilder.h>

@implementation UIViewController (GoogleAnalytics)

@dynamic tracker;
@dynamic trackedScreenName;

- (id<GAITracker>)tracker
{
    return [[GAI sharedInstance] defaultTracker];
}

- (NSString *)trackedScreenName
{
    return [self.tracker get:kGAIScreenName];
}

- (void)trackScreen:(NSString *)name
{
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [self.tracker set:kGAIScreenName value:name];
    
    [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value
{
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                               action:action
                                                                label:label
                                                                value:value] build]];
}

- (void)trackEventWithAction:(NSString *)action label:(NSString *)label value:(NSNumber *)value
{
    [self trackEventWithCategory:self.trackedScreenName action:action label:label value:value];
}

- (void)trackEventWithAction:(NSString *)action
{
    [self trackEventWithAction:action label:nil value:nil];
}

- (void)trackError:(NSError *)error
{
    [self.tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[error description]
                                                                   withFatal:@0] build]];
}

- (void)trackItemWithTransaction:(SKPaymentTransaction *)transaction product:(SKProduct *)product
{
    [self.tracker send:[[GAIDictionaryBuilder createItemWithTransactionId:transaction.transactionIdentifier
                                                                     name:product.productIdentifier
                                                                      sku:product.productIdentifier
                                                                 category:@""
                                                                    price:product.price
                                                                 quantity:@1
                                                             currencyCode:[product.priceLocale objectForKey:NSLocaleCurrencyCode]] build]];
    
}

@end
