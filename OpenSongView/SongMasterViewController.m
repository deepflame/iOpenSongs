//
//  MasterViewController.m
//  OpenSongMasterDetail
//
//  Created by Andreas Böhrnsen on 1/1/12.
//  Copyright (c) 2012 Open iT Norge AS. All rights reserved.
//

#import "SongMasterViewController.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface SongMasterViewController () <UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray *allTableData;
@property (strong, nonatomic) NSMutableArray *filteredTableData;
@property (nonatomic) BOOL isFiltered;

- (NSString *)applicationDocumentsDirectory;
- (void)reloadFiles;
@end


@implementation SongMasterViewController

@synthesize allTableData = _allTableData;
@synthesize filteredTableData = _filteredTableData;
@synthesize isFiltered = _isFiltered;

@synthesize delegate = _delegate;


- (NSURL *) songAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *fileUrl = nil;
    if (self.isFiltered) {
        fileUrl = (NSURL *) [self.filteredTableData objectAtIndex:indexPath.row];
    } else {
        fileUrl = (NSURL *) [self.allTableData objectAtIndex:indexPath.row];
    }
    return fileUrl;
}

-(NSArray *)allTableData
{
    if(!_allTableData) {
        _allTableData = [NSMutableArray array];
    }
    return _allTableData;
}

- (SongViewController *)splitViewSongViewController
{
    id svc = [self.splitViewController.viewControllers lastObject];
    
    if ([svc isKindOfClass:[UINavigationController class]]) {
        svc = ((UINavigationController *) svc).topViewController;
    }
    
    if (![svc isKindOfClass:[SongViewController class]]) {
        svc = nil;
    }
    return svc;
}

#pragma mark - View lifecycle

- (void)awakeFromNib 
{
    [super awakeFromNib];
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    
    self.splitViewController.delegate = self; // always try to be the split view's delegate
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    [self reloadFiles];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.allTableData = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


#pragma mark UISplitViewControllerDelegate

// helper method for the delegate
- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    
    if ([detailVC isKindOfClass:[UINavigationController class]]) {
        detailVC = ((UINavigationController *) detailVC).topViewController;
    }
    
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Songs";
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.isFiltered) {
        return self.filteredTableData.count;        
    }
    return self.allTableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Song Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }

    NSURL *fileUrl = [self songAtIndexPath:indexPath];
    cell.textLabel.text = fileUrl.lastPathComponent;
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *fileUrl = [self songAtIndexPath:indexPath];
    
    // setting the song url
    if ([self splitViewSongViewController]) {
        [[self splitViewSongViewController] parseSongFromUrl:fileUrl];
    } else {
        [self.delegate songMasterViewControllerDelegate:self choseSong:fileUrl];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UISearchBarDelegate

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0) {
        self.isFiltered = NO;
    } else {
        self.isFiltered = YES;
        self.filteredTableData = [[NSMutableArray alloc] init];
        
        for (NSURL *fileURL in self.allTableData) {
            NSRange nameRange = [fileURL.lastPathComponent rangeOfString:text options:NSCaseInsensitiveSearch];
            NSRange descriptionRange = [fileURL.description rangeOfString:text options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound || descriptionRange.location != NSNotFound) {
                [self.filteredTableData addObject:fileURL];
            }
        }
    }
    
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark File system support

- (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)reloadFiles
{
	[self.allTableData removeAllObjects];    // clear out the old docs and start over
	
	NSString *documentsDirectoryPath = [self applicationDocumentsDirectory];
	
	NSArray *documentsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:NULL];
    
	for (NSString* curFileName in [documentsDirectoryContents objectEnumerator]) {
		NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:curFileName];
		NSURL *fileURL = [NSURL fileURLWithPath:filePath];
		
		BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
		
        // proceed to add the document URL to our list (ignore the "Inbox" folder)
        if (!(isDirectory && [curFileName isEqualToString: @"Inbox"])) {
            [self.allTableData addObject:fileURL];
        }
	}
    
    // add a demo file if nothing is present
    if ([self.allTableData count] == 0) {
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"DemoFile" withExtension:@""];
        [self.allTableData addObject:fileURL];
    }
    
	[self.tableView reloadData];
}

- (IBAction)refreshList:(id)sender 
// Called when the user taps the Refresh button.
{
#pragma unused(sender)
    [self reloadFiles];
}

@end
