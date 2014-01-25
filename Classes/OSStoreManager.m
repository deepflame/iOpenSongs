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

#import "SKProduct+Plist.h"

@interface OSStoreManager()
@property (nonatomic, strong) NSSet *featureIdentifiers;
@property id<RMStoreReceiptVerificator> receiptVerificator;
@property RMStoreKeychainPersistence *persistence;
@property NSMutableDictionary *purchasedOrRestoredBlocks;
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
    
#if DEBUG
    // reset transactions in DEBUG
    //[self.persistence removeTransactions];
#endif
    
    self.purchasedOrRestoredBlocks = [NSMutableDictionary dictionary];
}

- (void)requestProductsOnSuccess:(void (^)(NSArray *products, NSArray *invalidIdentifiers))success
                         failure:(void (^)(NSError *error))failure
{
    if ([self.class isEnabled]) {
        // request product data from the app store
        [[RMStore defaultStore] requestProducts:self.featureIdentifiers success:success failure:failure];        
    } else {
        // build product data from plist file
        NSString *rootPath = [[NSBundle mainBundle] bundlePath];
        NSString *pListPath = [rootPath stringByAppendingPathComponent:@"Products.plist"];
        
        NSArray *products = [SKProduct productsWithContentsOfFile:pListPath];
        success(products, @[]);
    }
}

- (void)buyProduct:(NSString *)productIdentifier
           success:(void (^)(SKPaymentTransaction *transaction))successBlock
           failure:(void (^)(SKPaymentTransaction *transaction, NSError *error))failureBlock
{
    [[RMStore defaultStore] addPayment:productIdentifier
                               success:^(SKPaymentTransaction *transaction) {
                                   // execute product purchase block
                                   id value = [self.purchasedOrRestoredBlocks objectForKey:productIdentifier];
                                   if (value) {
                                       void (^ block)() = value;
                                       block();
                                   }
                                   
                                   successBlock(transaction);
                               } failure:^(SKPaymentTransaction *transaction, NSError *error) {
                                   
                                   failureBlock(transaction, error);
                               }];
}

- (void)restoreTransactionsOnSuccess:(void (^)(void))successBlock
                             failure:(void (^)(NSError *error))failureBlock
{
    [[RMStore defaultStore] restoreTransactionsOnSuccess:^ {
        
        [self.purchasedOrRestoredBlocks bk_each:^(NSString *productIdentifier, id value) {
            if (value) {
                void (^ block)() = value;
                block();
            }
        }];
        
        successBlock();
    } failure:^(NSError *error) {
        
        failureBlock(error);
    }];
}

- (BOOL)isPurchased:(NSString *)productIdentifier
{
    // open all features if shop disabled
    if (! [[self class] isEnabled]) {
        return YES; // <- !!
    }
    
    return [self.persistence isPurchasedProductOfIdentifier:productIdentifier];
}

- (BOOL)canRestorePurchases
{
    if ([self.class isEnabled]) {
        return YES;
    }
    return NO;
}

- (void)whenPurchasedOrRestored:(NSString *)productIdentifier execute:(void (^)(void))block
{
    [self.purchasedOrRestoredBlocks setObject:block forKey:productIdentifier];
}

@end
