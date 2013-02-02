//
//  ContentListViewController.m
//  PurchaseTest04
//
//  Created by okano on 11/05/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContentListViewController.h"


@implementation ContentListViewController

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

	appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - show other view.
- (void)showContentPlayer:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	[appDelegate hideContentListView];
	[appDelegate showContentPlayerView:cid];
}
- (void)showContentDetailView:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	[appDelegate hideContentListView];
	[appDelegate showContentDetailView:cid];
}
- (IBAction)showServerContentListView
{
	//LOG_CURRENT_METHOD;
	[appDelegate hideContentListView];
	[appDelegate showServerContentListView];
}
- (IBAction)showPaymentHistoryList
{
	//LOG_CURRENT_METHOD;
	PaymentHistoryListViewController* paymentHistoryListVC = [[PaymentHistoryListViewController alloc] init];
	[self.view addSubview:paymentHistoryListVC.view];
}

#pragma mark - Setup Images.
- (void)setupImagesWithDataSource:(ContentListDS*)contentListDS shelfImageName:(NSString*)shelfImageName
{
	CGFloat maxWidth = self.view.frame.size.width;
	NSLog(@"self.view.frame=%@", NSStringFromCGRect(self.view.frame));
	
	CGFloat currentOriginX = 0.0f, currentOriginY = 0.0f;
	CGFloat maxHeightInLine;
	//
	CGFloat buttonOffsetX, buttonOffsetY;
	CGFloat spacerX, spacerY;
	CGFloat shelfImageHeight;	//shelfImageWidth = self.view.frame.size.width;
	CGFloat buttonImageWidth, buttonImageHeight;
	
	//On real device.
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		//iPad
		//iPad1,2 (1024x768 pixel)
		buttonOffsetX = 60, buttonOffsetY = 24;
		spacerX = 30.0f, spacerY = 30.0f;
		shelfImageHeight = 240;
		buttonImageWidth = 106.66667, buttonImageHeight = 160;	// (1/6 size)
		
		//double size if new iPad (2048x1536 pixel)
		if (768 < self.view.frame.size.width)
		{
			buttonOffsetX *= 2.0f, buttonOffsetY *= 2.0f;
			spacerX *= 2.0f, spacerY *= 2.0f;
			shelfImageHeight *= 2.0f;
			buttonImageWidth *= 2.0f, buttonImageHeight *= 2.0f;
		}
	} else {
		//old iPhone(320x480)
		buttonOffsetX = 30, buttonOffsetY = 10;
		spacerX = 15.0f, spacerY = 15.0f;
		shelfImageHeight = 180;
		buttonImageWidth = 80, buttonImageHeight = 120;
		
		//double size if iPhone 3.5-inch(640x960 or 640x1136)...only care width.
		//(never use this code because view width is fixed 320pixel in .xib)
		if (320 < self.view.frame.size.width)
		{
			buttonOffsetX *= 2.0f, buttonOffsetY *= 2.0f;
			spacerX *= 2.0f, spacerY *= 2.0f;
			shelfImageHeight *= 2.0f;
			buttonImageWidth *= 2.0f, buttonImageHeight *= 2.0f;
		}
	}
	
	//Setup shelf image. (fit width)
	UIImage* shelfImageOrg = [UIImage imageNamed:shelfImageName];	//@"shelf.png"
	UIImage* shelfImage = nil;
	CGFloat shelfImageWidthResized = self.view.frame.size.width;
	CGFloat shelfImageHeightResized = shelfImageHeight;		//shelfImageOrg.size.height / 2;
	UIGraphicsBeginImageContext(CGSizeMake(shelfImageWidthResized, shelfImageHeightResized));
	[shelfImageOrg drawInRect:CGRectMake(0, 0, shelfImageWidthResized, shelfImageHeightResized)];
	shelfImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	//Show first shelf.
	UIImageView* shelfImageView = [[UIImageView alloc] initWithImage:shelfImage];
	CGRect shelfImageFrame;
	shelfImageFrame = shelfImageView.frame;
	//shelfImageFrame.origin.y = 0;
	shelfImageView.frame = shelfImageFrame;
	[scrollView addSubview:shelfImageView];
	
	
	currentOriginX += buttonOffsetX;
	//currentOriginY += spacerY;
	
	//
	int maxCount = [contentListDS count];
	for (int i = 0; i < maxCount; i = i + 1)
	{
		ContentId targetCid = [contentListDS contentIdAtIndex:i];
		NSLog(@"contentCid=%d", targetCid);
		
		//Get cover image.
		UIImage* imageOriginal = nil;
		UIImage* image = nil;
		
		//(Get from coverUrl.)
		NSURL* coverImageUrl = [contentListDS coverUrlAtIndex:i];
		if (coverImageUrl == nil) {
			NSLog(@"cannot get coverUrl. targetCid=%d", targetCid);
			//(Get from thumbnailUrl.)
			coverImageUrl = [contentListDS thumbnailUrlAtIndex:i];
			if (coverImageUrl == nil) {
				NSLog(@"cannot get thumbnailUrl. targetCid=%d", targetCid);
			}
		}
		NSData *coverImageData = [NSData dataWithContentsOfURL:coverImageUrl];
		if (coverImageData == nil) {
			NSLog(@"coverImageData is nil. targetCid=%d", targetCid);
		}
		imageOriginal = [[UIImage alloc]  initWithData:coverImageData];
		if (imageOriginal == nil) {
			NSLog(@"error: no cover image. cid=%d", targetCid);
			//(Get from contentIcon.(included in project file) )
			imageOriginal = [contentListDS contentIconAtIndex:i];
			if (imageOriginal == nil) {
				NSLog(@"cannot get cover image with contentIcon. targetCid=%d", targetCid);
			}
		}
		
		//Resize cover image for fit in scroll view.
		UIGraphicsBeginImageContext(CGSizeMake(buttonImageWidth, buttonImageHeight));
		[imageOriginal drawInRect:CGRectMake(0, 0, buttonImageWidth, buttonImageHeight)];
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		
		// Check width.
		if (maxWidth < image.size.width) {
			LOG_CURRENT_METHOD;
			LOG_CURRENT_LINE;
			NSLog(@"image is too huge width. width=%f", image.size.width);
			continue;	//skip to next object.
		}
		
		// Locate.
		CGRect buttonRect = CGRectZero;
		buttonRect.origin.x = currentOriginX;
		buttonRect.origin.y = currentOriginY + buttonOffsetY;
		buttonRect.size = image.size;
		if (maxHeightInLine < buttonRect.size.height) {
			maxHeightInLine = buttonRect.size.height;
		}
		
		// Check locate. feed line if overflow X.
		if (maxWidth < currentOriginX + image.size.width) {
			//feed line.
			currentOriginX = 0.0f + buttonOffsetX;
			currentOriginY += shelfImageHeightResized;
			maxHeightInLine = image.size.height;
			
			buttonRect.origin.x = currentOriginX;
			buttonRect.origin.y = currentOriginY + buttonOffsetY;
			
			//Show shelf.
			UIImageView* shelfImageView = [[UIImageView alloc] initWithImage:shelfImage];
			CGRect shelfImageFrame;
			shelfImageFrame = shelfImageView.frame;
			shelfImageFrame.origin.x = 0.0f;
			shelfImageFrame.origin.y = currentOriginY;	// - spacerY;
			shelfImageView.frame = shelfImageFrame;
			[scrollView addSubview:shelfImageView];
			
		}
		
		// Positioning to next position.
		currentOriginX += buttonRect.size.width + spacerX;
		//NSLog(@"pageNum=%d, rect for button=%@", pageNum, NSStringFromCGRect(rect));
		
		
		// Add to subview.
		UIButton* button = [[UIButton alloc] init];
		[button setImage:image forState:UIControlStateNormal];
		button.frame = buttonRect;
		button.tag = targetCid;
		[button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
		[scrollView addSubview:button];
		
		//Check payment status and show.
		NSString* targetPid = [[ProductIdList sharedManager] getProductIdentifier:targetCid];
		if (([[ProductIdList sharedManager] isFreeContent:targetPid] == TRUE)
			||
			([appDelegate.paymentHistoryDS isEnabledContent:targetCid] == TRUE))
		{
			//Paid content.
			//Do nothing.
		} else {
			//UnPaid content. Show unPaid mark.
			UIImage* unPaidImageOrg = [UIImage imageNamed:@"unpaid.png"];
			UIImage* unPaidImage = nil;
			CGFloat unPaidImageOffsetX = 2.0, unPaidImageOffsetY = 2.0;
			//(Resize unPaid mark image.)
			CGFloat unPaidImageWidth = button.frame.size.width / 10;
			UIGraphicsBeginImageContext(CGSizeMake(unPaidImageWidth, unPaidImageWidth));
			[unPaidImageOrg drawInRect:CGRectMake(0, 0, unPaidImageWidth, unPaidImageWidth)];
			unPaidImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			//(Set position.)
			UIImageView* unPaidImageView = [[UIImageView alloc] initWithImage:unPaidImage];
			CGRect unPaidImageViewFrame = CGRectMake(button.frame.origin.x + unPaidImageOffsetX,
													 button.frame.origin.y + unPaidImageOffsetY,
													 unPaidImage.size.width,
													 unPaidImage.size.height);
			unPaidImageView.frame = unPaidImageViewFrame;
			[scrollView addSubview:unPaidImageView];
		}
		
		// Set contentSize to scrollView.
		scrollView.contentSize = CGSizeMake(maxWidth, currentOriginY + shelfImageHeight);
	}
	
	//Add empty shelf for fill white space.
	while (currentOriginY + shelfImageHeight < self.view.frame.size.height)
	{
		//Feed next column.
		currentOriginY += shelfImageHeight;
		
		//Show empty shelf.
		UIImageView* shelfImageView = [[UIImageView alloc] initWithImage:shelfImage];
		CGRect shelfImageFrame;
		shelfImageFrame = shelfImageView.frame;
		shelfImageFrame.origin.x = 0.0f;
		shelfImageFrame.origin.y = currentOriginY;	// - spacerY;
		shelfImageView.frame = shelfImageFrame;
		[scrollView addSubview:shelfImageView];
		
		// Set contentSize to scrollView.
		scrollView.contentSize = CGSizeMake(maxWidth, currentOriginY);
	}
}

@end
