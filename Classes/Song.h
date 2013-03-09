//
//  Song.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/9/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SetItemSong;

@interface Song : NSManagedObject

@property (nonatomic, retain) NSString * aka;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * capo;
@property (nonatomic, retain) NSNumber * capo_print;
@property (nonatomic, retain) NSString * ccli;
@property (nonatomic, retain) NSString * copyright;
@property (nonatomic, retain) NSString * hymn_number;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * key_line;
@property (nonatomic, retain) NSString * lyrics;
@property (nonatomic, retain) NSString * presentation;
@property (nonatomic, retain) NSString * tempo;
@property (nonatomic, retain) NSString * theme;
@property (nonatomic, retain) NSString * time_sig;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * titleNormalized;
@property (nonatomic, retain) NSString * titleSectionIndex;
@property (nonatomic, retain) NSSet *setItems;
@end

@interface Song (CoreDataGeneratedAccessors)

- (void)addSetItemsObject:(SetItemSong *)value;
- (void)removeSetItemsObject:(SetItemSong *)value;
- (void)addSetItems:(NSSet *)values;
- (void)removeSetItems:(NSSet *)values;

@end
