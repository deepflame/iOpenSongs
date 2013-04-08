//
//  OSSetViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 4/8/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SYPaginator.h>

#import "Set.h"

@interface OSSetViewController : SYPaginatorViewController

@property (nonatomic, strong) Set *set;

@end
