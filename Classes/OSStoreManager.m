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
#import <RMStore/RMStoreTransactionReceiptVerificator.h>

#import "UIAlertView+Error.h"

@interface OSStoreManager()
@property (nonatomic, strong) NSSet *featureIdentifiers;

@property id<RMStoreReceiptVerificator> receiptVerificator;
@property RMStoreKeychainPersistence *persistence;
@end

@implementation OSStoreManager

+ (instancetype)sharedManager
{
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

+ (BOOL)isEnabled
{
    BOOL isBetaVersion = [[[[NSBundle mainBundle] bundleIdentifier] lowercaseString] hasSuffix:@"beta"];
    
    return ! isBetaVersion; // disable shop in Beta version
}

- (void)initInAppStore
{
    self.featureIdentifiers = [NSSet setWithArray:@[OS_IAP_DROPBOX]];
    
    self.receiptVerificator = [[RMStoreTransactionReceiptVerificator alloc] init];
    [RMStore defaultStore].receiptVerificator = self.receiptVerificator;
    
    self.persistence = [[RMStoreKeychainPersistence alloc] init];
    [RMStore defaultStore].transactionPersistor = self.persistence;
}

- (void)requestProductsOnSuccess:(void (^)(NSArray *products, NSArray *invalidIdentifiers))success
                         failure:(void (^)(NSError *error))failure
{
    [[RMStore defaultStore] requestProducts:self.featureIdentifiers success:success failure:failure];
}

- (void)buyProduct:(NSString *)productIdentifier
{
    [[RMStore defaultStore] addPayment:productIdentifier
                               success:^(SKPaymentTransaction *transaction) {
                                   
                               } failure:^(SKPaymentTransaction *transaction, NSError *error) {
                                   [UIAlertView showWithError:error];
                               }];
}

- (void)restorePurchases
{
    [[RMStore defaultStore] restoreTransactionsOnSuccess:^ {
        
    } failure:^(NSError *error) {
        [UIAlertView showWithError:error];
    }];
}

- (BOOL)canUseFeature:(NSString *)identifier
{
    // open all features if shop disabled
    if (! [[self class] isEnabled]) {
        return YES; // <- !!
    }
    
    return [self.persistence isPurchasedProductOfIdentifier:identifier];
}

@end
