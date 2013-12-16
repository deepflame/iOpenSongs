//
//  Set+Cloning.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/16/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "Set.h"

@interface Set (Cloning)

- (instancetype)cloneInContext:(NSManagedObjectContext *)context;

@end
