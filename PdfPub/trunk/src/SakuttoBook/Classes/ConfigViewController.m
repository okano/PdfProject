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
	[self saveUsernameAndPasswordToUserDefault:usernameField.text withPassword:passwordField.text];
	[self closeThisView:sender];
}
- (IBAction)closeThisView:(id)sender
{
	//[self dismissModalViewControllerAnimated:YES];
	[self.view removeFromSuperview];
}

#pragma mark -
- (IBAction)setDefaultUrl1:(id)sender
{
	textField.text = URL_BASE_OPDS_DEFAULT1;
}

#pragma mark -
- (void)saveUrlToUserDefault:(NSString*)urlStr
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"field=%@", textField.text);
	NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
	[userDefault setValue:urlStr forKey:URL_OPDS];
	[userDefault synchronize];
}
												 
+ (NSString*)getUrlBaseWithOpds
{
	//load from UserDefault.
    NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	id obj = [settings valueForKey:URL_OPDS];
	if (!obj) {		//not exists.
        NSLog(@"(use default URL because of no URL for opds in UserDefault.)");
		return URL_BASE_OPDS_DEFAULT1;
	}
	return (NSString*)obj;
}

#pragma mark -
- (void)saveUsernameAndPasswordToUserDefault:(NSString*)username
								withPassword:(NSString*)password
{
	NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
	[userDefault setValue:username forKey:USERNAME];
	[userDefault setValue:password forKey:PASSWORD];
	[userDefault synchronize];
}

- (NSDictionary*)loadUsernameAndPasswordFromUserDefault
{
	NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	id obj;
	//Get username.
	obj = [settings valueForKey:USERNAME];
	if (!obj) {
		return nil;
	}
	if (![obj isKindOfClass:[NSString class]]) {
		NSLog(@"illigal username infomation. class=%@", [obj class]);
		return nil;
	}
	NSString* username = [NSString stringWithString:obj];
	
	//Get password.
	obj = [settings valueForKey:PASSWORD];
	if (!obj) {
		return nil;
	}
	if (![obj isKindOfClass:[NSString class]]) {
		NSLog(@"illigal password infomation. class=%@", [obj class]);
		return nil;
	}
	NSString* password = [NSString stringWithString:obj];
	NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  username, USERNAME,
						  password, PASSWORD,
						  nil];
	return dict;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	//Setup GUI.
	textField.text = [ConfigViewController getUrlBaseWithOpds];
	NSDictionary* userinfoDict = [self loadUsernameAndPasswordFromUserDefault];
	usernameField.text = [userinfoDict valueForKey:USERNAME];
	if (usernameField.text == nil)
	{
		usernameField.text = USERNAME_DEFAULT;
	}
	passwordField.text = [userinfoDict valueForKey:PASSWORD];
	if (passwordField.text == nil)
	{
		passwordField.text = PASSWORD_DEFAULT;
	}
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
