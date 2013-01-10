//
//  SakuttoBookViewController.m
//  SakuttoBook
//
//  Created by okano on 10/12/13.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "SakuttoBookViewController.h"

@implementation SakuttoBookViewController

@synthesize contentPlayerViewController;
@synthesize contentListVC;
@synthesize contentDetailVC;
@synthesize serverContentListVC;
@synthesize serverContentDetailVC;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		contentPlayerViewController = nil;
		
		
		[self showContentPlayerView];
    }
    return self;
}
*/

- (void)viewDidLoad
{
#if defined(IS_MULTI_CONTENTS) && IS_MULTI_CONTENTS != 0
	//Mulit Contents.
	[self showContentListView];
#else
	//Single Content.
	[self showContentPlayerView];
#endif
}

- (void)showContentPlayerView
{
	if (contentPlayerViewController == nil) {
		contentPlayerViewController = [[ContentPlayerViewController alloc] initWithNibName:@"ContentPlayerView" bundle:[NSBundle mainBundle]];
	}
	[self.view addSubview:contentPlayerViewController.view];
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

#pragma mark - InAppPurchase
@implementation SakuttoBookViewController (InAppPurchase)
#pragma mark - show/hide view.
- (void)showContentListView
{
#if defined(IS_CONTENTLIST_WITH_IMAGE) && IS_CONTENTLIST_WITH_IMAGE != 0
	//content list with image.
	if (contentListTVC == nil) {
		contentListTVC = [[ContentListThumbnailViewController alloc] initWithNibName:@"ContentListThumbnailViewController" bundle:[NSBundle mainBundle]];
	}
	[self.view addSubview:contentListTVC.view];
	
	contentListVC = nil;
#else
	//content list with table.
	if (contentListVC == nil) {
		contentListVC = [[ContentListTableViewController alloc] init];
	}
	[self.view addSubview:contentListVC.view];
	[contentListVC reloadData];
#endif
}
- (void)hideContentListView
{
	if (contentListVC != nil) {
		[contentListVC.view removeFromSuperview]; 
	}
}
#pragma mark -
- (void)showContentPlayerView:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	if (contentPlayerViewController == nil) {
		contentPlayerViewController = [[ContentPlayerViewController alloc] initWithNibName:@"ContentPlayerView" bundle:[NSBundle mainBundle] contentId:cid];
	}
	[self.view addSubview:contentPlayerViewController.view];
}
- (void)hideContentPlayerView
{
	if (contentPlayerViewController != nil) {
		[contentPlayerViewController.view removeFromSuperview];
		[contentPlayerViewController release];
		contentPlayerViewController = nil;
	}
}
#pragma mark -
- (void)showContentDetailView:(ContentId)cid
{
	if (contentDetailVC == nil) {
		contentDetailVC = [[ContentDetailViewController alloc] initWithNibName:@"ContentDetailView" bundle:[NSBundle mainBundle]];
	}
	[self.view addSubview:contentDetailVC.view];
	[contentDetailVC setLabelsWithContentId:cid];
}
- (void)hideContentDetailView
{
	if (contentDetailVC != nil) {
		[contentDetailVC.view removeFromSuperview];
	}
}
@end

#pragma mark - ServerContent
@implementation SakuttoBookViewController (ServerContent)
#pragma mark show/hide view.
- (void)showServerContentListView{
	//LOG_CURRENT_METHOD;
	if (serverContentListVC == nil) {
		serverContentListVC = [[ServerContentListVC alloc] init];
		serverContentListVC.view.frame = self.view.frame;
	}
	[self.view addSubview:serverContentListVC.view];
	[serverContentListVC reloadData];
}
- (void)hideServerContentListView{
	//LOG_CURRENT_METHOD;
	if (serverContentListVC != nil) {
		[serverContentListVC.view removeFromSuperview]; 
	}
}
- (void)showServerContentDetailView:(NSString*)uuid{
	//LOG_CURRENT_METHOD;
	if (serverContentDetailVC == nil) {
		serverContentDetailVC = [[ServerContentDetailVC alloc] initWithNibName:@"ServerContentDetailView" bundle:[NSBundle mainBundle]];
	}
	[self.view addSubview:serverContentDetailVC.view];
	[serverContentDetailVC setLabelsWithUuid:uuid];
}

- (void)hideServerContentDetailView{LOG_CURRENT_METHOD;}
- (void)showDownloadView:(NSString*)productId{LOG_CURRENT_METHOD;}
@end
