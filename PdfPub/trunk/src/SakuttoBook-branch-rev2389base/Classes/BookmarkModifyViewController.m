//
//  BookmarkModifyViewController.m
//  SakuttoBook
//
//  Created by okano on 11/01/05.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "BookmarkModifyViewController.h"


@implementation BookmarkModifyViewController

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	//Show keyboard.
	[bookmarkNameField becomeFirstResponder];
}

- (void)setPageNumberForPrint:(int)pageNum {
	pageNumberLabel.text = [NSString stringWithFormat:@"%d", pageNum];
}

//touched return key.
- (void)textFieldShouldReturn:(UITextField *)tf {
	[self addBookmark:tf];
}

- (IBAction)addBookmark:(id)sender {
	//LOG_CURRENT_METHOD;
	NSString* bookmarkName;
	if (0 < [bookmarkNameField.text length]) {
		bookmarkName = [NSString stringWithString:bookmarkNameField.text];
	} else {
		bookmarkName = [NSString stringWithFormat:@"Bookmark"];
	}
	
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate addBookmarkWithCurrentPageWithName:bookmarkName];
	
	//
	[self closeThisView:nil];
}

- (IBAction)closeThisView:(id)sender {
	//[self.view removeFromSuperview];
	[self dismissModalViewControllerAnimated:YES];
}


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
