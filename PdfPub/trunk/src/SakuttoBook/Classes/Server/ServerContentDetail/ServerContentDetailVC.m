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
@synthesize thumbnailImageView, thumbnailScrollView, titleLabel, authorLabel, descriptionTextView;
@synthesize priceLabel;
@synthesize previewButton;
@synthesize buyButton, reDownloadButton;

#pragma mark -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
		targetCid = UndefinedContentId;
		targetProductId = nil;
		
		//Fit view size with screen. (iPhone-3.5inch/iPhone-4inch/iPad/iPad-Retina)
		self.view.frame = [[UIScreen mainScreen] bounds];

    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[self enableReDownloadButton];	//for cancel overwrite confirm.
	
	//For debug.
	[self hideDownloadWithoutPurchase];
#if defined (DEBUG_FREE_PURCHASE) && DEBUG_FREE_PURCHASE == 1
	[self showDownloadWithoutPurchase];
#endif
}

- (void)setLabelsWithUuid:(NSString *)uuid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	//NSLog(@"uuid=%@", uuid);
	//inner var.
	targetUuid = uuid;
	
	CGSize totalContentSize;
	CGFloat totalHeight = scrollView.frame.size.height + 44;
	
	//Thumbnail.
	UIImage* thumbnailImage = [CoverUtility coverImageWithUuid:uuid];
	thumbnailImageView.image = thumbnailImage;
	
	//Title, Author, Description.
	titleLabel.text = [appDelegate.serverContentListDS titleByUuid:uuid];
	authorLabel.text = [appDelegate.serverContentListDS authorByUuid:uuid];
	descriptionTextView.text = [appDelegate.serverContentListDS descriptionByUuid:uuid];
	
	//URL for preview.
	previewUrl = [[appDelegate.serverContentListDS previewUrlByUuid:uuid] copy];
	if (previewUrl == nil) {
		[self hidePreviewButton];
	} else {
		[self showPreviewButton];
	}
	
	//URL for download.
	NSURL* u = [appDelegate.serverContentListDS acquisitionUrlByUuid:uuid];
	if (u == nil) {
		//not exist acquisition content.
		LOG_CURRENT_METHOD;
		NSLog(@"valid contents not found. uuid=%@", uuid);
		priceLabel.text = @"no file found.";
		[buyButton setTitle:@"購入できません" forState:UIControlStateNormal];
		[self disableBuyButton];
		[self hideReDownloadButton];
		//Show alert.
		UIAlertView *alert = [[[UIAlertView alloc]
							   initWithTitle:@"format error"
							   message:@"このコンテンツはダウンロードできません。有効なダウンロードリンクが見つかりません。"
							   delegate:nil
							   cancelButtonTitle:nil
							   otherButtonTitles:@"OK", nil]
							  autorelease];
		[alert show];
		return;
	}
	targetUrl = [[NSURL alloc] initWithString:[u description]];
	NSLog(@"targetUrl class=%@", [targetUrl class]);
	NSLog(@"targetUrl=%@", [targetUrl description]);
	
	//Price.
	//NSString* pid = [appDelegate.productIdList getProductIdentifier:cid];
	//appDelegate.paymentConductor.productsRequestDelegate = self;
	//[appDelegate.paymentConductor getProductInfomation:cid];
	//priceLabel.text = @"(Now Loading...)";
	
	//BuyButton
	[self disableBuyButton];	//show but cannot push.
	
	//
	//targetCid = [appDelegate.contentListDS contentIdFromUuid:uuid];	/* USE contentListDS(not use ServerContentListDS) */
	//NSLog(@"targetCid=%d", targetCid);
	
	targetCid = [appDelegate.serverContentListDS contentIdFromUuid:uuid];
	NSLog(@"targetCid=%d", targetCid);
	
	
	if ((targetCid == UndefinedContentId)
		||
		(targetCid == InvalidContentId)
		)
	{
		//未購入
		NSLog(@"not yet buy(targetCid=%d)", targetCid);
		[self disableBuyButton];	//enable with price get.
		[self hideReDownloadButton];
	} else if ([appDelegate.paymentHistoryDS isEnabledContent:targetCid] == TRUE) {
		//購入済み
		NSLog(@"paymentHistoryDS=%@", [appDelegate.paymentHistoryDS description]);
		NSLog(@"has been buy");
		[self hideBuyButton];
		[self enableReDownloadButton];
	} else {
		//未購入
		NSLog(@"not yet buy");
		[self disableBuyButton];	//enable with price get.
		[self hideReDownloadButton];
	}
	
	
	//Get Price.
//	if (targetProductId == nil) {
		targetProductId = [NSString stringWithString:[[ProductIdList sharedManager] getProductIdentifier:targetCid]];
		if ((targetProductId == nil) || ([targetProductId length] <= 0)) {
			LOG_CURRENT_METHOD;
			NSLog(@"cid=%d, but targetProductId is nil or 0-length.", targetCid);
			NSLog(@"productIdList count=%d, %@", [[ProductIdList sharedManager] count], [[ProductIdList sharedManager] description]);
			
			priceLabel.text = @"no productId found.";
			return;
		} else {
			NSLog(@"get pid. targetProductId=%@", targetProductId);
		}
//	} else {
//		LOG_CURRENT_METHOD;
//		NSLog(@"targetProductId=%@", targetProductId);
//	}
	
	// Do not need productId for Apple-server if content is free.
	if ([[ProductIdList sharedManager] isFreeContentWithCid:targetCid] == TRUE) {
		[priceLabel setText:@"無料コンテンツ"];
		[self enableReDownloadButton];
		[reDownloadButton setTitle:@"無料ダウンロード" forState:UIControlStateNormal];
	} else {
		appDelegate.paymentConductor.parentVC = self;
		[appDelegate.paymentConductor getProductInfomation:targetProductId withContinueBuy:NO];
	}
	
	
	totalHeight = 400;
	
	//erase old thumbnail view.
	for (UIView* v in thumbnailScrollView.subviews) {
		[v removeFromSuperview];
	}
	
	//Thumbnail images. "http://opds-spec.org/thumbnail/{1..4}"
	//NSMutableArray* thumbnailUrlLinks = [appDelegate.serverContentListDS thumbnailUrlsByContentId:targetCid];
	NSMutableArray* thumbnailImages = [appDelegate.serverContentListDS thumbnailImagesByContentId:targetCid];
	if (thumbnailImages != nil) {
		LOG_CURRENT_LINE;
		CGFloat maxHeight = 0;
		CGFloat curPosX = 0, offsetX = 10, merginX = 10;
		
		curPosX = offsetX;
		for (UIImage* thumbnailImageOrg in thumbnailImages) {
			NSLog(@"thumbnailImage size=%@", NSStringFromCGSize([thumbnailImage size]));
			
			//Resige image.
			CGFloat thumbnailImageHeightResized = thumbnailImageView.frame.size.height;
			CGFloat resizeRetio = thumbnailImageView.frame.size.height / thumbnailImageOrg.size.height;
			CGFloat thumbnailImageWidthResized = thumbnailImageOrg.size.width * resizeRetio;
			UIGraphicsBeginImageContext(CGSizeMake(thumbnailImageWidthResized, thumbnailImageHeightResized));
			[thumbnailImageOrg drawInRect:CGRectMake(0, 0, thumbnailImageWidthResized, thumbnailImageHeightResized)];
			UIImage* thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			
			//positioning image.
			UIImageView* tiView = [[UIImageView alloc] initWithImage:thumbnailImage];
			CGRect rect = tiView.frame;
			rect.origin.x = curPosX;
			tiView.frame = rect;
			[thumbnailScrollView addSubview:tiView];
			
			//Fit thumbnailScrollView height with image..
			if (maxHeight < thumbnailImage.size.height) {
				maxHeight = thumbnailImage.size.height;
				
				//Resize scrollView height.
				CGRect thumbnailScrollViewFrame = thumbnailScrollView.frame;
				thumbnailScrollViewFrame.size.height = thumbnailImage.size.height;
				thumbnailScrollView.frame = thumbnailScrollViewFrame;
			}
			
			curPosX += thumbnailImage.size.width + merginX;
			
			CGSize contentSize = CGSizeMake(curPosX, maxHeight);
			[thumbnailScrollView setContentSize:contentSize];
		}
		//Resize total scrollView.
		totalHeight += thumbnailScrollView.frame.size.height;
		totalContentSize = scrollView.contentSize;
		totalContentSize.height = totalHeight;
		if (totalContentSize.width < self.view.frame.size.width) {
			totalContentSize.width = self.view.frame.size.width;
		}
		[scrollView setContentSize:totalContentSize];
		[scrollView scrollsToTop];
	}
	
	totalContentSize = scrollView.contentSize;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		//iPhone
		totalContentSize = CGSizeMake(self.view.frame.size.width, 2310);
	} else {
		//iPad
		totalContentSize = CGSizeMake(self.view.frame.size.width, 3600);
	}
	[scrollView setContentSize:totalContentSize];
}


- (void)enableBuyButton {
	buyButton.hidden = NO;
	buyButton.enabled = YES;
	[buyButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
}
- (void)disableBuyButton { //Disable but shown.
	buyButton.hidden = NO;
	buyButton.enabled = NO;
	[buyButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
}
- (void)hideBuyButton {
	buyButton.hidden = YES;
}

- (void)enableReDownloadButton {
	reDownloadButton.hidden = NO;
	reDownloadButton.enabled = YES;
	[reDownloadButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
}
- (void)disableReDownloadButton { //Disable but shown.
	reDownloadButton.hidden = NO;
	reDownloadButton.enabled = NO;
	[reDownloadButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
}
- (void)hideReDownloadButton {
	reDownloadButton.hidden = YES;
}


#pragma mark - preview.
- (void)showPreviewButton
{
	previewButton.hidden = NO;
}
- (void)hidePreviewButton
{
	previewButton.hidden = YES;
}
- (IBAction)pushedPreviewButton:(id)sender
{
	if (previewUrl != nil) {
		LOG_CURRENT_LINE;
		NSLog(@"previewUrl=%@", [previewUrl description]);
		
		NSString* ext = [previewUrl pathExtension];
		if (([ext caseInsensitiveCompare:@"mov"] == NSOrderedSame)
			|| ([ext caseInsensitiveCompare:@"mp4"] == NSOrderedSame)
			|| ([ext caseInsensitiveCompare:@"m4v"] == NSOrderedSame)
			|| ([ext caseInsensitiveCompare:@"mpv"] == NSOrderedSame)
			|| ([ext caseInsensitiveCompare:@"mpg"] == NSOrderedSame)
			|| ([ext caseInsensitiveCompare:@"3gp"] == NSOrderedSame)
			)
		{
			[self showMoviePlayer:previewUrl];
		}
	}
}
- (void)showMoviePlayer:(NSURL*)url
{
	NSLog(@"url class=%@", [url class]);
	NSLog(@"url=%@", [url description]);
	if (url != nil) {
		/*
		//Download preview file from URL.
		NSString* targetCidStr = [[NSNumber numberWithInt:targetCid] stringValue];
		NSLog(@"targetCid=%d(%@)", targetCid, targetCidStr);
		NSString* tmpDir = [ContentFileUtility getContentTmpDirectoryWithContentId:targetCidStr];
		NSString* filename = [url lastPathComponent];
		NSString* localFilename = [tmpDir stringByAppendingPathComponent:filename];
		NSLog(@"localFilename=%@", localFilename);
		
		NSData *previewFileData = [NSData dataWithContentsOfURL:url];

		
		//NSData* previewFileData = [[NSData alloc] initWithContentsOfURL:url];
		NSLog(@"data length=%d", [previewFileData length]);
		if (previewFileData == nil) {
			LOG_CURRENT_LINE;
		}
		
		[FileUtility makeDir:tmpDir];
		NSError* error = nil;
		[previewFileData writeToFile:localFilename
				  options:NSDataWritingFileProtectionComplete error:&error];
		if (error != nil)
		{
			NSLog(@"file write error. code=%d, desc=%@", [error code], [error localizedDescription]);
		}
		
		
		MPMoviePlayerViewController* mpview;
		NSURL* urlTmp = [[NSURL alloc] initFileURLWithPath:localFilename];
		if ((mpview = [[MPMoviePlayerViewController alloc] initWithContentURL:urlTmp]) != nil) {
		*/
		MPMoviePlayerViewController* mpview;
		if ((mpview = [[MPMoviePlayerViewController alloc] initWithContentURL:previewUrl]) != nil) {
			[self presentMoviePlayerViewControllerAnimated:mpview];
			//[mpview.moviePlayer setControlStyle:MPMovieControlStyleDefault];
			[mpview.moviePlayer setMovieSourceType:MPMovieSourceTypeFile];	//play from localfile.
			[mpview.moviePlayer prepareToPlay];
			[mpview.moviePlayer play];
			[mpview release];
		}
	}
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
	if ([appDelegate.paymentHistoryDS isEnabledContent:targetCid] == TRUE) {
		[self disableBuyButton];
		[buyButton setTitle:@"購入済み" forState:UIControlStateNormal];
	} else {
		[self enableBuyButton];
	}
	
	//Set product id.
	NSLog(@"product=%@",[product description]);
	NSLog(@"product id = %@", [product productIdentifier]);
	NSLog(@"class=%@", [product.productIdentifier class]);
	targetProductId = [[NSString  alloc] initWithString:[product productIdentifier]];
}
- (void)productRequestDidFailed:(NSString *)invalidProductIdentifier
{
	LOG_CURRENT_METHOD;
	NSLog(@"targetCid=%d", targetCid);
	
	priceLabel.text = @"error";
	[buyButton setTitle:@"購入できません" forState:UIControlStateNormal];
	[self disableBuyButton];
	
	if ([appDelegate.paymentHistoryDS isEnabledContent:targetCid] == TRUE) {
		//購入済み
	} else {
		//未購入
		[self hideReDownloadButton];
	}
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
	targetCid = [[ProductIdList sharedManager] getContentIdentifier:productId];
	NSLog(@"pid=%@, cid=%d", productId, targetCid);
	[self downloadContent:nil];
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
	NSLog(@"error userinfo=%@", [[error userInfo] description]);
	
	//ReEnable buy button.
	[self enableBuyButton];
}

#pragma mark -
- (IBAction)showServerContentList:(id)sender
{
	LOG_CURRENT_METHOD;
	[appDelegate hideContentDetailView];
	[appDelegate showServerContentListView];
}

- (IBAction)pushedBuyButton:(id)sender
{
	LOG_CURRENT_METHOD;
	//NSLog(@"targetProductId class=%@", [targetProductId class]);
	NSLog(@"targetProductId=%@", targetProductId);
	if (targetProductId == nil) {
		LOG_CURRENT_LINE;
		NSLog(@"no productId found.");
	}

	[self disableBuyButton];	//Disable buy at twice.
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
	
	targetProductId = [NSString stringWithString:[[ProductIdList sharedManager] getProductIdentifier:targetCid]];
	NSLog(@"targetProductId=%@", targetProductId);
	
	[self disableReDownloadButton];
	
	ServerContentDownloadVC* downloaderVC = [[ServerContentDownloadVC alloc] initWithNibName:@"ServerContentDownload"
																					bundle:[NSBundle mainBundle] 
																				 targetUrl:targetUrl
																				  targetUuid:targetUuid
																				   targetCid:targetCid];
	
	LOG_CURRENT_LINE;
	[self presentModalViewController:downloaderVC animated:YES];
	[downloaderVC doDownload];
	
	if ([[ProductIdList sharedManager] isFreeContentWithCid:targetCid] == TRUE) {
		//Write payment record for free content only first time read.
		[appDelegate.paymentHistoryDS recordHistoryOnceWithContentId:targetCid ProductId:targetProductId];
	}
}

#pragma mark - For Debug.
- (IBAction)downloadWithoutPurchase:(id)sender
{
#if defined (DEBUG_FREE_PURCHASE) && DEBUG_FREE_PURCHASE == 1
	[self downloadContent:sender];
#endif
}
- (void)showDownloadWithoutPurchase
{
	downloadWithoutPurchaseButton.hidden = NO;
}
- (void)hideDownloadWithoutPurchase
{
	downloadWithoutPurchaseButton.hidden = YES;
}

#pragma mark - View lifecycle
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
