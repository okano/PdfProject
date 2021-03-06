    //
//  BookmarkViewController.m
//  SakuttoBook
//
//  Created by okano on 11/01/06.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "BookmarkViewController.h"


@implementation BookmarkViewController
@synthesize topToolBar;
@synthesize flexibleSpaceButton, editButton, doneButton, cancelButton;

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Setup Button for toolbar.
	flexibleSpaceButton = [[UIBarButtonItem alloc]
						   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
						   target:nil
						   action:nil];
	editButton = [[UIBarButtonItem alloc]
				  initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
				  target:self
				  action:@selector(switchToEditModeOn:)];
	doneButton = [[UIBarButtonItem alloc]
				  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
				  target:self
				  action:@selector(switchToEditModeOff:)];
	cancelButton = [[UIBarButtonItem alloc]
					initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
					target:self
					action:@selector(closeThisView:)];
}


#pragma mark close this view.
- (IBAction)closeThisView:(id)sender
{
	[self.view removeFromSuperview];
}

- (void)reloadDataForce {
	[myTableView reloadData];
}
- (void)setToolbarForBookmark {
	//Set toolbar for Bookmark.
	//[0]Cancel, [1]ScalableSpacer, [2]Edit.
	NSArray* items = [NSArray arrayWithObjects:cancelButton, flexibleSpaceButton, editButton, nil];
	[topToolBar setItems:items];
}
- (void)setToolbarForBookmarkWithEditMode {
	//Set toolbar for Bookmark with Edit Mode.
	//[0]ScalableSpacer, [2]Done.

	NSArray* items = [NSArray arrayWithObjects:flexibleSpaceButton, doneButton, nil];
	[topToolBar setItems:items];
}

- (IBAction)switchToEditModeOn:(id)sender {
	[myTableView setEditing:YES animated:YES];
	[self setToolbarForBookmarkWithEditMode];
}
- (IBAction)switchToEditModeOff:(id)sender {
	[myTableView setEditing:NO animated:YES];
	[self setToolbarForBookmark];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	return [appDelegate.bookmarkDefine count];
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
	tmpDict = [appDelegate.bookmarkDefine objectAtIndex:indexPath.row];
	tocTitle = [NSString stringWithFormat:@"%@ (page %d)",
				[tmpDict objectForKey:BOOKMARK_PAGE_MEMO],
				[[tmpDict objectForKey:BOOKMARK_PAGE_NUMBER] intValue]];
	//[cell setEditing:YES];
	//NSUInteger tocPage = [[tmpDict objectForKey:TOC_PAGE] intValue];
	//NSUInteger tocLevel = [[tmpDict objectForKey:TOC_LEVEL] intValue];
	
    // Configure the cell...
	cell.textLabel.text = tocTitle;
	return cell;
}

#pragma mark treat editing.
/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
		return YES;	//Bookmark mode.
}
*/

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	LOG_CURRENT_METHOD;
	if (editingStyle == UITableViewCellEditingStyleInsert) {
		return;
	}
	//Delete bookmark item from local array.
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSMutableArray* bookmarkInAppDelegate = appDelegate.bookmarkDefine;
	if (indexPath.row < [bookmarkInAppDelegate count]) {
		[bookmarkInAppDelegate removeObjectAtIndex:indexPath.row];
	}
	
	//Delete bookmark item from UserDefault.
	[appDelegate saveBookmark];
	/*
	NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	id obj = [settings valueForKey:BOOKMARK_ARRAY];
	if (!obj) {		//no bookmark exists.
		return;
	}
	if (![obj isKindOfClass:[NSArray class]]) {
		NSLog(@"illigal bookmark infomation. class=%@", [obj class]);
		return;
	}
	NSMutableArray* bookmarkInUserDefault = [[NSMutableArray alloc] initWithArray:(NSArray*)obj];
	if (indexPath.row < [bookmarkInUserDefault count]) {
		[bookmarkInUserDefault removeObjectAtIndex:indexPath.row];
		NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
		[userDefault setObject:bookmarkInUserDefault forKey:BOOKMARK_ARRAY];
		[userDefault synchronize];
	}
	[bookmarkInUserDefault release];
	*/
	
	//Reload TableView.
	NSArray* rowsForDelete = [NSArray arrayWithObject:indexPath];
	[myTableView deleteRowsAtIndexPaths:rowsForDelete withRowAnimation:UITableViewRowAnimationFade];// <#(UITableViewRowAnimation)animation#>
	//[myTableView reloadData];
}

/*
- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
	LOG_CURRENT_METHOD;
}
*/

#pragma mark treat Moving.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	LOG_CURRENT_METHOD;
	NSLog(@"from = %d, to = %d", fromIndexPath.row, toIndexPath.row);
	if (fromIndexPath.row == toIndexPath.row) {
		return;
	}
	
	//Move bookmark item from local array.
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSMutableArray* bookmarkInAppDelegate = appDelegate.bookmarkDefine;
	if (fromIndexPath.row < [bookmarkInAppDelegate count]
		&&
		toIndexPath.row < [bookmarkInAppDelegate count]) {
		//move bookmark in array(Not EXCHANGE!. do insert and delete).
		//[bookmarkInAppDelegate exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];	//exchange -> NG!
		
		id obj = [bookmarkInAppDelegate objectAtIndex:fromIndexPath.row];
		if (fromIndexPath.row <= toIndexPath.row) {
			[bookmarkInAppDelegate insertObject:obj atIndex:toIndexPath.row + 1];
			[bookmarkInAppDelegate removeObjectAtIndex:fromIndexPath.row];
		} else {
			[bookmarkInAppDelegate insertObject:obj atIndex:toIndexPath.row];
			[bookmarkInAppDelegate removeObjectAtIndex:fromIndexPath.row + 1];
		}
	}
	
	/*
	//Move bookmark item from UserDefault.
	NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	id obj = [settings valueForKey:BOOKMARK_ARRAY];
	if (!obj) {		//no bookmark exists.
		return;
	}
	if (![obj isKindOfClass:[NSArray class]]) {
		NSLog(@"illigal bookmark infomation. class=%@", [obj class]);
		return;
	}
	NSMutableArray* bookmarkInUserDefault = [[NSMutableArray alloc] initWithArray:(NSArray*)obj];
	if (fromIndexPath.row < [bookmarkInUserDefault count]
		&&
		toIndexPath.row < [bookmarkInUserDefault count]) {
		//move bookmark in array(Not EXCHANGE!. do insert and delete).
		//[bookmarkInUserDefault exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
		id obj;
		obj = [bookmarkInUserDefault objectAtIndex:fromIndexPath.row];
		if (fromIndexPath.row <= toIndexPath.row) {
			[bookmarkInUserDefault insertObject:obj atIndex:toIndexPath.row + 1];
			[bookmarkInUserDefault removeObjectAtIndex:fromIndexPath.row];
		} else {
			[bookmarkInUserDefault insertObject:obj atIndex:toIndexPath.row];
			[bookmarkInUserDefault removeObjectAtIndex:fromIndexPath.row + 1];
		}
		
		NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
		[userDefault setObject:bookmarkInUserDefault forKey:BOOKMARK_ARRAY];
		[userDefault synchronize];
	}
	[bookmarkInUserDefault release];
	*/
	
	[appDelegate saveBookmark];
	
	//Reload TableView.
	//NSArray* targetRows = [NSArray arrayWithObjects:fromIndexPath, toIndexPath, nil];
	//[myTableView reloadRowsAtIndexPaths:targetRows withRowAnimation:UITableViewRowAnimationFade];
	//[myTableView reloadData];
	[self reloadDataForce];
	[self switchToEditModeOn:nil];
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
	
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSMutableDictionary* tmpDict;
	NSUInteger tocPage;
	tmpDict = [appDelegate.bookmarkDefine objectAtIndex:indexPath.row];
	tocPage = [[tmpDict objectForKey:BOOKMARK_PAGE_NUMBER] intValue];
	//NSLog(@"selected page=%d", tocPage);
	
	[appDelegate switchToPage:tocPage];
}

#pragma mark treat editing.
/*
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;	//Bookmark mode.
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

#pragma mark -
#pragma mark Memory management
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
	//Release Button for toolbar.
	[cancelButton release];
	[doneButton release];
	[editButton release];
	[flexibleSpaceButton release];
}


- (void)dealloc {
    [super dealloc];
}


@end
