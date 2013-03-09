//
//  Song+PrimitiveAccessors.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/9/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "Song.h"

@interface Song (PrimitiveAccessors)

- (void)setPrimitiveTitle:(NSString *)title;
- (void)setPrimitiveTitleNormalized:(NSString *)titleNormalized;
- (void)setPrimitiveTitleSectionIndex:(NSString *)titleSectionTitle;

@end
