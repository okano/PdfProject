//
//  WebViewController.m
//  SakuttoBook
//
//  Created by okano on 10/12/13.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController
@synthesize webView;
@synthesize activityIndicator;
@synthesize backButton, forwardButton;

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
	//LOG_CURRENT_METHOD;
	return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{	//LOG_CURRENT_METHOD;
	[activityIndicator stopAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	//LOG_CURRENT_METHOD;
	[activityIndicator stopAnimating];
	[self setButtonStatus];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	//LOG_CURRENT_METHOD;
	[activityIndicator stopAnimating];
    if (error != NULL) {
		NSLog(@"error description=%@", [error localizedDescription]);
		NSLog(@"error reason=%@", [error localizedFailureReason]);
		NSLog(@"error code=%d", [error code]);
		
		//Do nothing when "Cancel".
		NSInteger err_code = [error code];
		if (err_code == NSURLErrorCancelled) {
			return;
		}
		
		if(([[error domain]isEqual:NSURLErrorDomain])
		   && ([error code]!=NSURLErrorCancelled)) {
			UIAlertView* alertView = [[UIAlertView alloc]
									  initWithTitle:@"Load Error"
									  message:@"サーバが見つからないか、ネットワークのエラーです。"	//[error localizedDescription]
									  delegate:self
									  cancelButtonTitle:nil
									  otherButtonTitles:@"OK", nil];
			[alertView show];
		}
    }
	/*
	UILabel* errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 300, 200)];
	errorLabel.numberOfLines = 0;	//many lines.
	errorLabel.text = [NSString stringWithFormat:@"Error: %@", [error localizedDescription]];
	//errorLabel.backgroundColor = [UIColor orangeColor];
	[self.webView addSubview:errorLabel];
	*/
	
	[self setButtonStatus];
}

#pragma mark -
#pragma mark close this view.
- (IBAction)closeThisView:(id)sender
{
	//remove label on WebView.
	for (UIView* view in self.view.subviews) {
		if ([view isKindOfClass:[UIWebView class]] == TRUE) {
			for (UIView* labelCandidateView in view.subviews) {
				if ([labelCandidateView isKindOfClass:[UILabel class]] == TRUE) {
					[labelCandidateView removeFromSuperview];
				}
			}
		}
	}
	
	//close
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

#pragma mark -
- (void)setButtonStatus {
	if (webView.canGoBack) {
		backButton.enabled = YES;
	} else {
		backButton.enabled = NO;
	}
	if (webView.canGoForward) {
		forwardButton.enabled = YES;
	} else {
		forwardButton.enabled = NO;
	}
}

#pragma mark -
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
