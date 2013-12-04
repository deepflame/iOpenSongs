//
//  OSShopManager.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 11/30/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSStoreManager.h"

#import <RMStore/RMStore.h>
#import <RMStore/RMStoreKeychainPersistence.h>
#import <RMStore/RMStoreAppReceiptVerificator.h> // for iOS 7
#import <RMStore/RMStoreTransactionReceiptVerificator.h>

@interface OSStoreManager()
@property (nonatomic, strong) NSSet *featureIdentifiers;

@property id<RMStoreReceiptVerificator> receiptVerificator;
@property RMStoreKeychainPersistence *persistence;
@end

@implementation OSStoreManager

+ (instancetype)sharedManager {
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (void)initInAppStore
{
    self.featureIdentifiers = [NSSet setWithArray:@[OS_IAP_DROPBOX]];
    
    const BOOL iOS7OrHigher = floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1;
    self.receiptVerificator = iOS7OrHigher ? [[RMStoreAppReceiptVerificator alloc] init] : [[RMStoreTransactionReceiptVerificator alloc] init];
    [RMStore defaultStore].receiptVerificator = self.receiptVerificator;
    
    self.persistence = [[RMStoreKeychainPersistence alloc] init];
    [RMStore defaultStore].transactionPersistor = self.persistence;
}

- (void)requestProductsOnSuccess:(void (^)(NSArray *products, NSArray *invalidIdentifiers))success
                         failure:(void (^)(NSError *error))failure
{
    [[RMStore defaultStore] requestProducts:self.featureIdentifiers success:success failure:failure];
}


- (void)buyProduct:(SKProduct *)product
{

}

- (void)restorePurchases
{
    
}

- (BOOL)canUseFeature:(NSString *)identifier
{
    BOOL isBetaVersion = [[[[NSBundle mainBundle] bundleIdentifier] lowercaseString] hasSuffix:@"beta"];
    
    // open all features in Beta
    if (isBetaVersion) {
        return YES; // <- !!
    }
    
    return [self.persistence isPurchasedProductOfIdentifier:identifier];
}

@end
