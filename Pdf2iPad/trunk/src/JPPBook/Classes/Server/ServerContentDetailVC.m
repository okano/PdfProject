//
//  ContentDetailView.m
//  SakuttoBook
//
//  Created by okano on 11/06/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerContentDetailVC.h"


@implementation ServerContentDetailVC
@synthesize targetUuid;
@synthesize targetUrl;
@synthesize thumbnailImageView, titleLabel, authorLabel, descriptionTextView;
@synthesize priceLabel;
@synthesize buyButton, reDownloadButton;

#pragma mark -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
		targetCid = UndefinedContentId;
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

- (void)setLabelsWithUuid:(NSString *)uuid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	NSLog(@"uuid=%@", uuid);
	//inner var.
	targetUuid = uuid;
	
	
	//Thumbnail.
	UIImage* thumbnailImage = [CoverUtility coverImageWithUuid:uuid];
	thumbnailImageView.image = thumbnailImage;
	
	//Title, Author, Description.
	titleLabel.text = [appDelegate.serverContentListDS titleByUuid:uuid];
	authorLabel.text = [appDelegate.serverContentListDS authorByUuid:uuid];
	descriptionTextView.text = [appDelegate.serverContentListDS descriptionByUuid:uuid];
	
	//URL for download.
	NSURL* u = [appDelegate.serverContentListDS acquisitionUrlByUuid:uuid];
	targetUrl = [[NSURL alloc] initWithString:[u description]];
	NSLog(@"targetUrl class=%@", [targetUrl class]);
	NSLog(@"targetUrl=%@", [targetUrl description]);
	
	//Price.
	//appDelegate.paymentConductor.productsRequestDelegate = self;
	//[appDelegate.paymentConductor getProductInfomation:cid];
	//priceLabel.text = @"(Now Loading...)";
	
	//BuyButton
	buyButton.enabled = NO;
	buyButton.hidden = NO;
	targetCid = [appDelegate.contentListDS contentIdFromUuid:uuid];	/* USE contentListDS(not use ServerContentListDS) */
	NSLog(@"targetCid=%d", targetCid);
	
	targetCid = [appDelegate.serverContentListDS contentIdFromUuid:uuid];
	NSLog(@"targetCid=%d", targetCid);
	
	
	if ((targetCid != UndefinedContentId)
		&&
		(targetCid != InvalidContentId)
		&&
		([appDelegate.paymentHistoryDS isEnabledContent:targetCid] == TRUE))
	{
		//購入済み
		buyButton.hidden = YES;
		reDownloadButton.hidden = NO;
	} else {
		//未購入
		buyButton.hidden = NO;
		reDownloadButton.hidden = YES;
	}
	
	
	//Get Price.
	appDelegate.paymentConductor.parentVC = self;
	[appDelegate.paymentConductor getProductInfomation:targetCid];
}
#pragma mark - related SKProductsRequestDelegate methods.
/*
- (void)productsRequest:(SKProductsRequest *)request
	 didReceiveResponse:(SKProductsResponse *)responseParameters
{
	LOG_CURRENT_METHOD;
	if (responseParameters == nil) {
		priceLabel.text = @"(cannot buy this product.)";
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
*/

#pragma mark -
- (void)productRequestDidSuccess:(SKProduct *)product
{
	LOG_CURRENT_METHOD;
	
	//Set price label.
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[numberFormatter setLocale:product.priceLocale];
	NSString *formattedString = [numberFormatter stringFromNumber:product.price];
	priceLabel.text = [formattedString stringByAppendingString:@"-"];
	
	//Set buy button.
	buyButton.enabled = YES;
	
	//Set product id.
	NSLog(@"product=%@",[product description]);
	NSLog(@"product id = %@", [product productIdentifier]);
	NSLog(@"class=%@", [product.productIdentifier class]);
	targetProductId = [[NSString  alloc] initWithFormat:[product productIdentifier]];
}
- (void)productRequestDidFailed:(NSString *)invalidProductIdentifier
{
	LOG_CURRENT_METHOD;
	
	priceLabel.text = @"error";
	[buyButton setTitle:@"購入できません" forState:UIControlStateNormal];
	[buyButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	//buyButton.enabled = NO;
}


#pragma mark - related SKPaymentTransactionObserver methods.
/*
- (void)completeTransaction:(SKPaymentTransaction*)transaction
{
	LOG_CURRENT_METHOD;
	//
	NSString* productID = transaction.payment.productIdentifier;
	ContentId cid = [InAppPurchaseUtility getContentIdentifier:productID];
	NSLog(@"pid=%@, cid=%d", productID, cid);
	[appDelegate hideContentDetailView];
	[appDelegate showContentPlayerView:cid];
}
*/

- (void)purchaseDidSuccess:(NSString *)productId
{
	targetCid = [InAppPurchaseUtility getContentIdentifier:productId];
	NSLog(@"pid=%@, cid=%d", productId, targetCid);
	[self downloadContent:nil];
}
- (void)purchaseDidFailed:(NSError *)error
{
	NSLog(@"purchase error. error description=%@", [error description]);
	
	//Show alert.
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"purchse error"
						  message:[NSString stringWithFormat:@"課金処理に失敗しました。詳細：%@", [error description]]
						  delegate:nil
						  cancelButtonTitle:nil
						  otherButtonTitles:@"OK", nil];
	[alert show];
	NSLog(@"error userinfo=%@", [[error userInfo] description]);
	
	//ReEnable buy button.
	buyButton.enabled = YES;
	
}

#pragma mark -
- (IBAction)showServerContentList:(id)sender
{
	LOG_CURRENT_METHOD;
	[appDelegate hideContentDetailView];
	[appDelegate showServerContentListView];
}

- (IBAction)buyContent:(id)sender
{
	LOG_CURRENT_METHOD;
	//NSLog(@"targetProductId class=%@", [targetProductId class]);
	NSLog(@"targetProductId=%@", targetProductId);
	if (targetProductId == nil) {
		LOG_CURRENT_LINE;
		NSLog(@"no productId found.");
	}

	
	buyButton.enabled = NO;		//Disable buy at twice.
	[appDelegate.paymentConductor buyContent:targetProductId];
	return;
}

- (IBAction)downloadContent:(id)sender
{
	LOG_CURRENT_METHOD;
	
	NSLog(@"targetCid=%d", targetCid);
	NSLog(@"targetUrl class=%@", [targetUrl class]);
	NSLog(@"targetUrl=%@", [targetUrl description]);
	NSLog(@"targetUuid=%@", targetUuid);
	
	ServerContentDownloadVC* downloaderVC = [[ServerContentDownloadVC alloc] initWithNibName:@"ServerContentDownload"
																					bundle:[NSBundle mainBundle] 
																				 targetUrl:targetUrl
																				  targetUuid:targetUuid];
	LOG_CURRENT_LINE;
	[self presentModalViewController:downloaderVC animated:YES];
	[downloaderVC doDownload];
}


#pragma mark - View lifecycle
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
