//
//  TocView2.m
//  SakuttoBook
//
//  Created by okano on 10/12/14.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "TocViewController.h"


@implementation TocViewController
@synthesize topToolBar;

#pragma mark close this view.
- (IBAction)closeThisView:(id)sender
{
	[self.view removeFromSuperview];
}

- (void)reloadDataForce {
	[self arrangeTopToolBar];
	[myTableView reloadData];
}
- (void)arrangeTopToolBar {
	//LOG_CURRENT_METHOD;
	
	//TOC mode.
	if ([[topToolBar items] count] <= 2) {
		return;
	} else {
		//Set toolbar for TOC.
		[self setToolbarForToc];
	}
}
- (void)setToolbarForToc {
	//Set toolbar for TOC.
	//[0]Cancel, [1]ScalableSpacer.
	NSMutableArray* items = [[NSMutableArray alloc] initWithArray:[topToolBar items]];
	NSRange r = NSMakeRange(2, [items count] - 2);
	[items removeObjectsInRange:r];
	[topToolBar setItems:items];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	return [appDelegate.tocDefine count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    //setup cell.
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSMutableDictionary* tmpDict;
	NSString* tocTitle;
		tmpDict = [appDelegate.tocDefine objectAtIndex:indexPath.row];
		tocTitle = [tmpDict objectForKey:TOC_TITLE];
		//[cell setEditing:NO];
	//NSUInteger tocPage = [[tmpDict objectForKey:TOC_PAGE] intValue];
	NSUInteger tocLevel = [[tmpDict objectForKey:TOC_LEVEL] intValue];
	
    // Configure the cell...
	if (tocLevel == 3) {
		cell.textLabel.text = [NSString stringWithFormat:@"　　%@", tocTitle];
	} else 	if (tocLevel == 2) {
		cell.textLabel.text = [NSString stringWithFormat:@"　%@", tocTitle];
	} else {
		cell.textLabel.text = tocTitle;
	}
	
	return cell;
}

#pragma mark treat editing.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;	//TOC mode.
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	LOG_CURRENT_METHOD;
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
	LOG_CURRENT_METHOD;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
	
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSMutableDictionary* tmpDict;
	NSUInteger tocPage;
	tmpDict = [appDelegate.tocDefine objectAtIndex:indexPath.row];
	tocPage = [[tmpDict objectForKey:TOC_PAGE] intValue];
	//NSLog(@"selected page=%d", tocPage);
	
	[appDelegate.viewController switchToPage:tocPage];
}

#pragma mark treat editing.
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
		return UITableViewCellEditingStyleNone;		//TOC mode.
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
