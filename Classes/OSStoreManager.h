//
//  OSShopManager.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 11/30/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#import "OSInAppPurchaseIdentifiers.h"

@interface OSStoreManager : NSObject

+ (instancetype)sharedManager;

- (void)initInAppStore;

- (void)productsWithIdentifiers:(NSSet *)identifiers
                        success:(void (^)(NSArray *products, NSArray *invalidIdentifiers))success
                        failure:(void (^)(NSError *error))failure;

- (void)buyProduct:(SKProduct *)product;

- (BOOL)canUseFeature:(NSString *)identifier;

@end