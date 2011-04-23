//
//  MenuViewController.m
//  PdfPub
//
//  Created by okano on 10/12/13.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "MenuViewController.h"


@implementation MenuViewController
#pragma mark -
#pragma mark TocView.
- (IBAction)showTocView:(id)sender
{
	//LOG_CURRENT_METHOD;
	
	//[self closeThisView:nil];
	
	//Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	//PdfPubViewController* vc = (PdfPubViewController*)appDelegate.viewController;
	//[vc showTocView];	
/*
	TocViewController* tocVC = [[TocViewController alloc] initWithNibName:@"TocView" bundle:[NSBundle mainBundle]];
	[vc.currentImageView addSubview:[tocVC view]];
*/
	
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	if ([appDelegate isShownTocView] == YES) {
		LOG_CURRENT_LINE;
		return;
	}
	
	//Show Toc View with Popup.
	TocTableViewController* tocTableViewController = [[TocTableViewController alloc] init];
	
	aPopover = [[UIPopoverController alloc] initWithContentViewController:tocTableViewController];
	aPopover.delegate = self;
	//Setup size.
	CGSize popoverSize = CGSizeMake(TOC_VIEW_WIDTH,
									aPopover.popoverContentSize.height);
	[aPopover setPopoverContentSize:popoverSize];
	
	//show
	[aPopover presentPopoverFromBarButtonItem:sender
					 permittedArrowDirections:UIPopoverArrowDirectionAny
									 animated:YES];
	[appDelegate setIsShownTocView:YES];
}
- (void)hideTocView {
	if (aPopover) {
		[aPopover dismissPopoverAnimated:YES];
	}
	
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate setIsShownTocView:NO];
}


#pragma mark -
#pragma mark UIPopoverControllerDelegate method.
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate setIsShownTocView:NO];
	;
}

#pragma mark -
#pragma mark InfoView.
- (IBAction)showInfoView:(id)sender
{
	//LOG_CURRENT_METHOD;
	
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showInfoView];
}

#pragma mark -
#pragma mark BookmarkView.
- (IBAction)showBookmarkView:(id)sender
{
	//LOG_CURRENT_METHOD;
	
	[self closeThisView:nil];
	
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	Pdf2iPadViewController* vc = (Pdf2iPadViewController*)appDelegate.viewController;
	[vc showBookmarkView];	
}
- (void)hideBookmarkView {
	[self.view removeFromSuperview];
}

- (IBAction)showBookmarkModifyView:(id)sender {
	//LOG_CURRENT_METHOD;
	//BookmarkModifyViewController* bmvc = [[BookmarkModifyViewController alloc] initWithNibName:@"BookmarkModifyView" bundle:[NSBundle mainBundle]];
	//[currentPdf presentModalViewController:bmvc animated:YES];
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showBookmarkModifyView];
	//SakuttoBookViewController* vc = (SakuttoBookViewController*)appDelegate.viewController;
	//[(SakuttoBookViewController*)vc showBookmarkModifyView];
}
/*
- (IBAction)addBookmarkWithCurrentPage:(id)sender {
	LOG_CURRENT_METHOD;
	
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate addBookmarkWithCurrentPage];
}
*/

#pragma mark -
#pragma mark ImageTocView.
- (IBAction)showImageTocView:(id)sender
{
	//LOG_CURRENT_METHOD;
	
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showThumbnailScrollView];
	
	/*
	ImageTocViewController* imageTocVC = [[ImageTocViewController alloc] init];
	//[self.view.superview addSubview:imageTocVC.view];
	[self presentModalViewController:imageTocVC animated:YES];
	*/
}

- (IBAction)gotoTopPage:(id)sender {
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate gotoTopPage];
}
- (IBAction)gotoCoverPage:(id)sender {
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate gotoCoverPage];
}
- (IBAction)showHelpView:(id)sender {
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showHelpView];
}

//MARK: -
//MARK: Marker mode.
- (IBAction)enterMarkerMode:(id)sender
{
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate enterMarkerMode];
}


#pragma mark -
- (IBAction)closeThisView:(id)sender
{
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	PdfPubViewController* vc = (PdfPubViewController*)appDelegate.viewController;
	[(PdfPubViewController*)vc hideMenuBar];
	//[self.view removeFromSuperview];
}


#pragma mark -
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
