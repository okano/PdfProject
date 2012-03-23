    //
//  MenuViewController.m
//  SakuttoBook
//
//  Created by okano on 10/12/13.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "MenuViewController.h"


@implementation MenuViewController

- (IBAction)showTocView:(id)sender
{
	//LOG_CURRENT_METHOD;
	
	[self closeThisView:nil];
	
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	SakuttoBookViewController* vc = (SakuttoBookViewController*)appDelegate.viewController;
	[vc showTocView];	
/*
	TocViewController* tocVC = [[TocViewController alloc] initWithNibName:@"TocView" bundle:[NSBundle mainBundle]];
	[vc.currentImageView addSubview:[tocVC view]];
*/
}
- (void)hideTocView {
	[self.view removeFromSuperview];
}

#pragma mark -
#pragma mark ImageTocView.

#pragma mark -
- (IBAction)closeThisView:(id)sender
{
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	SakuttoBookViewController* vc = (SakuttoBookViewController*)appDelegate.viewController;
	[(SakuttoBookViewController*)vc hideMenuBar];
	//[self.view removeFromSuperview];
}


- (IBAction)showInfoView:(id)sender {
	//LOG_CURRENT_METHOD;
	
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showInfoView];
}

/*
- (IBAction)addBookmarkWithCurrentPage:(id)sender {
	LOG_CURRENT_METHOD;
	
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate addBookmarkWithCurrentPage];
}
*/

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
