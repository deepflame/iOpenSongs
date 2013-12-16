//
//  NSManagedObject+Cloning.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/15/13.
//
//  Based on: http://stackoverflow.com/questions/2730832/how-can-i-duplicate-or-copy-a-core-data-managed-object

#import "NSManagedObject+Cloning.h"

@implementation NSManagedObject (Cloning)

- (instancetype)clone
{
    return [self cloneInContext:self.managedObjectContext];
}

- (instancetype)cloneInContext:(NSManagedObjectContext *)context
{
    NSString *entityName = [[self entity] name];
    
    // create entity
    NSManagedObject *cloned = [NSEntityDescription
                               insertNewObjectForEntityForName:entityName
                               inManagedObjectContext:context];
    
    // set attributes
    NSDictionary *attributes = [[NSEntityDescription
                                 entityForName:entityName
                                 inManagedObjectContext:context] attributesByName];
    
    for (NSString *attr in attributes) {
        [cloned setValue:[self valueForKey:attr] forKey:attr];
    }
    
    // set relationships (only one-to-one)
    NSDictionary *relationships = [[NSEntityDescription
                                    entityForName:entityName
                                    inManagedObjectContext:context] relationshipsByName];
    
    for (NSString *relName in [relationships allKeys]) {
        
        NSRelationshipDescription *rel = [relationships objectForKey:relName];
        if (! [rel isToMany]) {
            [cloned setValue:[self valueForKey:relName] forKey:relName];
        }
        
    }
    
    return cloned;
}

@end
