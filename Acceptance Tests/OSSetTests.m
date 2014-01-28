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
    NSLog(@"KIF: beforeAll");
    // not called when running in TravisCI
}

- (void)afterAll
{
    NSLog(@"KIF: afterAll");
    // not called when running in TravisCI
}

- (void)beforeEach
{
    NSLog(@"KIF: beforeEach");
    [tester toggleSideBar];
    [tester tapViewWithAccessibilityLabel:@"Sets" traits:UIAccessibilityTraitButton];
}

- (void)afterEach
{
    NSLog(@"KIF: afterEach");
    [tester toggleSideBar];
}

- (void)testAdd
{
    [tester tapViewWithAccessibilityLabel:@"Add Set" traits:UIAccessibilityTraitButton];
    [tester enterTextIntoCurrentFirstResponder:@"New Set"];
}

@end
