//
//  Set.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 9/22/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SetItem;

@interface Set : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *items;
@end

@interface Set (CoreDataGeneratedAccessors)

- (void)addItemsObject:(SetItem *)value;
- (void)removeItemsObject:(SetItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
