    //
//  WebViewController.m
//  PdfPub
//
//  Created by okano on 10/12/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController
@synthesize webView;
@synthesize activityIndicator;

/*
- (void)loadRequest:(NSURLRequest *)request
{
	LOG_CURRENT_METHOD;
	[webView loadRequest:request];
	//[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.co.jp"]]];
}
*/

#pragma mark UIWebViewDelegate methods.
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	LOG_CURRENT_METHOD;
	return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{	LOG_CURRENT_METHOD;
	[activityIndicator stopAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	LOG_CURRENT_METHOD;
	[activityIndicator stopAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	LOG_CURRENT_METHOD;
	[activityIndicator stopAnimating];
}

#pragma mark close this view.
- (IBAction)closeThisView:(id)sender
{
	[self.view removeFromSuperview];
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
