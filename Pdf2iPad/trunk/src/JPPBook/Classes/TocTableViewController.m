//
//  TocTableViewController.m
//  Pdf2iPad
//
//  Created by okano on 10/12/18.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "TocTableViewController.h"


@implementation TocTableViewController
@synthesize tocDefine;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	tocDefine = appDelegate.tocDefine;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
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
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (tocDefine) {
		return [tocDefine count];
	} else {
		LOG_CURRENT_METHOD;
		LOG_CURRENT_LINE;
		NSLog(@"not found tocDefine");
		return 0;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Setup font for cell.
	UIFont* cellFont = [UIFont fontWithName:TOC_FONTNAME size:TOC_FONTSIZE];
	cell.textLabel.font = cellFont;
	
    // Configure the cell...
	if ([tocDefine count] < indexPath.row) {
		cell.textLabel.text = [NSString stringWithFormat:@"row=%d", indexPath.row];

	} else {
		NSString* str = [[tocDefine objectAtIndex:indexPath.row] objectForKey:TOC_TITLE];
		int tocLevel = [[[tocDefine objectAtIndex:indexPath.row] objectForKey:TOC_LEVEL] intValue];
		if (tocLevel == 3) {
			str = [NSString stringWithFormat:@"　　%@", str];
		} else if (tocLevel == 2) {
			str = [NSString stringWithFormat:@"　%@", str];
		}
		
		//cell.textLabel.text = str;//[NSString stringWithFormat:@"row=%d", indexPath.row];
		
		CGSize textSize = [str sizeWithFont:cellFont constrainedToSize:CGSizeMake(1000, 1000) lineBreakMode:UILineBreakModeTailTruncation];
		//NSLog(@"(cellForRowAtIndexPath) textSize=%@", NSStringFromCGSize(textSize));
		
		UILabel *textField = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 2.0f, TOC_VIEW_WIDTH, textSize.height)];
		[textField setText:str];
		//[textField setBackgroundColor:[UIColor clearColor]];
		[textField setLineBreakMode:UILineBreakModeTailTruncation];
		[textField setFont:cellFont];
		[textField setHighlightedTextColor:[UIColor whiteColor]];
		[textField setNumberOfLines:1];
		[cell addSubview:textField];
		[textField release];
	}
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate hideTocView];
	int newPageNumber = [[[tocDefine objectAtIndex:indexPath.row] objectForKey:TOC_PAGE] intValue];
	[appDelegate switchToPage:newPageNumber];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UIFont* cellFont = [UIFont fontWithName:TOC_FONTNAME size:TOC_FONTSIZE];
	NSString* str = [[tocDefine objectAtIndex:indexPath.row] objectForKey:TOC_TITLE];
	CGSize size = CGSizeMake(1000.0f, 1000.0f);
	CGSize textSize = [str sizeWithFont:cellFont constrainedToSize:size lineBreakMode:UILineBreakModeCharacterWrap];  
	//NSLog(@"textSize=%@", NSStringFromCGSize(textSize));
	return textSize.height;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

