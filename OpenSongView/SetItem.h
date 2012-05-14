//
//  SetItem.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/14/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Set;

@interface SetItem : NSManagedObject

@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) Set *set;

@end
