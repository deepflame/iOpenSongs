//
//  KIFUITestActor+OSAdditions.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 1/24/14.
//  Copyright (c) 2014 Andreas Boehrnsen. All rights reserved.
//

#import "KIFUITestActor+OSAdditions.h"

@implementation KIFUITestActor (OSAdditions)

- (void)toggleSideBar
{
    [tester tapViewWithAccessibilityLabel:@"Sidebar"];
}

@end
