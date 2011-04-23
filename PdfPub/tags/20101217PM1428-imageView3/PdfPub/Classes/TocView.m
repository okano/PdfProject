    //
//  TocView2.m
//  PdfPub
//
//  Created by okano on 10/12/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TocView.h"


@implementation TocView

#pragma mark close this view.
- (IBAction)closeThisView:(id)sender
{
	[self.view removeFromSuperview];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	PdfPubAppDelegate* appDelegate = (PdfPubAppDelegate*)[[UIApplication sharedApplication] delegate];
	return [appDelegate.tocDefine count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
	PdfPubAppDelegate* appDelegate = (PdfPubAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSMutableDictionary* tmpDict = [appDelegate.tocDefine objectAtIndex:indexPath.row];
	//NSUInteger tocPage = [[tmpDict objectForKey:TOC_PAGE] intValue];
	//NSUInteger tocLevel = [[tmpDict objectForKey:TOC_LEVEL] intValue];
	NSString* tocTitle = [tmpDict objectForKey:TOC_TITLE];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	cell.textLabel.text = tocTitle;
	return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
	
	PdfPubAppDelegate* appDelegate = (PdfPubAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSMutableDictionary* tmpDict = [appDelegate.tocDefine objectAtIndex:indexPath.row];
	NSUInteger tocPage = [[tmpDict objectForKey:TOC_PAGE] intValue];
	NSLog(@"selected page=%d", tocPage);
	
	[appDelegate.viewController switchToPage:tocPage];
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

#pragma mark -
#pragma mark Memory management
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
