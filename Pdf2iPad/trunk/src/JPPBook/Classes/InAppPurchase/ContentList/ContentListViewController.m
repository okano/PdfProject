//
//  ContentListViewController.m
//  PurchaseTest04
//
//  Created by okano on 11/05/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContentListViewController.h"


@implementation ContentListViewController

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	//Setup TableView.
	myTableView = [[UITableView alloc] initWithFrame:self.view.frame];
	myTableView.delegate = self;
	myTableView.dataSource = self;
	[self.view addSubview:myTableView];
	
	//Setup Toolbar.
	CGFloat toolBarHeight = 44.0f;
	CGRect toolBarFrame = CGRectMake(0.0f,
									 0.0f,
									 self.view.frame.size.width,
									 toolBarHeight);
	toolbar = [[UIToolbar alloc] initWithFrame:toolBarFrame];
	UIBarButtonItem *serverContentButton = [[UIBarButtonItem alloc] initWithTitle:@"Store"
																			 style:UIBarButtonItemStyleBordered
																			target:self
																			action:@selector(showServerContentListView)];
	UIBarButtonItem *paymentHistoryButton = [[UIBarButtonItem alloc] initWithTitle:@"購入履歴"
																	   style:UIBarButtonItemStyleBordered
																	  target:self
																	  action:@selector(showPaymentHistoryList)];
	NSArray *items = [NSArray arrayWithObjects:serverContentButton, paymentHistoryButton, nil];
	[toolbar setItems:items];
	[serverContentButton release];
	[paymentHistoryButton release];
	[self.view addSubview:toolbar];
	
	//Setup TableView size.
	CGRect tableViewframe = myTableView.frame;
	CGRect newTableViewframe = CGRectMake(tableViewframe.origin.x,
										  tableViewframe.origin.y + toolBarHeight,
										  tableViewframe.size.width, tableViewframe.size.height - toolBarHeight);
	//LOG_CURRENT_METHOD;
	//NSLog(@"tableViewframe=%@", NSStringFromCGRect(tableViewframe));
	//NSLog(@"newTableViewframe=%@", NSStringFromCGRect(newTableViewframe));
	
	myTableView.frame = newTableViewframe;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

#pragma mark -
#pragma mark Handle Rotate.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	//LOG_CURRENT_METHOD;
	//if ([self isChangeOrientationKind:self.interfaceOrientation newOrientation:toInterfaceOrientation] == YES) {
		//Rotate view.
		CGRect frameForTable;
		CGRect frameForToolbar;
		CGFloat statusBarHeight = 44.0f;
		if (toInterfaceOrientation == UIInterfaceOrientationPortrait
			||
			toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			frameForToolbar = CGRectMake(0.0f,
										 0.0f,
										 self.view.bounds.size.width,
										 statusBarHeight);
			frameForTable = CGRectMake(0.0f,
							   statusBarHeight,
							   self.view.bounds.size.height,
							   self.view.bounds.size.height - statusBarHeight);
		} else {
			frameForToolbar = CGRectMake(0.0f, 
										 0.0f, 
										 self.view.bounds.size.height,
										 statusBarHeight)	;
			frameForTable = CGRectMake(0.0f,
							   statusBarHeight,
							   self.view.bounds.size.height,
							   self.view.bounds.size.width - statusBarHeight);
		}
		
		toolbar.frame = frameForToolbar;
		myTableView.frame = frameForTable;
		[myTableView reloadData];
		[myTableView reloadInputViews];
	//}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	//LOG_CURRENT_METHOD;
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (bool)isChangeOrientationKind:(UIInterfaceOrientation)oldOrientation newOrientation:(UIInterfaceOrientation)newOrientation {
	if (oldOrientation == UIDeviceOrientationUnknown) { return NO; }
	if (newOrientation == UIDeviceOrientationUnknown) { return NO; }
	
	if (oldOrientation == UIDeviceOrientationPortrait
		||
		oldOrientation == UIDeviceOrientationPortraitUpsideDown) {
		if (newOrientation == UIDeviceOrientationLandscapeLeft
			||
			newOrientation == UIDeviceOrientationLandscapeRight) {
			return YES;
		} else {
			return NO;
		}
	} else {
		if (newOrientation == UIDeviceOrientationPortrait
			||
			newOrientation == UIDeviceOrientationPortraitUpsideDown) {
			return YES;
		} else {
			return NO;
		}
	}
}

#pragma mark - show other view.
- (void)showContentPlayer:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	[appDelegate hideContentListView];
	[appDelegate showContentPlayerView:cid];
}
- (void)showContentDetailView:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	[appDelegate hideContentListView];
	[appDelegate showContentDetailView:cid];
}
- (void)showServerContentListView
{
	//LOG_CURRENT_METHOD;
	[appDelegate hideContentListView];
	[appDelegate showServerContentListView];
}
- (IBAction)showPaymentHistoryList
{
	//LOG_CURRENT_METHOD;
	PaymentHistoryListViewController* paymentHistoryListVC = [[PaymentHistoryListViewController alloc] init];
	[self.view addSubview:paymentHistoryListVC.view];
	[paymentHistoryListVC release]; paymentHistoryListVC = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.	
    //return 5;
	return [appDelegate.contentListDS count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	static NSString *identifier = @"ContentListCell";
	ContentListCell *cell = (ContentListCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		ContentListCellController *cellController = [[ContentListCellController alloc] initWithNibName:identifier bundle:nil];
		cell = (ContentListCell*)cellController.view;
		[cellController release];
	}
    
	ContentId targetCid = [appDelegate.contentListDS contentIdAtIndex:indexPath.row];
	//NSString* targetPid = [appDelegate.contentListDS productIdFromContentId:targetCid];
	NSString* targetPid = [appDelegate.productIdList getProductIdentifier:targetCid];
	if (targetPid == InvalidProductId) {
		NSLog(@"Invalid productId. cid=%d", targetCid);
		return nil;
	}
	//NSLog(@"indexPath.row=%d, cid=%d, pid=%@", indexPath.row, targetCid, targetPid);
	
    // Configure the cell...
	cell.titleLabel.text = [appDelegate.contentListDS titleByContentId:targetCid];
	cell.authorLabel.text = [appDelegate.contentListDS authorByContentId:targetCid];
	
	//Check payment status.
	cell.isDownloadedLabel.hidden = NO;
	if (([appDelegate.productIdList isFreeContent:targetPid] == TRUE)
		||
		([appDelegate.paymentHistoryDS isEnabledContent:targetCid] == TRUE))
	{
		cell.isDownloadedLabel.text = @"購入済";
		cell.isDownloadedLabel.textColor = [UIColor blueColor];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	} else {
		cell.isDownloadedLabel.text = @"未購入";
		cell.isDownloadedLabel.textColor = [UIColor orangeColor];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	//cover Icon(not page chache thumbnail)
	cell.imageView.image = [appDelegate.contentListDS contentIconByContentId:targetCid];
	
	/*
	if (10 < targetCid) {
		NSLog(@"indexPath.row=%d", indexPath.row);
		NSLog(@"contentListDS[%d]=%@", indexPath.row, [appDelegate.contentListDS descriptionAtIndex:indexPath.row]);
		NSLog(@"contentListDS=%@", [appDelegate.contentListDS description]);
		NSLog(@"cid=%d, paymentHistory=%@", targetCid, [appDelegate.paymentHistoryDS description]);
	}
	*/
	
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 97.0;
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
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	//Check payment status.
	ContentId targetCid = [appDelegate.contentListDS contentIdAtIndex:indexPath.row];
	//NSString* targetPid = [appDelegate.contentListDS productIdFromContentId:targetCid];
	NSString* targetPid = [appDelegate.productIdList getProductIdentifier:targetCid];
	//LOG_CURRENT_METHOD;
	//NSLog(@"indexPath.row=%d, targetCid=%d, targetPid=%@", indexPath.row, targetCid, targetPid);
	
	BOOL isPayedContent = NO;
	if ([appDelegate.productIdList isFreeContent:targetPid] == TRUE) {
		isPayedContent = YES;
		
		//Record free content payment record only first time read.
		[appDelegate.paymentHistoryDS recordHistoryOnceWithProductId:targetPid ];
	}
	if ([appDelegate.paymentHistoryDS isEnabledContent:targetCid] == TRUE) {
		isPayedContent = YES;
	}
	
	if (isPayedContent == YES) {
		[self showContentPlayer:targetCid];
	} else {
		[self showContentDetailView:targetCid];
	}
}

#pragma mark - Accessor for table
- (void)reloadData
{
	[myTableView reloadData];
}
@end
