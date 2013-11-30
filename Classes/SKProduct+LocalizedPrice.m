//
//  SKProduct+LocalizedPrice.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 11/28/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "SKProduct+LocalizedPrice.h"

@implementation SKProduct (LocalizedPrice)

- (NSString *)localizedPrice
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    return [numberFormatter stringFromNumber:self.price];
}

@end
