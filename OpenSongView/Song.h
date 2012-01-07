//
//  Song.h
//  OpenSongView
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2011 Open iT Norge AS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Song : NSObject {
@private
    NSString *title;
    NSString *author;
    NSString *lyrics;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSString *lyrics;

- (NSString *)lyricsAsHtml;

@end
