//
//  OSShopManager.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 11/30/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSStoreManager.h"

#import <CargoBay/CargoBay.h>
#import <Lockbox/Lockbox.h>

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
    [[CargoBay sharedManager] setPaymentQueueUpdatedTransactionsBlock:^(SKPaymentQueue *queue, NSArray *transactions) {
        [transactions each:^(SKPaymentTransaction *transaction) {
            switch (transaction.transactionState) {
                case SKPaymentTransactionStatePurchasing: {
                    
                    break;
                }
                case SKPaymentTransactionStatePurchased: {
                    NSSet *set = [Lockbox setForKey:OS_IAP];
                    if (set == nil) {
                        set = [NSSet set];
                    }
                    
                    [Lockbox setSet:[NSSet set] forKey:OS_IAP];
                    
                    //transaction.transactionReceipt;
                    break;
                }
                case SKPaymentTransactionStateRestored: {
                    NSSet *set = [Lockbox setForKey:OS_IAP];
                    //transaction.transactionIdentifier
                    
                    break;
                }
                case SKPaymentTransactionStateFailed: {
                    NSError *error = transaction.error;
                    
                    //NSLocalizedDescriptionKey
                    
                    [queue finishTransaction:transaction];
                    break;
                }
                default: {
                    ;
                }
            }
        }];
    }];
    
    [[CargoBay sharedManager] setPaymentQueueRemovedTransactionsBlock:^(SKPaymentQueue *queue, NSArray *transactions) {
        
    }];
    
    [[CargoBay sharedManager] setPaymentQueueRestoreCompletedTransactionsWithSuccess:^(SKPaymentQueue *queue) {
        
    } failure:^(SKPaymentQueue *queue, NSError *error) {
        
    }];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[CargoBay sharedManager]];
}


- (void)productsWithIdentifiers:(NSSet *)identifiers
                        success:(void (^)(NSArray *products, NSArray *invalidIdentifiers))success
                        failure:(void (^)(NSError *error))failure
{
    [[CargoBay sharedManager] productsWithIdentifiers:identifiers success:success failure:failure];
}


- (void)buyProduct:(SKProduct *)product
{
    if ([SKPaymentQueue canMakePayments])
    {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    } else {
        /*
         [self showAlertWithTitle:NSLocalizedString(@"In-App Purchasing disabled", @"")
         message:NSLocalizedString(@"Check your parental control settings and try again later", @"")];
         */
    }
}

- (void)restorePurchases
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (BOOL)canUseFeature:(NSString *)identifier
{
    return YES;
}

@end
