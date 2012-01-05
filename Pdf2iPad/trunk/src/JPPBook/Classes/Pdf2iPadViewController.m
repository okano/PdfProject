//
//  Pdf2iPadViewController.m
//  JPPBook
//
//  Created by okano on 11/07/05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Pdf2iPadViewController.h"


@implementation Pdf2iPadViewController

@synthesize contentPlayerViewController;
@synthesize contentListVC;
@synthesize contentDetailVC;
@synthesize serverContentListVC;
@synthesize serverContentDetailVC;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.autoresizesSubviews = YES;
    // Do any additional setup after loading the view from its nib.
	[self showContentListView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	//LOG_CURRENT_METHOD;
	if (contentPlayerViewController != nil) {
		//LOG_CURRENT_LINE;
		[contentPlayerViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	}
	if (contentListVC != nil) {
		//LOG_CURRENT_LINE;
		[contentListVC willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	}
	if (serverContentListVC != nil) {
		//LOG_CURRENT_LINE;
		[serverContentListVC willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	}
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	//LOG_CURRENT_METHOD;
	if (contentPlayerViewController != nil) {
		[contentPlayerViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	}
	if (contentListVC != nil) {
		[contentListVC didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	}
	if (serverContentListVC != nil) {
		[serverContentListVC didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	}
}
- (void)showContentPlayerView
{
	if (contentPlayerViewController == nil) {
		contentPlayerViewController = [[ContentPlayerViewController alloc] initWithNibName:@"ContentPlayerView" bundle:[NSBundle mainBundle]];
	}
	[self.view addSubview:contentPlayerViewController.view];
}

@end

#pragma mark - InAppPurchase
@implementation Pdf2iPadViewController (InAppPurchase)
#pragma mark show/hide view.
- (void)showContentListView
{
	if (contentListVC == nil) {
		contentListVC = [[ContentListViewController alloc] init];
		contentListVC.view.frame = self.view.frame;
	}
	[self.view addSubview:contentListVC.view];
	[contentListVC reloadData];
}
- (void)hideContentListView
{
	if (contentListVC != nil) {
		[contentListVC.view removeFromSuperview];
	}
}
- (void)showContentPlayerView:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	if (contentPlayerViewController == nil) {
		contentPlayerViewController = [[ContentPlayerViewController alloc] initWithNibName:@"ContentPlayerView" bundle:[NSBundle mainBundle] contentId:cid];
	}
	
	//Treat startup with LandScape.
	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (interfaceOrientation == UIInterfaceOrientationLandscapeRight
		||
		interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
		CGRect rect = CGRectMake(self.view.frame.origin.x,
								 self.view.frame.origin.y,
								 self.view.frame.size.height,
								 self.view.frame.size.width);
		contentPlayerViewController.view.frame = rect;
		
		[contentPlayerViewController setupZoomScaleWithFrameSize:rect.size];
	}
	
	//
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
@implementation Pdf2iPadViewController (ServerContent)
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
