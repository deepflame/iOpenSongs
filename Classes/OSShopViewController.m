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
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

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
    [self trackScreen:@"Shop"];
}

#pragma mark - Private Methods

- (QSection *)sectionForPurchasingProduct:(SKProduct *)product
{
    QSection *section = [[QSection alloc] initWithTitle:product.localizedTitle];
    QTextElement *description = [[QTextElement alloc] initWithText:product.localizedDescription];
    QButtonElement *purchase = [[QButtonElement alloc] initWithTitle:product.localizedPrice];
    purchase.onSelected = ^ {
        
        // Google Analytics
        [self trackEventWithAction:@"purchase" label:product.productIdentifier value:nil];
        
        // buy product
        [[OSStoreManager sharedManager] buyProduct:product.productIdentifier success:^(SKPaymentTransaction *transaction) {
            
            // Google Analytics
            [self trackItemWithTransaction:transaction product:product];
            
            [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Thank you!", nil)
                                           message:[NSString stringWithFormat:NSLocalizedString(@"'%@' successfully purchased.", nil), product.localizedTitle]
                                 cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                 otherButtonTitles:nil handler:nil];
            
            [self refreshProductList];
            
        } failure:^(SKPaymentTransaction *transaction, NSError *error) {
            
            // Google Analytics
            [self trackError:error];
            
            [UIAlertView showWithError:error];
        }];
        
    };
    QButtonElement *purchased = [[QButtonElement alloc] initWithTitle:NSLocalizedString(@"Purchased", nil)];
    
    BOOL isPurchased = [[OSStoreManager sharedManager] isPurchased:product.productIdentifier];
    
    [section addElement:description];
    [section addElement:isPurchased ? purchased : purchase];
    
    return section;
}

- (QSection *)sectionForRestore
{
    QSection *section = [[QSection alloc] initWithTitle:NSLocalizedString(@"Previous Purchases", nil)];
    QButtonElement *restoreButton = [[QButtonElement alloc] initWithTitle:NSLocalizedString(@"Restore", nil)];
    restoreButton.onSelected = ^ {
        
        // Google Analytics
        [self trackEventWithAction:@"restore"];
        
        // restore purchases
        [[OSStoreManager sharedManager] restoreTransactionsOnSuccess:^ {
            [UIAlertView bk_showAlertViewWithTitle:nil
                                           message:NSLocalizedString(@"Purchases successfully restored", nil)
                                 cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                 otherButtonTitles:nil handler:nil];
            [self refreshProductList];
            
        } failure:^(NSError *error) {
            
            // Google Analytics
            [self trackError:error];
            
            [UIAlertView showWithError:error];
        }];
        
    };
    [section addElement:restoreButton];
    return section;
}

- (QSection *)sectionForRefreshWithError:(NSError *)error
{
    QSection *section = [[QSection alloc] initWithTitle:nil];
    QTextElement *description = [[QTextElement alloc] initWithText:error.localizedDescription];
    QButtonElement *retryButton = [[QButtonElement alloc] initWithTitle:NSLocalizedString(@"Retry", nil)];
    retryButton.onSelected = ^ {
        [self refreshProductList];
    };
    [section addElement:description];
    [section addElement:retryButton];
    
    return section;
}

- (void)refreshProductList
{
    // show HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // reset sections
    self.root.sections = [[NSMutableArray alloc] init];
    
    [[OSStoreManager sharedManager] requestProductsOnSuccess:^(NSArray *products, NSArray *invalidIdentifiers) {
        // buy products
        [products bk_each:^(SKProduct *product) {
            QSection *section = [self sectionForPurchasingProduct:product];
            [self.root addSection:section];
        }];
        
        // restore previous purchases
        QSection *section = [self sectionForRestore];
        [self.root addSection:section];
        
        [self.quickDialogTableView reloadData];
        [hud hide:YES];
    } failure:^(NSError *error) {
        
        // Google Analytics
        [self trackError:error];
        
        // retry contacting the app store
        QSection *section = [self sectionForRefreshWithError:error];
        [self.root addSection:section];
        
        [self.quickDialogTableView reloadData];
        [hud hide:YES];
    }];
    
}

@end
