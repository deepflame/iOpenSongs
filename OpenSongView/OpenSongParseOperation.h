//
//  OpenSongParseOperation.h
//  OpenSongView
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2011 Open iT Norge AS. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *kSongSuccessNotif;
extern NSString *kSongSuccessKey;

extern NSString *kSongErrorNotif;
extern NSString *kSongErrorKey;


@class Song;

@interface OpenSongParseOperation : NSOperation {
    NSData *songData;
    
@private
    // these variables are used during parsing
    Song *currentSongObject;
    NSMutableString *currentParsedCharacterData;
    
    BOOL accumulatingParsedCharacterData;
}

@property (copy, readonly) NSData *songData;

- (id)initWithData:(NSData *)parseData;

@end
