//
//  NSManagedObject+Cloning.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/15/13.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Cloning)

- (instancetype)cloneInContext:(NSManagedObjectContext *)context;

- (instancetype)clone;

@end
