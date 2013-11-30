//
//  OSShopViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 8/19/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSShopViewController.h"

#import <MBProgressHUD/MBProgressHUD.h>

#import <CargoBay/CargoBay.h>
#import "OSInAppPurchaseIdentifiers.h"
#import "SKProduct+LocalizedPrice.h"

@interface OSShopViewController ()

@end

@implementation OSShopViewController

- (OSShopViewController *)init
{
    self = [super init];
    if (self) {
        QRootElement *root = [[QRootElement alloc] init];
        root.title = NSLocalizedString(@"Shop", nil);
        root.grouped = YES;
        self.root = root;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refreshProductList];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Private Methods

- (void)refreshProductList
{
    // show HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // reset sections
    self.root.sections = [[NSMutableArray alloc] init];
    
    NSArray *identifiers = @[OS_IAP_DROPBOX];
    [[CargoBay sharedManager] productsWithIdentifiers:[NSSet setWithArray:identifiers]
                                              success:^(NSArray *products, NSArray *invalidIdentifiers) {
                                                  
                                                  // buy products
                                                  [products each:^(SKProduct *product) {
                                                      QSection *section = [[QSection alloc] initWithTitle:product.localizedTitle];
                                                      QTextElement *description = [[QTextElement alloc] initWithText:product.localizedDescription];
                                                      QButtonElement *purchase = [[QButtonElement alloc] initWithTitle:product.localizedPrice];
                                                      purchase.onSelected = ^ {
                                                          [self buyProduct:product];
                                                      };
                                                      [section addElement:description];
                                                      [section addElement:purchase];
                                                      
                                                      [self.root addSection:section];
                                                  }];
                                                  
                                                  // restore previous purchases
                                                  QSection *restoreSec = [[QSection alloc] initWithTitle:NSLocalizedString(@"Previous Purchases", nil)];
                                                  QButtonElement *restoreButton = [[QButtonElement alloc] initWithTitle:NSLocalizedString(@"Restore", nil)];
                                                  restoreButton.onSelected = ^ {
                                                      [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
                                                  };
                                                  [restoreSec addElement:restoreButton];
                                                  // add to root
                                                  [self.root addSection:restoreSec];
                                                  
                                                  [self.quickDialogTableView reloadData];
                                                  [hud hide:YES];
                                              } failure:^(NSError *error) {
                                                  
                                                  // retry contacting the app store
                                                  QSection *section = [[QSection alloc] initWithTitle:NSLocalizedString(@"Error", nil)];
                                                  QTextElement *description = [[QTextElement alloc] initWithText:NSLocalizedString(@"Cannot contact", nil)];
                                                  QButtonElement *retryButton = [[QButtonElement alloc] initWithTitle:NSLocalizedString(@"Retry", nil)];
                                                  retryButton.onSelected = ^ {
                                                      [self refreshProductList];
                                                  };
                                                  [section addElement:description];
                                                  [section addElement:retryButton];
                                                  // add to root
                                                  [self.root addSection:section];
                                                  
                                                  [self.quickDialogTableView reloadData];
                                                  [hud hide:YES];
                                              }];
    
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

@end
