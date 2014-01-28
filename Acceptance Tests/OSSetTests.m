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
}

- (void)afterAll
{
    NSLog(@"KIF: afterAll");
}

- (void)beforeEach
{
    NSLog(@"KIF: beforeEach");
}

- (void)afterEach
{
    NSLog(@"KIF: afterEach");
}

- (void)testAdd
{
    [tester toggleSideBar];
    [tester tapViewWithAccessibilityLabel:@"Sets" traits:UIAccessibilityTraitButton];
    [tester tapViewWithAccessibilityLabel:@"Add Set" traits:UIAccessibilityTraitButton];
    [tester enterTextIntoCurrentFirstResponder:@"New Set"];
}

@end
