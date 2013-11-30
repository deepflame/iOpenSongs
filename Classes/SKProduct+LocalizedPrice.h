//
//  SKProduct+LocalizedPrice.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 11/28/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end
