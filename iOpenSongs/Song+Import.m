//
//  Song+Import.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 1/14/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "Song+Import.h"
#import "Song+OpenSong.h"

NSString *const SongImportWillImport  = @"SongImportWillImport";
NSString *const SongImportAttributeName  = @"SongImportAttributeName";
NSString *const SongImportAttributeProgress  = @"SongImportAttributeProgress";


@implementation Song (Import)

#pragma mark Private Methods

+ (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark Public Methods

+ (void)importApplicationDocumentsIntoContext:(NSManagedObjectContext *)managedObjectContext error:(NSError **)error
{
    NSMutableArray *errors = [NSMutableArray arrayWithCapacity:0];
    
    NSString *documentsDirectoryPath = [self applicationDocumentsDirectory];
    NSArray *documentsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:NULL];
    
    [documentsDirectoryContents enumerateObjectsUsingBlock:^(NSString *curFileName, NSUInteger idx, BOOL *stop) {
        // send a progress notification
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNumber *progress = @((float)idx / (float)documentsDirectoryContents.count);
            NSDictionary *notificationInfo = @{SongImportAttributeName: curFileName, SongImportAttributeProgress: progress};
            [[NSNotificationCenter defaultCenter] postNotificationName:SongImportWillImport object:curFileName userInfo:notificationInfo];
        });
        
        NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:curFileName];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        
        // ignore directories and certain files
        if (isDirectory || [curFileName isEqualToString:@"Inbox"] || [curFileName isEqualToString:@".DS_Store"]) {
            return;
        }
        
        NSLog(@"File: %@", curFileName);
        
        NSDictionary *info = [Song openSongInfoWithOpenSongFileUrl:fileURL];
        // record error if no info
        if (!info) {
            NSLog(@"Error: %@", curFileName);
            [errors addObject:curFileName];
            return;
        }
        
        // import info
        [managedObjectContext performBlock:^{ // perform in the NSMOC's safe thread (main thread)
            NSArray *songsBeforeImport = [Song MR_findAll];
            
            // check if song already exists based on title
            Song *songFound = nil;
            for (Song *song in songsBeforeImport) {
                if ([song.title isEqualToString:[info valueForKey:@"title"]]) {
                    songFound = song;
                    break;
                }
            }
            
            if (songFound) {
                [songFound updateWithOpenSongInfo:info];
            } else {
                [Song songWithOpenSongInfo:info inManagedObjectContext:managedObjectContext];
            }
        }];
        
    }];
    
    // process import issues
    if (errors.count > 0) {
        NSString *failureReason = [NSString stringWithFormat:@"Issue importing %d file(s):", errors.count];
        NSString *failureDescription = [errors componentsJoinedByString:@"\n"];
        NSString *recoverySuggestion = @"Make sure the files are in the OpenSong format.";

        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
        [errorInfo setValue:failureReason forKey:NSLocalizedFailureReasonErrorKey];
        [errorInfo setValue:failureDescription forKey:NSLocalizedDescriptionKey];
        [errorInfo setValue:recoverySuggestion forKey:NSLocalizedRecoverySuggestionErrorKey];
        
        *error = [NSError errorWithDomain:@"import" code:100 userInfo:errorInfo];
    }
    
    [managedObjectContext MR_saveToPersistentStoreAndWait];
}

+ (void)importDemoSongIntoContext:(NSManagedObjectContext *)managedObjectContext
{
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"DemoFile" withExtension:@""];
    NSDictionary *info = [Song openSongInfoWithOpenSongFileUrl:fileURL];
    [Song songWithOpenSongInfo:info inManagedObjectContext:managedObjectContext];
    
    [managedObjectContext MR_saveToPersistentStoreAndWait];
}



@end
