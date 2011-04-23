//
//  WebViewController.h
//  PdfPub
//
//  Created by okano on 10/12/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"

@interface WebViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView* webView;
	IBOutlet UIActivityIndicatorView* activityIndicator;
}
@property (nonatomic, retain) UIWebView* webView;
@property (nonatomic, retain) UIActivityIndicatorView* activityIndicator;

//- (void)loadRequest:(NSURLRequest *)request;
- (IBAction)closeThisView:(id)sender;
@end
