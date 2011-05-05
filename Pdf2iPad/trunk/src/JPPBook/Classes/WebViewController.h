//
//  WebViewController.h
//  PdfPub
//
//  Created by okano on 10/12/13.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"

@interface WebViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView* webView;
	IBOutlet UIActivityIndicatorView* activityIndicator;
	IBOutlet UIBarButtonItem* backButton;
	IBOutlet UIBarButtonItem* forwardButton;
}
@property (nonatomic, retain) UIWebView* webView;
@property (nonatomic, retain) UIActivityIndicatorView* activityIndicator;
@property (nonatomic, retain) UIBarButtonItem* backButton;
@property (nonatomic, retain) UIBarButtonItem* forwardButton;

//- (void)loadRequest:(NSURLRequest *)request;
- (IBAction)closeThisView:(id)sender;
- (void)setButtonStatus;
@end
