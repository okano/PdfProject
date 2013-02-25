    //
//  MenuViewController.m
//  SakuttoBook
//
//  Created by okano on 10/12/13.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "MenuViewController.h"


@implementation MenuViewController
@synthesize toolbar, contentListButton, infoButton;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//Hide ContentList Button.
#if defined(IS_MULTI_CONTENTS) && IS_MULTI_CONTENTS != 0
	//Mulit Contents. (Do-nothing.)
#else
	//Single Content(hide contentListButton on toolbar.)
	NSMutableArray* itemArray = [[NSMutableArray alloc] initWithArray:toolbar.items];
	for (id obj in [itemArray reverseObjectEnumerator]) {
		if (obj == contentListButton) {
			[itemArray removeObject:obj];
		};
	}
	[toolbar setItems:itemArray];
#endif
	
	//Hide Info Button.
#if defined(HIDE_INFOMATION_BUTTON) && HIDE_INFOMATION_BUTTON != 0
	infoButton.hidden = YES;
#endif
	
}


- (IBAction)showTocView:(id)sender
{
	//LOG_CURRENT_METHOD;
	
	[self closeThisView:nil];
	
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showTocView];
}
- (void)hideTocView {
	[self.view removeFromSuperview];
}

#pragma mark -
#pragma mark ImageTocView.
- (IBAction)showPageSmallView:(id)sender
{
	//LOG_CURRENT_METHOD;
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showPageSmallView];
}

#pragma mark -
- (IBAction)closeThisView:(id)sender
{
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate hideMenuBar];
	//[self.view removeFromSuperview];
}


- (IBAction)showInfoView:(id)sender {
	//LOG_CURRENT_METHOD;
	
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showInfoView];
}

- (IBAction)showBookmarkView:(id)sender
{
	//LOG_CURRENT_METHOD;
	
	[self closeThisView:nil];
	
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showBookmarkView];
}
- (void)hideBookmarkView {
	[self.view removeFromSuperview];
}

- (IBAction)showBookmarkModifyView:(id)sender {
	//LOG_CURRENT_METHOD;
	//BookmarkModifyViewController* bmvc = [[BookmarkModifyViewController alloc] initWithNibName:@"BookmarkModifyView" bundle:[NSBundle mainBundle]];
	//[currentPdf presentModalViewController:bmvc animated:YES];
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showBookmarkModifyView];
}

/*
- (IBAction)addBookmarkWithCurrentPage:(id)sender {
	LOG_CURRENT_METHOD;
	
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate addBookmarkWithCurrentPage];
}
*/

- (IBAction)switchToContentListView:(id)sender {
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate hideContentPlayerView];
	[appDelegate showContentListView];
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
