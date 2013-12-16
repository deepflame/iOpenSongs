//
//  Set+Cloning.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/16/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "Set+Cloning.h"
#import "NSManagedObject+Cloning.h"

#import "SetItem.h"

@implementation Set (Cloning)

- (instancetype)cloneInContext:(NSManagedObjectContext *)context
{
    Set *clonedSet = [super cloneInContext:context];
    for (SetItem *item in [self.items copy]) {
        SetItem *clonedItem = [item cloneInContext:context];
        [clonedSet addItemsObject:clonedItem];
    }
    return clonedSet;
}

@end
