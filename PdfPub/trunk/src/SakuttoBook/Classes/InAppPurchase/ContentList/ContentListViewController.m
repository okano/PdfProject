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

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
}

@end
