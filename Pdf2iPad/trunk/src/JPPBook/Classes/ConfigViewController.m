//
//  ConfigView.m
//  JPPBook
//
//  Created by okano on 11/10/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConfigViewController.h"


@implementation ConfigViewController

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
- (IBAction)handleDoneButton:(id)sender
{
	[self saveUrlToUserDefault:textField.text];
	[self closeThisView:sender];
}
- (IBAction)closeThisView:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
- (IBAction)setDefaultUrl1:(id)sender
{
	textField.text = URL_BASE_OPDS_DEFAULT1;
}
- (IBAction)setDefaultUrl2:(id)sender
{
	textField.text = URL_BASE_OPDS_DEFAULT2;
}

#pragma mark -
- (void)saveUrlToUserDefault:(NSString*)urlStr
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"field=%@", textField.text);
	NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
	[userDefault setValue:urlStr forKey:URL_OPDS];
}
												 
+ (NSString*)getUrlBaseWithOpds
{
	//load from UserDefault.
    NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	id obj = [settings valueForKey:URL_OPDS];
	if (!obj) {		//not exists.
        NSLog(@"no URL for opds in UserDefault.");
		return URL_BASE_OPDS_DEFAULT1;
	}
	return (NSString*)obj;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	textField.text = [ConfigViewController getUrlBaseWithOpds];
}

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
