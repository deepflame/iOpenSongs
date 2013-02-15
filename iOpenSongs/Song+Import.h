//
//  Song+Import.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 1/14/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "Song.h"

// Notification that gets sent before an item gets imported
extern NSString *const SongImportWillImport;
// Notification userinfo keys
extern NSString *const SongImportAttributeName; // the file to be imported
extern NSString *const SongImportAttributeProgress; // in float value 0..1

@interface Song (Import)

+ (void)importApplicationDocumentsIntoContext:(NSManagedObjectContext *)managedObjectContext
                                        error:(NSError **)error;

+ (void)importDemoSongIntoContext:(NSManagedObjectContext *)managedObjectContext;

@end
