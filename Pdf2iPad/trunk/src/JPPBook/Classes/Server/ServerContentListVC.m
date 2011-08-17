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
	//Setup TableView, Toolbar..
    [super viewDidLoad];
	
	
	
	//Setup TableView.
	myTableView.delegate = self;
	myTableView.dataSource = self;
	
	[self reloadData];
}

#pragma mark - show other view.
- (void)showContentList:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	[appDelegate hideServerContentListView];
	[appDelegate showContentListView];
}
- (void)showServerContentDetailView:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	[appDelegate hideServerContentListView];
	[appDelegate showServerContentDetailView:cid];
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
	NSString* targetPid = [appDelegate.contentListDS productIdFromContentId:targetCid];
	if (targetPid == InvalidProductId) {
		NSLog(@"Invalid productId. cid=%d", targetCid);
		return nil;
	}
	//NSLog(@"indexPath.row=%d, cid=%d, pid=%@", indexPath.row, targetCid, targetPid);
	
    // Configure the cell...
	cell.titleLabel.text = [appDelegate.contentListDS titleByContentId:targetCid];
	cell.authorLabel.text = [appDelegate.contentListDS authorByContentId:targetCid];
	//Check payment status.
	if (([InAppPurchaseUtility isFreeContent:targetPid] == TRUE)
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
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	//Check payment status.
	ContentId targetCid = [appDelegate.contentListDS contentIdAtIndex:indexPath.row];
	NSString* targetPid = [appDelegate.contentListDS productIdFromContentId:targetCid];
	//LOG_CURRENT_METHOD;
	//NSLog(@"indexPath.row=%d, targetCid=%d, targetPid=%@", indexPath.row, targetCid, targetPid);
	
	BOOL isPayedContent = NO;
	if ([InAppPurchaseUtility isFreeContent:targetPid] == TRUE) {
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
