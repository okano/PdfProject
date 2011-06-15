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

	appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	
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
	UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:toolBarFrame];
	UIBarButtonItem *paymentHistoryButton = [[UIBarButtonItem alloc] initWithTitle:@"Purchase History"
																	   style:UIBarButtonItemStyleBordered
																	  target:self
																	  action:@selector(showPaymentHistoryList)];
	NSArray *items = [NSArray arrayWithObjects:paymentHistoryButton, nil];
	[toolbar setItems:items];
	[self.view addSubview:toolbar];
	
	//Setup TableView size.
	CGRect tableViewframe = myTableView.frame;
	CGRect newTableViewframe = CGRectMake(tableViewframe.origin.x,
										  tableViewframe.origin.y + toolBarHeight,
										  tableViewframe.size.width, tableViewframe.size.height - toolBarHeight);
	NSLog(@"tableViewframe=%@", NSStringFromCGRect(tableViewframe));
	NSLog(@"newTableViewframe=%@", NSStringFromCGRect(newTableViewframe));
	
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - show other view.
- (void)showContentPlayer:(ContentId)cid
{
	LOG_CURRENT_METHOD;
	[appDelegate hideContentListView];
	[appDelegate showContentPlayerView:cid];
}
- (void)showContentDetailView:(ContentId)cid
{
	LOG_CURRENT_METHOD;
	[appDelegate hideContentListView];
	[appDelegate showContentDetailView:cid];
}
- (IBAction)showPaymentHistoryList
{
	LOG_CURRENT_METHOD;
	PaymentHistoryListViewController* paymentHistoryListVC = [[PaymentHistoryListViewController alloc] init];
	[self.view addSubview:paymentHistoryListVC.view];
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
    
    // Configure the cell...
	ContentId targetCid = [appDelegate.contentListDS contentIdAtIndex:indexPath.row];
	NSUInteger paymentStat = [appDelegate.contentListDS checkPaymentStatusByContentId:targetCid];
	NSString* paymentStatStr;
	if (paymentStat == PAYMENT_STATUS_PAYED) {
		paymentStatStr = @"payed";
	} else {
		paymentStatStr = @"not_payed";
	}
	/*
	cell.textLabel.text = [NSString stringWithFormat:@"stat=%d, %@, %@",
						   [appDelegate.contentListDS checkPaymentStatusByContentId:targetCid],
						   paymentStatStr,
						   [appDelegate.contentListDS titleByContentId:targetCid]
						   ];
	*/
	cell.titleLabel.text = [appDelegate.contentListDS titleByContentId:targetCid];
	cell.authorLabel.text = [appDelegate.contentListDS authorByContentId:targetCid];
	if ([appDelegate.contentListDS checkPaymentStatusByContentId:targetCid] == TRUE) {
		cell.isDownloadedLabel.text = @"支払済";
		cell.isDownloadedLabel.textColor = [UIColor blueColor];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	} else {
		cell.isDownloadedLabel.text = @"支払未";
		cell.isDownloadedLabel.textColor = [UIColor orangeColor];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	cell.imageView.image = [appDelegate.contentListDS contentIconByContentId:targetCid];
	
	
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	//
	ContentId targetCid = [appDelegate.contentListDS contentIdAtIndex:indexPath.row];
	NSUInteger paymentStatus = [appDelegate.contentListDS checkPaymentStatusByContentId:targetCid];
	
	if (paymentStatus == PAYMENT_STATUS_PAYED) {
		[self showContentPlayer:targetCid];
	} else {
		[self showContentDetailView:targetCid];
	}
}

@end
