//
//  PaymentHistoryListViewController.m
//  SakuttoBook
//
//  Created by okano on 11/06/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaymentHistoryListViewController.h"


@implementation PaymentHistoryListViewController


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
	UIBarButtonItem *paymentHistoryButton = [[UIBarButtonItem alloc] initWithTitle:@"close"
																			 style:UIBarButtonItemStyleBordered
																			target:self
																			action:@selector(closeThisView)];
	UIBarButtonItem *flexibleSpaceButton = [[UIBarButtonItem alloc]
						   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
						   target:nil
						   action:nil];
#if defined(HIDE_RESTORE_BUTTON) && HIDE_RESTORE_BUTTON != 0
	//Hide Restore Button.
	NSArray *items = [NSArray arrayWithObjects:paymentHistoryButton, flexibleSpaceButton, nil];
#else
	UIBarButtonItem *restoreButton = [[UIBarButtonItem alloc] initWithTitle:@"Restore"
																	  style:UIBarButtonItemStyleBordered
																	 target:self
																	 action:@selector(showAlertForRestoreTransaction:)];
	NSArray *items = [NSArray arrayWithObjects:paymentHistoryButton, flexibleSpaceButton, restoreButton, nil];
#endif
	[toolbar setItems:items];
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

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.	
	return ([appDelegate.paymentHistoryDS count] + 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	cell.userInteractionEnabled = NO;
	if (indexPath.row < [appDelegate.paymentHistoryDS count]) {
		cell.textLabel.numberOfLines = 0;
		cell.textLabel.text = [appDelegate.paymentHistoryDS descriptionAtIndex:indexPath.row];
	} else {
		cell.textLabel.text = [NSString stringWithFormat:@"Total %d record(s).", [appDelegate.paymentHistoryDS count]];
	}
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//return 97.0;
	return 122.0;
}

#pragma mark -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

#pragma mark - Restore Completed Transactons.


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//LOG_CURRENT_METHOD;
	//DebugLog(@"view tag=%d, index=%d", alertView.tag, buttonIndex);
	if (alertView.tag == ALERTVIEW_TAG_RESTORE_TRANSACTION) {
		//Restore transaction.
		if (buttonIndex == 1) {
			//Restore Transaction.
			[self restoreTransaction];
		}
	} else if (alertView.tag == ALERTVIEW_TAG_RESTORE_TRANSACTION) {
		//Do nothing.
	}
}

- (void)restoreCompletedTransactions
{
	PaymentConductor* paymentConductor = appDelegate.paymentConductor;
	[paymentConductor myRestoreCompletedTransactions];
}





#pragma mark - Request restore transaction. (async)
- (IBAction)showAlertForRestoreTransaction:(id)sender
{
	LOG_CURRENT_METHOD;
	NSString* message = [NSString stringWithFormat:@"他の端末の購入情報をこの端末でも使用する場合は、購入情報の復元が必要です。復元しますか？"];
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"購入情報の復元"
													message:message
												   delegate:self
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"復元", nil];
	alert.tag = ALERTVIEW_TAG_RESTORE_TRANSACTION;
	[alert show];
}
- (void)showAlertForDisableRestore
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
													message:@"現在ネットワークに接続されていないため、購入情報を復元できません"
												   delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	alert.tag = ALERTVIEW_TAG_RESTORE_TRANSACTION_DISABLE;
	[alert show];
}

- (void)restoreTransaction
{
	LOG_CURRENT_METHOD;
	//Check Network Reachability for connect purchase server in Apple.
	/* [FIXME] */
	/*
	if ((status3G == NO) && (statusWifi == NO)) {
		[self showAlertForDisableRestore];
		return;
	}
	*/
	
	PaymentConductor* conductor = appDelegate.paymentConductor;
	conductor.parentVC = self;
	[conductor myRestoreCompletedTransactions];
	
	//Show ActivityIndicator.
	//[self showActivityIndicator];
}


- (void)restoreDidSuccess:(SKPaymentTransaction*)transaction
{
	LOG_CURRENT_METHOD;
	NSLog(@"restore success. transaction=%@", [transaction description]);
	
	//Pickup original purchase date.
	NSDate* originalPurchaseDate = [NSDate dateWithTimeIntervalSinceNow:0.0f];
	if (transaction.originalTransaction != nil) {
		originalPurchaseDate = transaction.originalTransaction.transactionDate;
		NSLog(@"originalPurchaseDate=%@", [originalPurchaseDate description]);
	}

	
	//Add payment history record.
	PaymentHistoryDS* paymentHistory = appDelegate.paymentHistoryDS;
	SKPayment* payment = [[transaction originalTransaction] payment];
	
	NSString* originalProductId = [payment productIdentifier];
	ContentId contentId = [appDelegate.contentListDS contentIdFromProductId:originalProductId];
	NSLog(@"contentId=%d, originalProductId=%@, originalPurchaseDate=%@", contentId, originalProductId, [originalPurchaseDate description]);
	
	[paymentHistory recordHistoryOnceWithContentId:contentId ProductId:originalProductId date:originalPurchaseDate];
}
- (void)restoreDidFailed:(SKPaymentTransaction*)transaction
{
	LOG_CURRENT_METHOD;
}
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
	LOG_CURRENT_METHOD;
	for (SKPaymentTransaction* transaction in [queue transactions])
	{
		NSLog(@"productIdentifier = %@", [[[transaction originalTransaction] payment] productIdentifier]);
	}
	
	//Show alert.
	UIAlertView *alert = [[[UIAlertView alloc]
						   initWithTitle:@""
						   message:@"購入情報の復元に成功しました。"
						   delegate:nil
						   cancelButtonTitle:nil
						   otherButtonTitles:@"OK", nil]
						  autorelease];
	[alert show];
	
	//Hide ActivityIndicator.
	//[self hideActivityIndicator];
}
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
	LOG_CURRENT_METHOD;
	NSLog(@"restoreCompletedTransactionsFailedWithError. error = %@", [error localizedDescription]);
	for (SKPaymentTransaction* transaction in [queue transactions])
	{
		NSLog(@"productIdentifier = %@", [[[transaction originalTransaction] payment] productIdentifier]);
	}
	
	
	//Error.
	NSLog(@"restore failed. error code=%d, error description=%@", error.code, [error description]);
	
	if (error.code != SKErrorPaymentCancelled)
	{
		//Show alert.
		UIAlertView *alert = [[[UIAlertView alloc]
							   initWithTitle:@""
							   message:[NSString stringWithFormat:@"購入情報の復元に失敗しました。詳細：%@", [error localizedDescription]]
							   delegate:nil
							   cancelButtonTitle:nil
							   otherButtonTitles:@"OK", nil]
							  autorelease];
		[alert show];
	}
	//Hide ActivityIndicator.
	//[self hideActivityIndicator];
}


- (void)purchaseDidSuccess:(NSString*)productId
{
	LOG_CURRENT_METHOD;
	NSLog(@"purchase success. , productId=%@", productId);
	
	//Refresh table data.
	[myTableView reloadData];
}





#pragma mark -
- (void)closeThisView
{
	[self.view removeFromSuperview];
}
#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
