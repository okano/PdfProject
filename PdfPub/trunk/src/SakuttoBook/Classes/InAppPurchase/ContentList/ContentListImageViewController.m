//
//  ContentListImageViewController.m
//  SakuttoBook
//
//  Created by okano on 13/01/10.
//
//

#import "ContentListImageViewController.h"

@interface ContentListImageViewController ()

@end

@implementation ContentListImageViewController


#pragma mark - View lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//Fit view size with screen. (iPhone-3.5inch/iPhone-4inch/iPad/iPad-Retina)
	self.view.frame = [[UIScreen mainScreen] bounds];
	
#if defined(HIDE_SERVER_BUTTON) && HIDE_SERVER_BUTTON != 0
	//Hide Server Button.
#define STORE_BUTTON_TAG 300
	serverContentButton.tag = STORE_BUTTON_TAG;
	NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:[toolbar items]];
	for (UIBarButtonItem* item in [toolbarItems reverseObjectEnumerator]) {
		if (item.tag == STORE_BUTTON_TAG) {
			[toolbarItems removeObject:item];
		}
	}
	toolbar.items = toolbarItems;
#endif
	
	[self setupImagesWithDataSource:appDelegate.contentListDS shelfImageName:@"shelf.png"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)setupImagesWithDataSource:(ContentListDS*)contentListDS shelfImageName:(NSString*)shelfImageName
{
	CGFloat maxWidth = self.view.frame.size.width;
	
	CGFloat currentOriginX = 0.0f, currentOriginY = 0.0f;
	CGFloat maxHeightInLine;
	//
	CGFloat spacerX, spacerY;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// iPad
		spacerX = 25.0f, spacerY = 20.0f;
	} else {
		// iPhone
		spacerX = 4.0f, spacerY = 4.0f;
	}

	currentOriginX += spacerX;
	currentOriginY += spacerY;
	
	//Setup shelf image. (fit width)
	UIImage* shelfImageOrg = [UIImage imageNamed:shelfImageName];	//@"shelf.png"
	UIImage* shelfImage = nil;
	CGFloat shelfImageWidthResized = self.view.frame.size.width;
	CGFloat shelfImageHeightResized = shelfImageOrg.size.height / 2;
	UIGraphicsBeginImageContext(CGSizeMake(shelfImageWidthResized, shelfImageHeightResized));
	[shelfImageOrg drawInRect:CGRectMake(0, 0, shelfImageWidthResized, shelfImageHeightResized)];
	shelfImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	//Show first shelf.
	UIImageView* shelfImageView = [[UIImageView alloc] initWithImage:shelfImage];
	CGRect shelfImageFrame;
	shelfImageFrame = shelfImageView.frame;
	shelfImageFrame.origin.y = 2;
	shelfImageView.frame = shelfImageFrame;
	[scrollView addSubview:shelfImageView];
	
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
		NSUInteger imageInEachLine;
		CGFloat newImageWidth, newImageHeight;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			// iPad
			imageInEachLine = 5;
			newImageWidth = ((self.view.frame.size.width - spacerX) / imageInEachLine) - spacerX;
			newImageHeight = imageOriginal.size.height * (newImageWidth / imageOriginal.size.width);
		} else {
			// iPhone
			imageInEachLine = 3;
			newImageWidth = ((self.view.frame.size.width - spacerX) / imageInEachLine) - spacerX;
			newImageHeight = imageOriginal.size.height * (newImageWidth / imageOriginal.size.width);
		}
		UIGraphicsBeginImageContext(CGSizeMake(newImageWidth, newImageHeight));
		[imageOriginal drawInRect:CGRectMake(0, 0, newImageWidth, newImageHeight)];
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
		CGRect rect = CGRectZero;
		rect.origin.x = currentOriginX;
		rect.origin.y = currentOriginY;
		rect.size = image.size;
		if (maxHeightInLine < rect.size.height) {
			maxHeightInLine = rect.size.height;
		}
		
		// Check locate. feed line.
		if (maxWidth < currentOriginX + image.size.width) {
			//feed line.
			currentOriginX = 0.0f + spacerX;
			currentOriginY += maxHeightInLine;
			currentOriginY += spacerY + spacerY + spacerY;
			maxHeightInLine = image.size.height;
			
			rect.origin.x = currentOriginX;
			rect.origin.y = currentOriginY;
			
			//Show shelf.
			UIImageView* shelfImageView = [[UIImageView alloc] initWithImage:shelfImage];
			CGRect shelfImageFrame;
			shelfImageFrame = shelfImageView.frame;
			shelfImageFrame.origin.y = currentOriginY - spacerY;
			shelfImageView.frame = shelfImageFrame;
			[scrollView addSubview:shelfImageView];
		}
		// Positioning to next position.
		currentOriginX += rect.size.width;
		currentOriginX += spacerX;
		//NSLog(@"pageNum=%d, rect for button=%@", pageNum, NSStringFromCGRect(rect));
		
		// Add to subview.
		UIButton* button = [[UIButton alloc] init];
		[button setImage:image forState:UIControlStateNormal];
		button.frame = rect;
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
			//(Resize unPaid mark image.)
			newImageWidth = button.frame.size.width / 10;
			UIGraphicsBeginImageContext(CGSizeMake(newImageWidth, newImageWidth));
			[unPaidImageOrg drawInRect:CGRectMake(0, 0, newImageWidth, newImageWidth)];
			unPaidImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			//(Set position.)
			UIImageView* unPaidImageView = [[UIImageView alloc] initWithImage:unPaidImage];
			CGRect unPaidImageViewFrame = CGRectMake(button.frame.origin.x + 2,
													 button.frame.origin.y + 2,
													 unPaidImage.size.width,
													 unPaidImage.size.height);
			unPaidImageView.frame = unPaidImageViewFrame;
			[scrollView addSubview:unPaidImageView];
		}
		
		// Set contentSize to scrollView.
		scrollView.contentSize = CGSizeMake(maxWidth, currentOriginY + maxHeightInLine);
	}
}

-(void)buttonEvent:(UIButton*)button
{
	//LOG_CURRENT_METHOD;
	
	ContentId targetCid = button.tag;
	NSLog(@"touch cover image. targetCid = %d", targetCid);
	
	//[appDelegate hideContentListView];
	
	//Check payment status.
	NSString* targetPid = [[ProductIdList sharedManager] getProductIdentifier:targetCid];
	BOOL isPayedContent = NO;
	if ([[ProductIdList sharedManager] isFreeContent:targetPid] == TRUE) {
		isPayedContent = YES;
		
		//Record free content payment record only first time read.
		//(TODO: Set date to first_launchup_daytime.)
		[appDelegate.paymentHistoryDS recordHistoryOnceWithContentId:targetCid ProductId:targetPid date:nil];
	}
	if ([appDelegate.paymentHistoryDS isEnabledContent:targetCid] == TRUE) {
		isPayedContent = YES;
	}
	
	if (isPayedContent == YES) {
		[self showContentPlayer:targetCid];
	} else {
		[self showContentDetailView:targetCid];
	}
}

@end
