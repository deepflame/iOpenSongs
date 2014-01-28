//
//  Acceptance_Tests.m
//  Acceptance Tests
//
//  Created by Andreas Böhrnsen on 1/24/14.
//  Copyright (c) 2014 Andreas Boehrnsen. All rights reserved.
//

#import <KIF/KIF.h>
#import "KIFUITestActor+OSAdditions.h"

@interface Acceptance_Tests : KIFTestCase
@end

@implementation Acceptance_Tests

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
}

- (void)afterEach
{
    NSLog(@"KIF: afterEach");
    [tester toggleSideBar];
}

- (void)testExample
{
    [tester tapViewWithAccessibilityLabel:@"Songs" traits:UIAccessibilityTraitButton];
    [tester tapViewWithAccessibilityLabel:@"Sets" traits:UIAccessibilityTraitButton];
    [tester tapViewWithAccessibilityLabel:@"Settings" traits:UIAccessibilityTraitButton];
    [tester tapViewWithAccessibilityLabel:@"Shop" traits:UIAccessibilityTraitButton];
}

@end