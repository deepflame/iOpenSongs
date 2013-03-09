//
//  Song+AccessorOverrides.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/9/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "Song.h"

@interface Song (AccessorOverrides)

- (void)setTitle:(NSString *)title;

@end
