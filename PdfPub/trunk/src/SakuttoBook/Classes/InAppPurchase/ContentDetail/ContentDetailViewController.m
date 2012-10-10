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
		
		//Change view size in iPad.
		CGRect viewFrame = CGRectZero;
#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 30200)
		// sdk upper 3.2
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			// iPad
			viewFrame = CGRectMake(0, 0, 768, 1024);
		}
		else {
			// other
			viewFrame = CGRectMake(0, 0, 320, 480);
		}
#else
		// sdk under 3.2
#endif
		self.view.frame = viewFrame;

    }
    return self;
}

#pragma mark - Implement.
- (void)setLabelsWithContentId:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	
	//inner var.
	targetCid = cid;
	
	
	//Thumbnail.
	thumbnailImageView.image = [appDelegate.contentListDS contentIconByContentId:cid];
	
	//Title, Author, Description.
	titleLabel.text = [appDelegate.contentListDS titleByContentId:cid];
	authorLabel.text = [appDelegate.contentListDS authorByContentId:cid];
	descriptionTextView.text = [appDelegate.contentListDS descriptionByContentId:cid];
	
	
	//Price.
	/*
	appDelegate.paymentConductor.productsRequestDelegate = self;
	[appDelegate.paymentConductor getProductInfomation:cid];
	*/
	NSString* pid = [[ProductIdList sharedManager] getProductIdentifier:cid];
	if ((pid == nil) || ([pid compare:InvalidProductId] == NSOrderedSame)) {
		NSLog(@"Invalid Product Id. cid=%d, pid=%@", cid, pid);
	}
	appDelegate.paymentConductor.parentVC = self;
	[appDelegate.paymentConductor getProductInfomation:pid];
	priceLabel.text = @"(Now Loading...)";
	
	//BuyButton
	buyButton.titleLabel.text = @"(Now Loading...)";
	buyButton.enabled = NO;
	buyButton.hidden = NO;
}
#pragma mark - SKProductsRequestDelegate methods.
- (void)productsRequest:(SKProductsRequest *)request
	 didReceiveResponse:(SKProductsResponse *)responseParameters
{
	LOG_CURRENT_METHOD;
	if (responseParameters == nil) {
		priceLabel.text = @"(cannot buy this product.)";
		buyButton.enabled = NO;
		buyButton.hidden = YES;
		return;
	}
	
	//NSLog(@"result count = %d", [responseParameters.products count]);
	if ([responseParameters.products count] <= 0) {
		buyButton.hidden = NO;
		buyButton.titleLabel.font = [UIFont systemFontOfSize:10.0f];
		CGRect frame = buyButton.titleLabel.frame;
		buyButton.titleLabel.frame = CGRectMake(frame.origin.x,
												frame.origin.y,
												150.0f,
												frame.size.height);
		buyButton.titleLabel.text = @"error";
		NSLog(@"responseParameters.invalidProductIdentifiers=%@", [responseParameters.invalidProductIdentifiers description]);
	}
	for (SKProduct* resultProduct in responseParameters.products) {
		//LOG_CURRENT_LINE;
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[numberFormatter setLocale:resultProduct.priceLocale];
		NSString *formattedString = [numberFormatter stringFromNumber:resultProduct.price];
		priceLabel.text = [formattedString stringByAppendingString:@"-"];
		
		//Enable buy.
		buyButton.hidden = NO;
		buyButton.enabled = YES;
		//buyButton.titleLabel.text = @"Buy Now";
		buyButton.titleLabel.text = [formattedString stringByAppendingString:@"-"];
		
		//inner var.
		targetProductId = [NSString stringWithString:resultProduct.productIdentifier];
		[targetProductId retain];
		
		//LOG_CURRENT_METHOD;
		//NSLog(@"targetProductId=%@", targetProductId);
	}
}

- (void)productRequestDidSuccess:(SKProduct*)product
{
	//Set price label.
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[numberFormatter setLocale:product.priceLocale];
	NSString *formattedString = [numberFormatter stringFromNumber:product.price];
	priceLabel.text = [formattedString stringByAppendingString:@"-"];
	//[buyButton setTitle:[formattedString stringByAppendingString:@"-"] forState:UIControlStateNormal];
	
	//Set targetProductId.
	targetProductId = [NSString stringWithString:product.productIdentifier];
	[targetProductId retain];

	//Set text.
	[buyButton setTitle:@"購入する" forState:UIControlStateNormal];
	[buyButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];

	//Enable buy.
	buyButton.hidden = NO;
	buyButton.enabled = YES;
}

- (void)productRequestDidFailed:(NSString*)invalidProductIdentifier
{
	LOG_CURRENT_METHOD;
	NSLog(@"%@", invalidProductIdentifier);
	
	//Set text.
	priceLabel.text = @"no product information.";
	[buyButton setTitle:@"購入できません" forState:UIControlStateNormal];
	[buyButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	//buyButton.enabled = NO;
	
	//Disble buy.
	buyButton.hidden = NO;
	buyButton.enabled = NO;
};

- (void)purchaseDidSuccess:(NSString*)productId
{
	targetCid = [[ProductIdList sharedManager] getContentIdentifier:productId];
	NSLog(@"pid=%@, cid=%d", productId, targetCid);
	//[self downloadContent:nil];
	
	
	//
	ContentId cid = [[ProductIdList sharedManager] getContentIdentifier:productId];
	NSLog(@"pid=%@, cid=%d", productId, cid);
	[appDelegate hideContentDetailView];
	[appDelegate showContentPlayerView:cid];
	
}
- (void)purchaseDidFailed:(NSError *)error
{
	NSLog(@"purchase error. error description=%@", [error description]);
	
	//Show alert.
	UIAlertView *alert = [[[UIAlertView alloc]
						   initWithTitle:@"purchse error"
						   message:[NSString stringWithFormat:@"課金処理に失敗しました。詳細：%@", [error description]]
						   delegate:nil
						   cancelButtonTitle:nil
						   otherButtonTitles:@"OK", nil]
						  autorelease];
	[alert show];
}


#pragma mark - related SKPaymentTransactionObserver methods.
- (void)completeTransaction:(SKPaymentTransaction*)transaction
{
	LOG_CURRENT_METHOD;
	//
	NSString* productID = transaction.payment.productIdentifier;
	//ContentId cid = [InAppPurchaseUtility getContentIdentifier:productID];
	ContentId cid = [[ProductIdList sharedManager] getContentIdentifier:productID];
	NSLog(@"pid=%@, cid=%d", productID, cid);
	[appDelegate hideContentDetailView];
	[appDelegate showContentPlayerView:cid];
}

#pragma mark -
- (IBAction)showContentList:(id)sender
{
	LOG_CURRENT_METHOD;
	[appDelegate hideContentDetailView];
	[appDelegate showContentListView];
}

- (IBAction)pushedBuyButton:(id)sender
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"targetProductId class=%@", [targetProductId class]);
	//NSLog(@"targetProductId=%@", targetProductId);
	
	buyButton.enabled = NO;		//Disable buy at twice.
	//[appDelegate.paymentHistoryDS buyContent:targetProductId];
	[appDelegate.paymentConductor buyContent:targetProductId];

	
	
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
