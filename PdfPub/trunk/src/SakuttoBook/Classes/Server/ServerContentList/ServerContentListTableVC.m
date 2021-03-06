//
//  ServerContentListVC.m
//  JPPBook
//
//  Created by okano on 11/08/17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerContentListTableVC.h"


@implementation ServerContentListTableVC

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	//Setup Toolbar..
    [super viewDidLoad];
	
	//Setup TableView.
	myTableView.delegate = self;
	myTableView.dataSource = self;
	
	//Setup data.
	//[self setupData];
	//Setup data.
	if (appDelegate.serverContentListDS == nil) {
		appDelegate.serverContentListDS = [[ServerContentListDS alloc] init];
	}
	appDelegate.serverContentListDS.targetTableVC = self;
	[self setupData];
	[self reloadData];
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
	//NSLog(@"targetCid=%d", targetCid);
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
	
	
	//Cover Image.
	//cell.imageView.image = [appDelegate.serverContentListDS contentIconByContentId:targetCid];
	UIImage* coverImage = [CoverUtility coverImageWithUuid:uuid];
	cell.imageView.image = coverImage;

	
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


@end
