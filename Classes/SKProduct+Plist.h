//
//  SKProduct+PList.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 1/7/14.
//  Copyright (c) 2014 Andreas Boehrnsen. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface SKProduct (Plist)

+ (NSArray *)productsWithContentsOfFile:(NSString *)pListPath;

@end
