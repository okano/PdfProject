//
//  InfomationViewController.m
//  SakuttoBook
//
//  Created by okano on 10/12/25.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "InfomationViewController.h"


@implementation InfomationViewController
@synthesize bookTitleLabel, bookAuthorLabel, bookCopyrightLabel;
@synthesize licenceNumberLabel;
@synthesize bookSupportPageUrl;
@synthesize bookSupportPageButton;

- (void)viewDidLoad {
	[super viewDidLoad];
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSLog(@"license key = %@", [appDelegate.license getLicenseKeyByString]);
	if ([appDelegate.license isValidLicense]) {
		licenceNumberLabel.text = [appDelegate.license getLicenseKeyByString];
		NSLog(@"(this is valid license)");
	} else {
		if ([appDelegate.license isSampleLicense]) {
			licenceNumberLabel.text = @"(this is sample license)";
			NSLog(@"(this is sample license:%@", [appDelegate.license getLicenseKeyByString]);
		} else {
			licenceNumberLabel.text = @"(this is invalid license)";
			NSLog(@"invalid license key. key = %@", [appDelegate.license getLicenseKeyByString]);
		}
	}
	
	[self setBookInfoFromDefineFile];
}

- (void)setBookInfoFromDefineFile {
	//Open define file.
	NSString* csvFilePath = [[NSBundle mainBundle] pathForResource:@"bookDefine" ofType:@"csv"];
	NSError* error = nil;
	NSString* text = [NSString stringWithContentsOfFile:csvFilePath encoding:NSUTF8StringEncoding error:&error];
	if (error) {
		NSLog(@"book define file not found. filename=%@", [csvFilePath lastPathComponent]);
		NSLog(@"error=%@, error code=%d", [error localizedDescription], [error code]);
		return;
	}
	
	//Read book define.
	NSArray* lines = [text componentsSeparatedByString:@"\n"];
	//NSArray* lines = [[text stringByAppendingString:@"\n"] componentsSeparatedByString:@"\n"];
	if ([lines count] <= 0) {
		return;
	}
	
	bookTitleLabel.text		= [[NSString alloc] initWithString:[lines objectAtIndex:0]];
	if (2 <= [lines count]) {
		bookAuthorLabel.text	= [[NSString alloc] initWithString:[lines objectAtIndex:1]];
	}
	if (3 <= [lines count]) {
		bookCopyrightLabel.text = [[NSString alloc] initWithString:[lines objectAtIndex:2]];
	}
	if (4 <= [lines count] && 0 < [[lines objectAtIndex:3] length]) {
		//Check valid web Url.(start with "http://" or "https://")
		NSRange range1 = NSMakeRange(0, 7);	// "http://"
		NSRange range2 = NSMakeRange(0, 8);	// "https://"
		
		NSString* tmpStr = [lines objectAtIndex:3];
		if ([tmpStr compare:@"http://" options:NSCaseInsensitiveSearch range:range1] == NSOrderedSame
			||
			[tmpStr compare:@"https://" options:NSCaseInsensitiveSearch range:range2] == NSOrderedSame) {
			bookSupportPageUrl = [[[NSString alloc] initWithString:[lines objectAtIndex:3]]
								  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			//NSLog(@"retain count=%d", [bookSupportPageUrl retainCount]);
		} else {

			bookSupportPageUrl = [[[NSString alloc] initWithFormat:@"%@%@", DEFAULT_BOOK_SUPPORT_URL_PREFIX, [lines objectAtIndex:3]]
								  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			[bookSupportPageUrl retain];
			//NSLog(@"retain count=%d", [bookSupportPageUrl retainCount]);
		}
	} else {
		//bookSupportPageUrl = DEFAULT_BOOK_SUPPORT_URL;
		bookSupportPageButton.hidden = YES;
	}
}

#pragma mark -
- (IBAction)closeThisView:(id)sender
{
	[self.view removeFromSuperview];
}

- (void)showWebView:(NSString*)urlString {
	[self closeThisView:nil];
	
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showWebView:urlString];
}
- (IBAction)openBookSupportPage:(id)sender {
	//LOG_CURRENT_METHOD;
	//NSLog(@"openBookSupportPage. url=%@", bookSupportPageUrl);
	[self showWebView:bookSupportPageUrl];
}
- (IBAction)openProgramSupportPage:(id)sender {
	[self showWebView:PROGRAM_SUPPORT_URL];
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
