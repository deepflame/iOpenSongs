//
//  Song+Import.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 1/14/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "Song.h"

@interface Song (Import)

+ (void)importApplicationDocumentsIntoContext:(NSManagedObjectContext *)managedObjectContext
                                        error:(NSError **)error;

+ (void)importDemoSongIntoContext:(NSManagedObjectContext *)managedObjectContext;

@end
