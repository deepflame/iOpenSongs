//
//  Song.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/26/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Song : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * copyright;
@property (nonatomic, retain) NSString * presentation;
@property (nonatomic, retain) NSString * ccli;
@property (nonatomic, retain) NSString * lyrics;
@property (nonatomic, retain) NSString * capo;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * aka;
@property (nonatomic, retain) NSString * theme;
@property (nonatomic, retain) NSNumber * capo_print;
@property (nonatomic, retain) NSString * key_line;
@property (nonatomic, retain) NSString * user1;
@property (nonatomic, retain) NSString * user2;
@property (nonatomic, retain) NSString * user3;
@property (nonatomic, retain) NSString * tempo;
@property (nonatomic, retain) NSString * time_sig;
@property (nonatomic, retain) NSData * style_background;

@end
