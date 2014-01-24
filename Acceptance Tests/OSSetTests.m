//
//  OSSetTests.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 1/24/14.
//  Copyright (c) 2014 Andreas Boehrnsen. All rights reserved.
//

#import <KIF/KIF.h>
#import "KIFUITestActor+OSAdditions.h"

@interface OSSetTests : KIFTestCase
@end

@implementation OSSetTests

- (void)beforeAll
{
    [tester toggleSideBar];
    [tester tapViewWithAccessibilityLabel:@"Sets"];
}

- (void)afterAll
{
    [tester toggleSideBar];
}

- (void)testAdd
{
    [tester tapViewWithAccessibilityLabel:@"Add Set"];
    [tester enterTextIntoCurrentFirstResponder:@"New Set"];
}

@end
