//
//  OSSongPageView.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 4/8/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSSongPageView.h"

@implementation OSSongPageView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithReuseIdentifier:reuseIdentifier])) {        
		_songView = [[OSSongView alloc] initWithFrame:self.bounds];
		_songView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:_songView];
	}
	return self;
}

@end
