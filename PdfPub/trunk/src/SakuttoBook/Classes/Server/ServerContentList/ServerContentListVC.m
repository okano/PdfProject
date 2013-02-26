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
	[self setupNetworkReachability];
	
	//Setup View.
    [super viewDidLoad];
	
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
	/*
	UIBarButtonItem *configButton = [[UIBarButtonItem alloc] initWithTitle:@"Config"
																	 style:UIBarButtonItemStyleBordered
																	target:self
																	action:@selector(showConfigView)];
	 */
	UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	spacer2.width = 40.0f;
	UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																				  target:self
																				  action:@selector(reloadFromNetwork)];
	activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];

	NSArray *items = [NSArray arrayWithObjects:localContentButton, paymentHistoryButton, spacer1, activityItem, spacer2, reloadButton, nil];
	[toolbar setItems:items];
	[localContentButton release]; localContentButton = nil;
	[paymentHistoryButton release]; paymentHistoryButton = nil;
	[spacer1 release]; spacer1 = nil;
	/* [configButton release]; configButton = nil; */
	[spacer2 release]; spacer2 = nil;
	[reloadButton release]; reloadButton = nil;
	[activityItem release]; activityItem = nil;
}
//Setup network reachability.
- (void)setupNetworkReachability
{
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
	
#if defined(OVERWRITE_PRODUCTIDLIST_BY_SERVER) && OVERWRITE_PRODUCTIDLIST_BY_SERVER != 0
	//Get productIdList from server.
	[[ProductIdList sharedManager] refreshProductIdListFromNetwork];
#endif
}

- (void)reloadFromNetwork
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
	[[ProductIdList sharedManager] refreshProductIdListFromNetwork];
	
	//Reload OPDS from network.
	//[appDelegate.serverContentListDS removeAllObjects];
	[appDelegate.serverContentListDS loadContentListFromNetworkByOpds];
}
- (IBAction)reloadFromNetwork:(id)sender { [self reloadFromNetwork]; }

#pragma mark - show other view.
- (void)showContentList
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	[appDelegate hideServerContentListView];
	[appDelegate showContentListView];
}
- (IBAction)showContentList:(id)sender { [self showContentList]; }

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
	//[self presentModalViewController:configVC animated:YES];
	configVC.view.frame = self.view.frame;
	[self.view addSubview:configVC.view];
	//[configVC release]; configVC = nil;
}


#pragma mark - MyTableViewVCProtocol (Accessor for table)
- (void)reloadData
{
	//[myTableView reloadData];
	//Do nothing.
}

- (void)didFinishParseOpdsRoot:(NSURL*)elementUrl
{
	LOG_CURRENT_METHOD;
	[self performSelector:@selector(stopIndicator) withObject:nil];
}
- (void)didFailParseOpdsRoot{
	LOG_CURRENT_METHOD;
	UIAlertView *alert = [[[UIAlertView alloc]
						   initWithTitle:nil
						   message:@"コンテンツ情報の読み込みに失敗しました。"
						   delegate:nil
						   cancelButtonTitle:nil
						   otherButtonTitles:@"OK", nil]
						  autorelease];
	[alert show];
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
