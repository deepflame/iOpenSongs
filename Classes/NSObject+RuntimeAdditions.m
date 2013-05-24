//
//  NSObject+RuntimeAdditions.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/24/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "NSObject+RuntimeAdditions.h"

#import <objc/runtime.h>

@implementation NSObject (RuntimeAdditions)

- (NSArray *)propertyNames
{
    NSUInteger count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableArray *rv = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [rv addObject:name];
    }
    
    free(properties);
    
    return rv;
}

@end
