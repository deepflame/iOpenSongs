//
//  MasterViewController.m
//  OpenSongMasterDetail
//
//  Created by Andreas Böhrnsen on 1/1/12.
//  Copyright (c) 2012 Open iT Norge AS. All rights reserved.
//

#import "SongMasterViewController.h"

@interface SongMasterViewController ()

- (NSString *)applicationDocumentsDirectory;
- (void)reloadFiles;
@end


@synthesize documentURLs;
@implementation SongMasterViewController
@synthesize detailViewController = _detailViewController;


- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    
    // Add refresh button to the navigation view
    UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction:)];
    [self navigationItem].rightBarButtonItem = refreshBarButtonItem;
    
    
    self.detailViewController = (SongViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    self.documentURLs = [NSMutableArray array];
    [self reloadFiles];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.documentURLs = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.documentURLs count] == 0) {
        return 1; //we will display a Demo file
    }
    return self.documentURLs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"dyncamicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }

    // display the DemoFile when there is no file transferred yet
    NSURL *fileUrl = nil;
    if ([self.documentURLs count] == 0) {
        fileUrl = [[NSBundle mainBundle] URLForResource:@"DemoFile" withExtension:@""];
    } else {
        fileUrl = (NSURL *) [self.documentURLs objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = fileUrl.lastPathComponent;
    
    return cell;
}

#pragma mark -
#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // display the DemoFile when there is no file transferred yet
    NSURL *fileUrl = nil;
    if ([self.documentURLs count] == 0) {
        fileUrl = [[NSBundle mainBundle] URLForResource:@"DemoFile" withExtension:@""];  
    } else {
        fileUrl = (NSURL *) [self.documentURLs objectAtIndex:indexPath.row];
    }
    
    [_detailViewController parseSongFromUrl:fileUrl];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark -
#pragma mark File system support

- (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)reloadFiles
{
	[self.documentURLs removeAllObjects];    // clear out the old docs and start over
	
	NSString *documentsDirectoryPath = [self applicationDocumentsDirectory];
	
	NSArray *documentsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:NULL];
    
	for (NSString* curFileName in [documentsDirectoryContents objectEnumerator]) {
		NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:curFileName];
		NSURL *fileURL = [NSURL fileURLWithPath:filePath];
		
		BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
		
        // proceed to add the document URL to our list (ignore the "Inbox" folder)
        if (!(isDirectory && [curFileName isEqualToString: @"Inbox"])) {
            [self.documentURLs addObject:fileURL];
        }
	}
	
	[self.tableView reloadData];
}

- (IBAction)refreshAction:(id)sender 
// Called when the user taps the Refresh button.
{
#pragma unused(sender)
    [self reloadFiles];
}

@end
