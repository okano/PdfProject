//
//  ServerContentListVC.m
//  JPPBook
//
//  Created by okano on 11/08/17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerContentListVC.h"


@implementation ServerContentListVC

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	//Setup network reachability.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reachabilityChanged:)
												 name:kReachabilityChangedNotification
											   object:nil];
	status3G = YES;
	statusWifi = YES;
	internetActive = YES;
	internetReachable = [[Reachability reachabilityForInternetConnection] retain];
	[self updateInterfaceWithReachability:internetReachable];
	
	wifiReachable = [[Reachability reachabilityForLocalWiFi] retain];
	[self updateInterfaceWithReachability:wifiReachable];
	
	NSLog(@"internetEnable=%d, YES=%d, NO=%d", internetActive, YES, NO);
	
	
	//Setup TableView, Toolbar..
    [super viewDidLoad];
	
	
	
	//Setup TableView.
	myTableView.delegate = self;
	myTableView.dataSource = self;
	//Setup data.
	[self setupData];
	
	//Setup Toolbar.
	UIBarButtonItem *localContentButton = [[UIBarButtonItem alloc] initWithTitle:@"Books"
																			style:UIBarButtonItemStyleBordered
																		   target:self
																		   action:@selector(showContentList)];
	UIBarButtonItem *paymentHistoryButton = [[UIBarButtonItem alloc] initWithTitle:@"購入履歴"
																			 style:UIBarButtonItemStyleBordered
																			target:self
																			action:@selector(showPaymentHistoryList)];
	UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *configButton = [[UIBarButtonItem alloc] initWithTitle:@"Config"
																	 style:UIBarButtonItemStyleBordered
																	target:self
																	action:@selector(showConfigView)];
	UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	spacer2.width = 40.0f;
	UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																				  target:self
																				  action:@selector(reloadFromNetwork)];
	activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];

	NSArray *items = [NSArray arrayWithObjects:localContentButton, paymentHistoryButton, spacer1, activityItem,  configButton, spacer2, reloadButton, nil];
	[toolbar setItems:items];
	[localContentButton release]; localContentButton = nil;
	[paymentHistoryButton release]; paymentHistoryButton = nil;
	[spacer1 release]; spacer1 = nil;
	[configButton release]; configButton = nil;
	[spacer2 release]; spacer2 = nil;
	[reloadButton release]; reloadButton = nil;
	[activityItem release]; activityItem = nil;

	[self reloadData];
}

#pragma mark - setup data.
- (void)setupData
{
	LOG_CURRENT_METHOD;
	if (appDelegate.serverContentListDS == nil) {
		appDelegate.serverContentListDS = [[ServerContentListDS alloc] init];
	}
	appDelegate.serverContentListDS.targetTableVC = self;
	[appDelegate.serverContentListDS loadContentList:32];
	
	//Check network enable before get productIdList.
	if (internetActive == NO) {
		LOG_CURRENT_METHOD;
		UIAlertView *alert = [[[UIAlertView alloc]
							   initWithTitle:@"Network error"
							   message:@"Network not found."
							   delegate:nil
							   cancelButtonTitle:nil
							   otherButtonTitles:@"OK", nil]
							  autorelease];
		[alert show];
		
		return;
	}
	
	//Get productIdList.
	[appDelegate.productIdList refreshProductIdListFromNetwork];
}

- (void)reloadFromNetwork;
{
	//Check network enable before connect.
	if (internetActive == NO)
	{
		LOG_CURRENT_METHOD;
		UIAlertView *alert = [[[UIAlertView alloc]
							   initWithTitle:@"Network error"
							   message:@"Network not found."
							   delegate:nil
							   cancelButtonTitle:nil
							   otherButtonTitles:@"OK", nil]
							  autorelease];
		[alert show];
		return;
	}
	
	//Get productIdList before get opds.
	[appDelegate.productIdList refreshProductIdListFromNetwork];
	
	//Reload OPDS from network.
	[appDelegate.serverContentListDS removeAllObjects];
	[appDelegate.serverContentListDS loadContentListFromNetworkByOpds];
}

#pragma mark - show other view.
- (void)showContentList
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	[appDelegate hideServerContentListView];
	[appDelegate showContentListView];
}
- (void)showServerContentDetailView:(NSString*)uuid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	[appDelegate hideServerContentListView];
	[appDelegate showServerContentDetailView:uuid];
}
- (void)showConfigView
{
	ConfigViewController* configVC = [[ConfigViewController alloc] initWithNibName:@"ConfigView"
																			bundle:[NSBundle mainBundle]];
	[self presentModalViewController:configVC animated:YES];
	[configVC release]; configVC = nil;
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
	return [appDelegate.serverContentListDS count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	LOG_CURRENT_METHOD;
	//NSLog(@"serverContentListDS=%@", [appDelegate.serverContentListDS description]);
	//NSLog(@"row=%d", indexPath.row);
	
	static NSString *identifier = @"ContentListCell";
	ContentListCell *cell = (ContentListCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		ContentListCellController *cellController = [[ContentListCellController alloc] initWithNibName:identifier bundle:nil];
		cell = (ContentListCell*)cellController.view;
		[cellController release];
	}
	
    
	//ContentId targetCid = [appDelegate.serverContentListDS contentIdAtIndex:indexPath.row];
	/*
	if (targetCid == InvalidContentId) {
		LOG_CURRENT_LINE;
		NSLog(@"Invalid ContentId.");
	} else if (targetCid == UndefinedContentId) {
		LOG_CURRENT_LINE;
		NSLog(@"UndefinedContentId.");
	}
	NSString* targetPid = [appDelegate.serverContentListDS productIdFromContentId:targetCid];
	if (targetPid == InvalidProductId) {
		NSLog(@"Invalid productId. cid=%d", targetCid);
		return nil;
	}
	NSLog(@"indexPath.row=%d, cid=%d, pid=%@", indexPath.row, targetCid, targetPid);
	*/
	
	//
	NSString* uuid = [appDelegate.serverContentListDS uuidAtIndex:indexPath.row];
	NSLog(@"uuid=%@", uuid);
	
	
    // Configure the cell...
	cell.titleLabel.text = [appDelegate.serverContentListDS titleByUuid:uuid];
	cell.authorLabel.text = [appDelegate.serverContentListDS authorByUuid:uuid];
	
	cell.isDownloadedLabel.hidden = YES;
	
	//Check payment status.
	cell.isDownloadedLabel.hidden = NO;
	ContentId targetCid = [appDelegate.contentListDS contentIdFromUuid:uuid];
	NSLog(@"targetCid=%d", targetCid);
	if ((targetCid != UndefinedContentId)
		&&
		(targetCid != InvalidContentId)
		&&
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
	
	
	//Thumbnail.
	//cell.imageView.image = [appDelegate.serverContentListDS contentIconByContentId:targetCid];
	UIImage* thumbnailImage = [CoverUtility coverImageWithUuid:uuid];
	cell.imageView.image = thumbnailImage;

	
	NSLog(@"title=%@", cell.titleLabel.text);
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
	//ContentId targetCid = [appDelegate.serverContentListDS contentIdAtIndex:indexPath.row];
	//NSString* targetPid = [appDelegate.serverContentListDS productIdFromContentId:targetCid];
	NSString* targetUuid = [appDelegate.serverContentListDS uuidAtIndex:indexPath.row];
	LOG_CURRENT_METHOD;
	//NSLog(@"indexPath.row=%d, targetCid=%d, targetPid=%@", indexPath.row, targetCid, targetPid);
	NSLog(@"indexPath.row=%d, targetUuid=%@", indexPath.row, targetUuid);
	
	//Show detail view.
	//[self showServerContentDetailView:targetCid];
	[self showServerContentDetailView:targetUuid];
}

#pragma mark - MyTableViewVCProtocol (Accessor for table)
- (void)reloadData
{
	[myTableView reloadData];
}

- (void)didFinishParseOpdsRoot:(NSURL*)elementUrl
{
	LOG_CURRENT_METHOD;
	[self performSelector:@selector(stopIndicator) withObject:nil];
}
- (void)didFailParseOpdsRoot{
	LOG_CURRENT_METHOD;
	/*
	UIAlertView *alert = [[[UIAlertView alloc]
						   initWithTitle:nil
						   message:@"fail parse OPDS Root."
						   delegate:nil
						   cancelButtonTitle:nil
						   otherButtonTitles:@"OK", nil]
						  autorelease];
	[alert show];
	*/
	[self performSelector:@selector(stopIndicator) withObject:nil];
}
- (void)didFinishParseOpdsElement:(NSMutableArray*)resultArray{
	LOG_CURRENT_METHOD;
	//NSLog(@"contentList=%@", [appDelegate.serverContentListDS description]);
	[self reloadData];
	[self performSelector:@selector(stopIndicator) withObject:nil];
}
- (void)didFailParseOpdsElement
{
	LOG_CURRENT_METHOD;
	[self performSelector:@selector(stopIndicator) withObject:nil];
}
#pragma mark - MyTableViewVCProtocol(@optional) (Accessor for table)
- (void)didStartParseOpdsRoot
{
	LOG_CURRENT_METHOD;
	[self performSelector:@selector(startIndicator) withObject:nil];
}

- (void)didStartParseOpdsElement
{
	LOG_CURRENT_METHOD;
	[self performSelector:@selector(startIndicator) withObject:nil];
}


#pragma mark - UIActivityIndicator.
- (void)startIndicator
{
	[activityIndicator startAnimating];
}
- (void)stopIndicator
{
	[activityIndicator stopAnimating];
}


#pragma mark - Network reachability.
- (void)updateInterfaceWithReachability:(Reachability*)curReach
{
	//LOG_CURRENT_METHOD;
	NetworkStatus status = [curReach currentReachabilityStatus];
	
	if (curReach == hostReachable) {
		if (status == NotReachable) {
			NSLog(@"host failed");
			internetActive = NO;
		} else {
			NSLog(@"host success");
			internetActive = YES;
		}
	}
	
	if (curReach == internetReachable) {
		if (status == NotReachable) {
			NSLog(@"3G failed.");
			status3G = NO;
		} else {
			NSLog(@"3G success.");
			status3G = YES;
		}
	}
	
	if (curReach == wifiReachable) {
		if (status == NotReachable) {
			NSLog(@"Wi-Fi failed");
			statusWifi = NO;
		} else {
			NSLog(@"Wi-Fi success");
			statusWifi = YES;
		}
	}
	
	if ((status3G == NO) && (statusWifi == NO)) {
		internetActive = NO;
	} else {
		internetActive = YES;
	}
}

- (void)reachabilityChanged:(NSNotification*)note
{
	//LOG_CURRENT_METHOD;
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self updateInterfaceWithReachability:curReach];
}


@end
