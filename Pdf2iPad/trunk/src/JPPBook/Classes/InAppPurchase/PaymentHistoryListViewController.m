//
//  PaymentHistoryListViewController.m
//  SakuttoBook
//
//  Created by okano on 11/06/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaymentHistoryListViewController.h"


@implementation PaymentHistoryListViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	//Setup TableView.
	myTableView = [[UITableView alloc] initWithFrame:self.view.frame];
	myTableView.delegate = self;
	myTableView.dataSource = self;
	[self.view addSubview:myTableView];
	
	//Setup Toolbar.
	CGFloat toolBarHeight = 44.0f;
	CGRect toolBarFrame = CGRectMake(0.0f,
									 0.0f,
									 self.view.frame.size.width,
									 toolBarHeight);
	UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:toolBarFrame];
	UIBarButtonItem *paymentHistoryButton = [[UIBarButtonItem alloc] initWithTitle:@"close"
																			 style:UIBarButtonItemStyleBordered
																			target:self
																			action:@selector(closeThisView)];
	NSArray *items = [NSArray arrayWithObjects:paymentHistoryButton, nil];
	[toolbar setItems:items];
	[self.view addSubview:toolbar];
	
	//Setup TableView size.
	CGRect tableViewframe = myTableView.frame;
	CGRect newTableViewframe = CGRectMake(tableViewframe.origin.x,
										  tableViewframe.origin.y + toolBarHeight,
										  tableViewframe.size.width, tableViewframe.size.height - toolBarHeight);
	//LOG_CURRENT_METHOD;
	//NSLog(@"tableViewframe=%@", NSStringFromCGRect(tableViewframe));
	//NSLog(@"newTableViewframe=%@", NSStringFromCGRect(newTableViewframe));
	
	myTableView.frame = newTableViewframe;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.	
	return ([appDelegate.paymentHistoryDS count] + 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	cell.userInteractionEnabled = NO;
	if (indexPath.row < [appDelegate.paymentHistoryDS count]) {
		cell.textLabel.numberOfLines = 0;
		cell.textLabel.text = [appDelegate.paymentHistoryDS descriptionAtIndex:indexPath.row];
	} else {
		cell.textLabel.text = [NSString stringWithFormat:@"Total %d record(s).", [appDelegate.paymentHistoryDS count]];
	}
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 97.0;
}

#pragma mark -
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

#pragma mark -
- (void)closeThisView
{
	[self.view removeFromSuperview];
}
#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
