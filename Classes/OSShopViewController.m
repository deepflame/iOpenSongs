//
//  OSShopViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 8/19/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSShopViewController.h"

#import <MBProgressHUD/MBProgressHUD.h>

#import "OSStoreManager.h"
#import "SKProduct+LocalizedPrice.h"

#import "UIAlertView+Error.h"

#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@interface OSShopViewController ()
@property (nonatomic, strong) id<GAITracker> tracker;
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
        
        // Google Analytics
        self.tracker = [[GAI sharedInstance] defaultTracker];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refreshProductList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tracker set:kGAIScreenName value:NSStringFromClass([self class])];
    [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
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
    
    [[OSStoreManager sharedManager] requestProductsOnSuccess:^(NSArray *products, NSArray *invalidIdentifiers) {
                                                  
                                                  // buy products
                                                  [products bk_each:^(SKProduct *product) {
                                                      QSection *section = [[QSection alloc] initWithTitle:product.localizedTitle];
                                                      QTextElement *description = [[QTextElement alloc] initWithText:product.localizedDescription];
                                                      QButtonElement *purchase = [[QButtonElement alloc] initWithTitle:product.localizedPrice];
                                                      purchase.onSelected = ^ {
                                                          
                                                          // Google Analytics
                                                          [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:NSStringFromClass([self class])
                                                                                                                     action:@"button"
                                                                                                                      label:@"buy"
                                                                                                                      value:nil] build]];
                                                          
                                                          // buy product
                                                          [[OSStoreManager sharedManager] buyProduct:product.productIdentifier success:^(SKPaymentTransaction *transaction) {
                                                              
                                                              // Google Analytics
                                                              [self.tracker send:[[GAIDictionaryBuilder createItemWithTransactionId:transaction.transactionIdentifier
                                                                                                                               name:product.productIdentifier
                                                                                                                                sku:product.productIdentifier
                                                                                                                           category:@""
                                                                                                                              price:product.price
                                                                                                                           quantity:@1
                                                                                                                       currencyCode:[product.priceLocale objectForKey:NSLocaleCurrencyCode]] build]];
                                                              
                                                              [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Thank you!", nil)
                                                                                             message:[NSString stringWithFormat:NSLocalizedString(@"'%@' successfully purchased.", nil), product.localizedTitle]
                                                                                   cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                                                   otherButtonTitles:nil handler:nil];
                                                              
                                                              [self refreshProductList];
                                                              
                                                          } failure:^(SKPaymentTransaction *transaction, NSError *error) {
                                                              
                                                              // Google Analytics
                                                              [self.tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[error description]
                                                                                                                             withFatal:@0] build]];
                                                              
                                                              [UIAlertView showWithError:error];
                                                          }];
                                                          
                                                      };
                                                      QButtonElement *purchased = [[QButtonElement alloc] initWithTitle:NSLocalizedString(@"Purchased", nil)];
                                                      
                                                      BOOL isPurchased = [[OSStoreManager sharedManager] isPurchased:product.productIdentifier];
                                                      
                                                      [section addElement:description];
                                                      [section addElement:isPurchased ? purchased : purchase];
                                                      
                                                      [self.root addSection:section];
                                                  }];
                                                  
                                                  // restore previous purchases
                                                  QSection *restoreSec = [[QSection alloc] initWithTitle:NSLocalizedString(@"Previous Purchases", nil)];
                                                  QButtonElement *restoreButton = [[QButtonElement alloc] initWithTitle:NSLocalizedString(@"Restore", nil)];
                                                  restoreButton.onSelected = ^ {
                                                      
                                                      // Google Analytics
                                                      [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:NSStringFromClass([self class])
                                                                                                                 action:@"button"
                                                                                                                  label:@"restore purchases"
                                                                                                                  value:nil] build]];
                                                      
                                                      // restore purchases
                                                      [[OSStoreManager sharedManager] restoreTransactionsOnSuccess:^ {
                                                          [UIAlertView bk_showAlertViewWithTitle:nil
                                                                                         message:NSLocalizedString(@"Purchases successfully restored", nil)
                                                                               cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                                               otherButtonTitles:nil handler:nil];
                                                          [self refreshProductList];
                                                          
                                                      } failure:^(NSError *error) {
                                                          
                                                          // Google Analytics
                                                          [self.tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[error description]
                                                                                                                         withFatal:@0] build]];
                                                          
                                                          [UIAlertView showWithError:error];
                                                      }];
                                                      
                                                  };
                                                  [restoreSec addElement:restoreButton];
                                                  // add to root
                                                  [self.root addSection:restoreSec];
                                                  
                                                  [self.quickDialogTableView reloadData];
                                                  [hud hide:YES];
                                              } failure:^(NSError *error) {
                                                  
                                                  // Google Analytics
                                                  [self.tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[error description]
                                                                                                                 withFatal:@0] build]];
                                                  
                                                  // retry contacting the app store
                                                  QSection *section = [[QSection alloc] initWithTitle:nil];
                                                  QTextElement *description = [[QTextElement alloc] initWithText:error.localizedDescription];
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

@end
