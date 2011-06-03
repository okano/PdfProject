//
//  ContentDetailView.m
//  SakuttoBook
//
//  Created by okano on 11/06/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContentDetailViewController.h"


@implementation ContentDetailViewController
@synthesize thumbnailImageView, titleLabel, authorLabel, descriptionTextView;
@synthesize priceLabel;
@synthesize buyButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
		targetCid = -1;
		targetProductId = nil;
    }
    return self;
}

#pragma mark - Implement.
- (void)setLabelsWithContentId:(ContentId)cid
{
	LOG_CURRENT_METHOD;
	NSLog(@"cid=%d", cid);
	
	//inner var.
	targetCid = cid;
	
	
	//Thumbnail.
	thumbnailImageView.image = [appDelegate.contentListDS thumbnailImageByContentId:cid];
	
	//Title, Author, Description.
	titleLabel.text = [appDelegate.contentListDS titleByContentId:cid];
	authorLabel.text = [appDelegate.contentListDS authorByContentId:cid];
	descriptionTextView.text = [appDelegate.contentListDS descriptionByContentId:cid];
	
	/*
	//Price.
	appDelegate.paymentHistoryDS.productsRequestDelegate = self;
	[appDelegate.paymentHistoryDS getProductInfomation:cid];
	priceLabel.text = @"(Now Loading...)";
	//BuyButton
	buyButton.titleLabel.text = @"(Now Loading...)";
	buyButton.enabled = NO;
	buyButton.hidden = YES;
	*/
}
#pragma mark - SKProductsRequestDelegate methods.
- (void)productsRequest:(SKProductsRequest *)request
	 didReceiveResponse:(SKProductsResponse *)responseParameters
{
	LOG_CURRENT_METHOD;
	if (responseParameters == nil) {
		priceLabel.text = @"(cannot buy this product.)";
		buyButton.hidden = YES;
		return;
	}
	
	for (SKProduct* resultProduct in responseParameters.products) {
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[numberFormatter setLocale:resultProduct.priceLocale];
		NSString *formattedString = [numberFormatter stringFromNumber:resultProduct.price];
		priceLabel.text = [formattedString stringByAppendingString:@"-"];
		
		//Enable buy.
		buyButton.hidden = NO;
		buyButton.enabled = YES;
		buyButton.titleLabel.text = @"Buy Now";
		
		//inner var.
		targetProductId = [NSString stringWithString:resultProduct.productIdentifier];
		[targetProductId retain];
		LOG_CURRENT_METHOD;
		NSLog(@"targetProductId=%@", targetProductId);
	}
}

#pragma mark -
- (IBAction)showContentList:(id)sender
{
	LOG_CURRENT_METHOD;
	[appDelegate hideContentDetailView];
	[appDelegate showContentListView];
}

- (IBAction)buyContent:(id)sender
{
	LOG_CURRENT_METHOD;
	NSLog(@"targetProductId class=%@", [targetProductId class]);
	NSLog(@"targetProductId=%@", targetProductId);
	//
	[appDelegate.paymentHistoryDS buyContent:targetProductId];
	return;
}




#pragma mark -
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
