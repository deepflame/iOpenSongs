//
//  UIManagedDocumentTableViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/12/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface UIManagedDocumentTableViewController : CoreDataTableViewController

@property (nonatomic, strong) UIManagedDocument *database;  // Model is a Core Data database

@end
