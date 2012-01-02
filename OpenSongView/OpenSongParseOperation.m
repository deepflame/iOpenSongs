//
//  OpenSongParseOperation.m
//  OpenSongView
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2011 Open iT Norge AS. All rights reserved.
//

#import "OpenSongParseOperation.h"
#import "Song.h"


// NSNotification name for sending Song data back to the app delegate
NSString *kSongSuccessNotif = @"SongSuccessNotif";

// NSNotification userInfo key for obtaining the Song data
NSString *kSongSuccessKey = @"SongSuccessKey";

// NSNotification name for reporting errors
NSString *kSongErrorNotif = @"SongErrorNotif";

// NSNotification userInfo key for obtaining the error message
NSString *kSongErrorKey = @"SongErrorKey";


@interface OpenSongParseOperation () <NSXMLParserDelegate>
    @property (nonatomic, retain) Song *currentSongObject;
    @property (nonatomic, retain) NSMutableString *currentParsedCharacterData;
@end

@implementation OpenSongParseOperation

@synthesize songData;
@synthesize currentSongObject;
@synthesize currentParsedCharacterData;

- (id)initWithData:(NSData *)parseData
{
    if (self = [super init]) {    
        songData = [parseData copy];
    }
    return self;
}

// the main function for this NSOperation, to start the parsing
- (void)main {
    self.currentSongObject = [[Song alloc] init];
    self.currentParsedCharacterData = [NSMutableString string];
    
    // It's also possible to have NSXMLParser download the data, by passing it a URL, but this is
    // not desirable because it gives less control over the network, particularly in responding to
    // connection errors.
    //
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.songData];
    [parser setDelegate:self];
    [parser parse];
}

#pragma mark -
#pragma mark Parser constants

// When an Song object has been fully constructed, it must be passed to the main thread and
// the table view in RootViewController must be reloaded to display it. It is not efficient to do
// this for every Song object - the overhead in communicating between the threads and reloading
// the table exceed the benefit to the user. Instead, we pass the objects in batches, sized by the
// constant below. In your application, the optimal batch size will vary 
// depending on the amount of data in the object and other factors, as appropriate.
//
static NSUInteger const kSizeOfSongBatch = 10;

// Reduce potential parsing errors by using string constants declared in a single place.
static NSString * const kTitleElementName = @"title";
static NSString * const kAuthorElementName = @"author";
static NSString * const kLyricsElementName = @"lyrics";


#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"Parsed Song");

    [[NSNotificationCenter defaultCenter] postNotificationName:kSongSuccessNotif
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:currentSongObject
                                                                                           forKey:kSongSuccessKey]];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {

    if ([elementName isEqualToString:kTitleElementName] ||
        [elementName isEqualToString:kAuthorElementName] ||
        [elementName isEqualToString:kLyricsElementName]) {
        // For the 'title', or 'lyrics' element begin accumulating parsed character data.
        // The contents are collected in parser:foundCharacters:.
        accumulatingParsedCharacterData = YES;
        // The mutable string needs to be reset to empty.
        [currentParsedCharacterData setString:@""];
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {     
    if ([elementName isEqualToString:kTitleElementName]) {
        currentSongObject.title = [self.currentParsedCharacterData copy];
    } else if ([elementName isEqualToString:kAuthorElementName]) {
        currentSongObject.author = [self.currentParsedCharacterData copy];
    } else if ([elementName isEqualToString:kLyricsElementName]) {
        currentSongObject.lyrics = [self.currentParsedCharacterData copy];
    }
    // Stop accumulating parsed character data. We won't start again until specific elements begin.
    accumulatingParsedCharacterData = NO;
}

// This method is called by the parser when it find parsed character data ("PCDATA") in an element.
// The parser is not guaranteed to deliver all of the parsed character data for an element in a single
// invocation, so it is necessary to accumulate character data until the end of the element is reached.
//
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (accumulatingParsedCharacterData) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        //
        [self.currentParsedCharacterData appendString:string];
    }
}

// an error occurred while parsing the Song data,
// post the error as an NSNotification to our app delegate.
// 
- (void)handleSongsError:(NSError *)parseError {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSongErrorNotif
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:parseError
                                                                                           forKey:kSongErrorKey]];
}

// an error occurred while parsing the Song data,
// pass the error to the main thread for handling.
// (note: don't report an error if we aborted the parse due to a max limit of Songs)
//
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if ([parseError code] != NSXMLParserDelegateAbortedParseError) {
        [self performSelectorOnMainThread:@selector(handleSongsError:)
                               withObject:parseError
                            waitUntilDone:NO];
    }
}

@end
