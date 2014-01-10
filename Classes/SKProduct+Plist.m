//
//  SKProduct+PList.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 1/7/14.
//  Copyright (c) 2014 Andreas Boehrnsen. All rights reserved.
//

#import "SKProduct+Plist.h"

@implementation SKProduct (Plist)

+ (NSArray *)productsWithContentsOfFile:(NSString *)pListPath;
{
    NSMutableArray *products = [NSMutableArray array];
    
    NSArray *pInfos = [NSArray arrayWithContentsOfFile:pListPath];
    for (NSDictionary *pInfo in pInfos) {
        SKProduct *product = [[SKProduct alloc] init];
        [product setValue:[pInfo valueForKey:@"productIdentifier"] forKey:@"productIdentifier"];
        [product setValue:[pInfo valueForKey:@"localizedTitle"] forKey:@"localizedTitle"];
        [product setValue:[pInfo valueForKey:@"localizedDescription"] forKey:@"localizedDescription"];
        
        [products addObject:product];
    }
    
    return products;
}

@end
