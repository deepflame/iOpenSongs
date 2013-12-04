//
//  OSShopManager.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 11/30/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/SKProduct.h>

#import "OSInAppPurchaseIdentifiers.h"

@interface OSStoreManager : NSObject

+ (instancetype)sharedManager;

+ (BOOL)isEnabled;

- (void)initInAppStore;

- (void)requestProductsOnSuccess:(void (^)(NSArray *products, NSArray *invalidIdentifiers))success
                        failure:(void (^)(NSError *error))failure;

- (void)buyProduct:(SKProduct *)product;

- (void)restorePurchases;

- (BOOL)canUseFeature:(NSString *)identifier;

@end
