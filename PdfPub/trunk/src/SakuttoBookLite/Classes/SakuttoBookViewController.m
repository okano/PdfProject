//
//  SakuttoBookViewController.m
//  SakuttoBook
//
//  Created by okano on 10/12/13.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "SakuttoBookViewController.h"

@implementation SakuttoBookViewController
@synthesize pdfScrollView1, pdfScrollView2, pdfScrollView3;
@synthesize pdfURL;
//@synthesize imageView1, imageView2, imageView3;
//@synthesize image1, image2, image3;
@synthesize menuViewController, webViewController, tocViewController;
@synthesize isShownMenuBar, isShownTocView;
//@synthesize currentImageView;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


#pragma mark -
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"PDF";
	
	currentPageNum = 1;//;
	//1-start.
	
#pragma mark (Setup ImageView, Pointer)
	//Initialized in xib file.
	//imageView1 = [[UIImageView alloc] init];
	//imageView2 = [[UIImageView alloc] init];
	//imageView3 = [[UIImageView alloc] init];
	//currentScrollView = [[UIScrollView alloc] init];
	
	//
	[pdfScrollView1 setupUiScrollView];
	[pdfScrollView2 setupUiScrollView];
	[pdfScrollView3 setupUiScrollView];
	
	//Set pointer.
	prevPdfScrollView	= pdfScrollView1;
	nextPdfScrollView	= pdfScrollView2;
	currentPdfScrollView= pdfScrollView3;
	
#pragma mark (gesture)
	//Add gesture recognizer to imageView1,2,3, scrollView.
	tapRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	tapRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	tapRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	[pdfScrollView1 addGestureRecognizer:tapRecognizer1];
	[pdfScrollView2 addGestureRecognizer:tapRecognizer2];
	[pdfScrollView3 addGestureRecognizer:tapRecognizer3];
	//(Swipe)
	swipeRecognizer1right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	swipeRecognizer2right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	swipeRecognizer3right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	swipeRecognizer1left  = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	swipeRecognizer2left  = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	swipeRecognizer3left  = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	swipeRecognizer1right.direction = UISwipeGestureRecognizerDirectionRight;
	swipeRecognizer2right.direction = UISwipeGestureRecognizerDirectionRight;
	swipeRecognizer3right.direction = UISwipeGestureRecognizerDirectionRight;
	swipeRecognizer1left.direction  = UISwipeGestureRecognizerDirectionLeft;
	swipeRecognizer2left.direction  = UISwipeGestureRecognizerDirectionLeft;
	swipeRecognizer3left.direction  = UISwipeGestureRecognizerDirectionLeft;
	[pdfScrollView1 addGestureRecognizer:swipeRecognizer1right];
	[pdfScrollView2 addGestureRecognizer:swipeRecognizer2right];
	[pdfScrollView3 addGestureRecognizer:swipeRecognizer3right];
	[pdfScrollView1 addGestureRecognizer:swipeRecognizer1left];
	[pdfScrollView2 addGestureRecognizer:swipeRecognizer2left];
	[pdfScrollView3 addGestureRecognizer:swipeRecognizer3left];
	
	/*
	 panRecognizer1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	 panRecognizer2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	 panRecognizer3 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	 [pdfScrolView1 addGestureRecognizer:panRecognizer1];
	 [pdfScrolView2 addGestureRecognizer:panRecognizer2];
	 [pdfScrolView3 addGestureRecognizer:panRecognizer3];
	 */
	
	
	//Setup maxPageNum.
	if ([self setupPdfBasicInfo] == FALSE) {
		NSLog(@"cannot get pdf infomation.");
		return;
	}

	
	//Generate Thumbnail image.
	//generate when need.(for launch speed up.)
	//[self generateThumbnailImage:100.0f];
	
	//Remove all image cache when debug.
#ifdef TARGET_IPHONE_SIMULATOR
	if (0==1) {
		[self removeAllImageCache];
	}
#endif
	
	//Show top page.
	[self drawPageWithNumber:currentPageNum];
	[self.view setNeedsDisplay];
	
#pragma mark (MenuBar and other)
	//Setup MenuBar.
	menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuView" bundle:[NSBundle mainBundle]];
	CGRect menuBarFrame = menuViewController.view.frame;	//Fit with self.view.
	menuBarFrame.size.width = self.view.frame.size.width;//Fit size only width.
	menuViewController.view.frame = menuBarFrame;
	[self.view addSubview:menuViewController.view];
	[self hideMenuBar];
	
	//Setup WebView.
	//generate when need.
	webViewController = nil;
	urlForWeb = [[NSMutableString alloc] init];
	
	//Setup Links.
	linksInCurrentPage = [[NSMutableArray alloc] init];
	[self renderPageLinkAtIndex:currentPageNum];
	
	// Setup for Movie play.
	[self parseMovieDefine];
	[self renderMovieLinkAtIndex:currentPageNum];
	
	// Setup for InPage ScrollView.
	
	// Setup for Popover ScrollView.
	[self parsePopoverScrollImageDefine];
	[self renderPopoverScrollImageLinkAtIndex:currentPageNum];
	
	// Setup TOC(Table Of Contents).
	[self parseTocDefine];
	tocViewController = [[TocViewController alloc] initWithNibName:@"TocView" bundle:[NSBundle mainBundle]];
	CGRect tocViewFrame = tocViewController.view.frame;	//Fit with self.view.
	tocViewFrame.size.width = self.view.frame.size.width;
	tocViewFrame.size.height = self.view.frame.size.height;
	tocViewController.view.frame = tocViewFrame;
	isShownTocView = FALSE;
	
	// Setup Thumbnail Image Toc View.
	
	// Setup Bookmark View.
	
#pragma mark (Read LastReadPage from UserDefault)
	int lastReadPage = [self getLatestReadPage];
	if (0 < lastReadPage) {
		[self switchToPage:lastReadPage];
	}
}


#pragma mark -
#pragma mark setup pdf infomation.
- (BOOL)setupPdfBasicInfo
{
	//Setup PDF filename.(chached in this class)
	NSString* csvFilePath = [[NSBundle mainBundle] pathForResource:@"pdfDefine" ofType:@"csv"];
	NSError* error;
	NSString* text = [NSString stringWithContentsOfFile:csvFilePath encoding:NSUTF8StringEncoding error:&error];
	NSArray* lines = [text componentsSeparatedByString:@"\n"];
	NSString* pdfFilename;
	if ([lines count] < 1) {
		NSLog(@"no PDF file specified.");
		pdfFilename = [NSString stringWithFormat:@"document.pdf"];
	} else {
		pdfFilename = [lines objectAtIndex:0];
	}
	pdfURL = [[NSBundle mainBundle] URLForResource:pdfFilename withExtension:nil];
	[pdfURL retain];	//Owned by this class.
	if (!pdfURL) {
		NSLog(@"PDF file not exist. filename=%@", pdfFilename);
		return FALSE;
	}
	//NSLog(@"pdfFilename=%@", pdfFilename);
	//NSLog(@"pdfURL=%@", [pdfURL standardizedURL]);
	
	//Open PDF file.
	CGPDFDocumentRef pdfDocument;
	pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
	if (!pdfDocument) {
		NSLog(@"PDF file cannot open. filename=%@", pdfFilename);
		return FALSE;
	}
	
	//Set max page number.
	maxPageNum = CGPDFDocumentGetNumberOfPages(pdfDocument);
	//NSLog(@"maxPageNum=%d", maxPageNum);
	
	//Set frame size from page1.
	CGPDFPageRef page1 = CGPDFDocumentGetPage(pdfDocument, 1);
	if (!page1) {
		NSLog(@"cannot get PDF Page.");
		return FALSE;
	}
	CGRect originalPageRect = CGPDFPageGetBoxRect(page1, kCGPDFMediaBox);
	pdfScale = self.view.frame.size.width / originalPageRect.size.width;
	//NSLog(@"self.view.frame=%@", NSStringFromCGRect(self.view.frame));
	//NSLog(@"page rect from page1=%@", NSStringFromCGRect(originalPageRect));
	//NSLog(@"pdfScale(by width)=%f (= %f / %f)", pdfScale, self.view.frame.size.width, originalPageRect.size.width);
	currentPdfScrollView.originalPageSize = originalPageRect.size;
	nextPdfScrollView.originalPageSize = originalPageRect.size;
	prevPdfScrollView.originalPageSize = originalPageRect.size;
	
	//Release PDFDocument.
	if (pdfDocument) {
		CGPDFDocumentRelease(pdfDocument);
	}
	
	return TRUE;
}

#pragma mark handle PDF infomation.
//IS_VERTICAL_PDF: 0=horizon(yokogaki), 1=vertical(tategaki).
- (BOOL)isVerticalWriting
{
#if defined(IS_VERTICAL_PDF) && IS_VERTICAL_PDF != 0
	return YES;	//tategaki.
#else
	return NO;	//yokogaki.
#endif
}

- (BOOL)isMultiContents
{
	return NO;	//False, single content.
}



#pragma mark -
#pragma mark draw pdf to screen.
- (NSString*)getPageFilenameFull:(int)pageNum {
	NSString* filename = [NSString stringWithFormat:@"%@%d", PAGE_FILE_PREFIX, pageNum];
	NSString* targetFilenameFull = [[[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:PAGE_FILE_EXTENSION];
	return targetFilenameFull;
}


#pragma mark -
/**
 *
 *note:pageNum is 1-start.
 *
 */
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum
{
	if (maxPageNum < pageNum) {
		NSLog(@"illigal page given. pageNum=%d, maxPageNum=%d", pageNum, maxPageNum);
		return nil;
	}
	
	//
	//[self preparePdfPageImageWithPageNum:pageNum];
	
	//Get image from file if exists.
	NSString* targetFilenameFull = [self getPageFilenameFull:pageNum];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:targetFilenameFull]) {
		UIImage* pdfImage = [[UIImage alloc] initWithContentsOfFile:targetFilenameFull];
		if (pdfImage) {
			return pdfImage;
		} else {
			NSLog(@"page exists but can not generate image. for page %d filename=%@", pageNum, targetFilenameFull);
			return nil;
		}
	} else {
		//NSLog(@"page file for page %d not exist. generate. filename=%@", pageNum, targetFilenameFull);
		//return [self generateImageWithPageNum:pageNum];
		ImageGenerator* ig = [[ImageGenerator alloc] init];
		[ig generateImageWithPageNum:pageNum fromUrl:pdfURL minWidth:CACHE_IMAGE_WIDTH_MIN];
		[ig release];
		
		UIImage* pdfImage = [[UIImage alloc] initWithContentsOfFile:targetFilenameFull];
		if (pdfImage) {
			//Thumbnail image is generated ondemand.
			//[self generateThumbnailImageFromImage:pdfImage width:THUMBNAIL_WIDTH pageNumForSave:pageNum];
			
			return pdfImage;
		} else {
			NSLog(@"page generate but can not open image from file. for page %d filename=%@", pageNum, targetFilenameFull);
			return nil;
		}
	}
	
	[targetFilenameFull release];
	return nil;
}

//Remove image cache.
- (void)removeAllImageCache
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError* error;
	NSString* targetFilenameFull;
		int i;
	for (i = 1; i < maxPageNum; i = i + 1) {
		targetFilenameFull = [self getPageFilenameFull:i];
		[fileManager removeItemAtPath:targetFilenameFull error:&error];
	}
}


#pragma mark -
- (void)drawPageWithNumber:(int)newPageNum
{
	//LOG_CURRENT_METHOD;
	
	//Check currentPageNum.
	if (newPageNum <= 0) {
		newPageNum = 1;	//1-start.
	}
	if (maxPageNum < newPageNum) {
		newPageNum = maxPageNum;
	}
	
	
	//
	//[self preparePdfPageImageWithPageNum:newPageNum];
	
	//Draw current rough imageView.
	[currentPdfScrollView setupWithPageNum:newPageNum];
	//bring currentImageView to Front.
	[self.view bringSubviewToFront:currentPdfScrollView];
	//[currentPdfScrollView layoutIfNeeded];
	[currentPdfScrollView setNeedsLayout];
	[currentPdfScrollView setNeedsDisplay];
	
	//Draw next imageView.
	if (currentPageNum + 1 <= maxPageNum) {
		[nextPdfScrollView setupWithPageNum:newPageNum + 1];
	}
	
	//Draw prev imageView.
	if (1 <= currentPageNum - 1) {
		[prevPdfScrollView setupWithPageNum:newPageNum - 1];
	}
}


#pragma mark -
#pragma mark Move Page.
- (void)gotoNextPage
{
	//LOG_CURRENT_METHOD;
	if (currentPageNum == maxPageNum) {
		return;
	}
	
	//Erase child view(like LINK button).
	[currentPdfScrollView cleanupSubviews];
	
	//Reset zoomScale
	[currentPdfScrollView resetScrollView];
	
	// Set animation
	CATransition* animation1 = [CATransition animation];
	[animation1 setDelegate:self];
	[animation1 setDuration:PAGE_ANIMATION_DURATION_NEXT];
	[animation1 setTimingFunction:UIViewAnimationCurveEaseInOut];
	[animation1 setType:kCATransitionPush];
	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	//UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
	if ([self isVerticalWriting]) {//tategaki.
		switch (interfaceOrientation) {
			case UIInterfaceOrientationPortrait:
				[animation1 setSubtype:kCATransitionFromLeft];
				//NSLog(@"kCATransitionFromLeft");
				break;
			case UIInterfaceOrientationPortraitUpsideDown:
				[animation1 setSubtype:kCATransitionFromRight];
				//NSLog(@"kCATransitionFromRight");
				break;
			case UIInterfaceOrientationLandscapeLeft:
				[animation1 setSubtype:kCATransitionFromBottom];
				//NSLog(@"kCATransitionFromBottom(LandscapeLeft)");
				break;
			case UIInterfaceOrientationLandscapeRight:
				[animation1 setSubtype:kCATransitionFromTop];
				//NSLog(@"kCATransitionFromTop");
				break;
			default://Unknown
				[animation1 setSubtype:kCATransitionFromRight];
				break;
		}
	}else{
		switch (interfaceOrientation) {
			case UIInterfaceOrientationPortrait:
				[animation1 setSubtype:kCATransitionFromRight];
				//NSLog(@"kCATransitionFromRight");
				break;
			case UIInterfaceOrientationPortraitUpsideDown:
				[animation1 setSubtype:kCATransitionFromLeft];
				//NSLog(@"kCATransitionFromLeft");
				break;
			case UIInterfaceOrientationLandscapeLeft:
				[animation1 setSubtype:kCATransitionFromBottom];
				//NSLog(@"kCATransitionFromBottom(LandscapeLeft)");
				break;
			case UIInterfaceOrientationLandscapeRight:
				[animation1 setSubtype:kCATransitionFromTop];
				//NSLog(@"kCATransitionFromTop");
				break;
			default://Unknown
				[animation1 setSubtype:kCATransitionFromRight];
				break;
		}
	}
	[animation1 setValue:MY_ANIMATION_KIND_PAGE_FROM_RIGHT forKey:MY_ANIMATION_KIND];
	[[self.view layer] addAnimation:animation1 forKey:@"animation_to_NextPage"];
	
	
	// Move NextImageView to Front.
	[self.view bringSubviewToFront:nextPdfScrollView];
	[nextPdfScrollView scrollViewDidEndZooming:nextPdfScrollView withView:nil atScale:0.0f];
	[nextPdfScrollView setNeedsLayout];
	[nextPdfScrollView setNeedsDisplay];
	
	// Shift view pointer.
	// tmp <- prev <- current <- next <- tmp.
	//(before)
	//(after)
	MyPdfScrollView* tmpPointer;
	tmpPointer			= prevPdfScrollView;
	prevPdfScrollView	= currentPdfScrollView;
	currentPdfScrollView= nextPdfScrollView;
	nextPdfScrollView	= tmpPointer;
	tmpPointer		= nil;
	
	//
	currentPageNum = currentPageNum + 1;
	if (maxPageNum < currentPageNum) {
		currentPageNum = maxPageNum;
	}
	//NSLog(@"new page number=%d", currentPageNum);
	
	// Load (new)nextImage.
	if (currentPageNum + 1 <= maxPageNum) {
		[nextPdfScrollView setupWithPageNum:currentPageNum + 1];
	}
	
	//
	//[self getPdfDictionaryWithPageNum:currentPageNum];
	[self renderPageLinkAtIndex:currentPageNum];
	[self renderMovieLinkAtIndex:currentPageNum];
	//[self renderPageJumpLinkAtIndex:currentPageNum];
	//[self renderInPageScrollViewAtIndex:currentPageNum];
	[self renderPopoverScrollImageLinkAtIndex:currentPageNum];
	//[self playSoundAtIndex:currentPageNum];	//play sound for new page.
	
	/*
	 NSLog(@"prev-subviews=%d, curr-subview=%d, next-subview=%d",
	 [prevPdfScrollView.subviews count],
	 [currentPdfScrollView.subviews count],
	 [nextPdfScrollView.subviews count]
	 );
	 */
	
	//Save LastReadPage.
	[self setLatestReadPage:currentPageNum];
}

- (void)gotoPrevPage
{
	//LOG_CURRENT_METHOD;
	if (currentPageNum == 1) {
		return;
	}
	
	//Erase child view(like LINK button).
	[currentPdfScrollView cleanupSubviews];
	//NSLog(@"(old)prevPdfScrollView subviews = %d", [prevPdfScrollView.subviews count]);
	
	//Reset zoomScale
	[currentPdfScrollView resetScrollView];
	
	if (currentPageNum <= 1) {
		return;
	}
	
	// Set animation
	CATransition* animation1 = [CATransition animation];
	[animation1 setDelegate:self];
	[animation1 setDuration:PAGE_ANIMATION_DURATION_PREV];
	[animation1 setTimingFunction:UIViewAnimationCurveEaseInOut];
	[animation1 setType:kCATransitionPush];
	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	//UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
	if ([self isVerticalWriting]) {
		switch (interfaceOrientation) {
			case UIInterfaceOrientationPortrait:
				[animation1 setSubtype:kCATransitionFromRight];
				//NSLog(@"kCATransitionFromRight");
				break;
			case UIInterfaceOrientationPortraitUpsideDown:
				[animation1 setSubtype:kCATransitionFromLeft];
				//NSLog(@"kCATransitionFromLeft");
				break;
			case UIInterfaceOrientationLandscapeLeft:
				[animation1 setSubtype:kCATransitionFromTop];
				//NSLog(@"kCATransitionFromTop(LandscapeLeft)");
				break;
			case UIInterfaceOrientationLandscapeRight:
				[animation1 setSubtype:kCATransitionFromBottom];
				//NSLog(@"kCATransitionFromBottom");
				break;
			default://Unknown
				[animation1 setSubtype:kCATransitionFromLeft];
				break;
		}
	} else {
		switch (interfaceOrientation) {
			case UIInterfaceOrientationPortrait:
				[animation1 setSubtype:kCATransitionFromLeft];
				//NSLog(@"kCATransitionFromLeft");
				break;
			case UIInterfaceOrientationPortraitUpsideDown:
				[animation1 setSubtype:kCATransitionFromRight];
				//NSLog(@"kCATransitionFromRight");
				break;
			case UIInterfaceOrientationLandscapeLeft:
				[animation1 setSubtype:kCATransitionFromTop];
				//NSLog(@"kCATransitionFromTop(LandscapeLeft)");
				break;
			case UIInterfaceOrientationLandscapeRight:
				[animation1 setSubtype:kCATransitionFromBottom];
				//NSLog(@"kCATransitionFromBottom");
				break;
			default://Unknown
				[animation1 setSubtype:kCATransitionFromLeft];
				break;
		}
	}
	[animation1 setValue:MY_ANIMATION_KIND_PAGE_FROM_LEFT forKey:MY_ANIMATION_KIND];
	[[self.view layer] addAnimation:animation1 forKey:@"animation_to_PrevPage"];
	
	
	// Move PrevImageView to Front.
	[self.view bringSubviewToFront:prevPdfScrollView];
	[prevPdfScrollView scrollViewDidEndZooming:prevPdfScrollView withView:nil atScale:0.0f];
	[prevPdfScrollView setNeedsLayout];
	[prevPdfScrollView setNeedsDisplay];
	
	// Shift view pointer.
	// tmp -> prev -> current -> next -> tmp.
	//(before)
	//(after)
	MyPdfScrollView* tmpPointer;
	tmpPointer			= nextPdfScrollView;
	nextPdfScrollView	= currentPdfScrollView;
	currentPdfScrollView= prevPdfScrollView;
	prevPdfScrollView	= tmpPointer;
	tmpPointer			= nil;
	
	//
	currentPageNum = currentPageNum - 1;
	if (currentPageNum < 1) {
		currentPageNum = 1;
	}
	//NSLog(@"new page number=%d", currentPageNum);
	
	// Load (new)prevImage.
	if (1 < currentPageNum) {
		[prevPdfScrollView setupWithPageNum:currentPageNum - 1];
	}
	
	//NSLog(@"(new)currentPdfScrollView subviews = %d", [currentPdfScrollView.subviews count]);
	//
	[self renderPageLinkAtIndex:currentPageNum];
	[self renderMovieLinkAtIndex:currentPageNum];
	//[self renderPageJumpLinkAtIndex:currentPageNum];
	//[self renderInPageScrollViewAtIndex:currentPageNum];
	[self renderPopoverScrollImageLinkAtIndex:currentPageNum];
	//[self playSoundAtIndex:currentPageNum];	//play sound for new page.

	//Save LastReadPage.
	[self setLatestReadPage:currentPageNum];
}

- (void)switchToPage:(int)newPageNum
{
	//Check page range.
	if (newPageNum < 1 || maxPageNum < newPageNum) {
		return;
	}
	
	currentPageNum = newPageNum;
	
	//Erase child view(like LINK button).
    for (UIView *v in currentPdfScrollView.subviews) {
        [v removeFromSuperview];
    }
	
	// Load (new)currentImage.
	[currentPdfScrollView setupWithPageNum:currentPageNum];
	[currentPdfScrollView scrollViewDidEndZooming:currentPdfScrollView withView:nil atScale:0.0f];
	
	// Load (new)nextImage.
	if (currentPageNum + 1 <= maxPageNum) {
		[nextPdfScrollView setupWithPageNum:currentPageNum + 1];
	}
	
	// Load (new)prevImage.
	if (1 < currentPageNum) {
		[prevPdfScrollView setupWithPageNum:currentPageNum - 1];
	}
	
	//Reset zoomScale
	[prevPdfScrollView resetScrollView];
	[currentPdfScrollView resetScrollView];
	[nextPdfScrollView resetScrollView];
	
	//Hide TOCView.
	[self.tocViewController.view removeFromSuperview];
	
	//Draw link to URL, Movie.
	[self renderPageLinkAtIndex:currentPageNum];
	[self renderMovieLinkAtIndex:currentPageNum];
	//[self renderPageJumpLinkAtIndex:currentPageNum];
	//[self renderInPageScrollViewAtIndex:currentPageNum];
	[self renderPopoverScrollImageLinkAtIndex:currentPageNum];
	//[self playSoundAtIndex:currentPageNum];	//play sound for new page.
	
	// Set animation
	CATransition* animation1 = [CATransition animation];
	[animation1 setDelegate:self];
	[animation1 setDuration:0.2f];
	[animation1 setTimingFunction:UIViewAnimationCurveEaseInOut];
	[animation1 setType:kCATransitionFade];
	[animation1 setValue:MY_ANIMATION_KIND_FADE forKey:MY_ANIMATION_KIND];
	[[self.view layer] addAnimation:animation1 forKey:@"animation_to_SpecifyPage"];
	
	
	// Move CurrentImageView to Front.
	[self.view bringSubviewToFront:currentPdfScrollView];
	
	//Save LastReadPage.
	[self setLatestReadPage:currentPageNum];
}

- (void)switchNextImageWithAnimationType:(NSString*)animationType
{ LOG_CURRENT_METHOD; }


#pragma mark -
#pragma mark handle Gesture.
- (void)handleTap:(UITapGestureRecognizer*)gestureRecognizer
{
	CGPoint touchedPoint = [gestureRecognizer locationInView:currentPdfScrollView.pageImageView];
	//CGPoint touchedPointNormalize = CGPointMake(touchedPoint.x / currentPdfScrollView.scaleForDraw,
	//											touchedPoint.y / currentPdfScrollView.scaleForDraw);
	CGPoint touchedPointInOriginalPdf;
	/*
	if (currentPdfScrollView.originalPageWidth < self.view.frame.size.width) {
		touchedPointInOriginalPdf = CGPointMake(touchedPoint.x / pdfScale,
												touchedPoint.y / pdfScale);
		//for "Retina" display.
		CGFloat myscale;
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			myscale = [[UIScreen mainScreen] scale];
		} else {
			myscale = 2.0f;
		}
		touchedPointInOriginalPdf = CGPointMake(touchedPointInOriginalPdf.x / myscale,
												touchedPointInOriginalPdf.y / myscale);
	} else {
		touchedPointInOriginalPdf = [gestureRecognizer locationInView:currentPdfScrollView.pageImageView];
	}

	//CGPoint touchedPointInScreen = [gestureRecognizer locationInView:self.view];
	//NSLog(@"touched point in currentPdfScrollView.pageImageView=%@", NSStringFromCGPoint(touchedPoint));
	//NSLog(@"touched point in Original PDF = %@", NSStringFromCGPoint(touchedPointInOriginalPdf));
	//NSLog(@"touched point in Screen = %@", NSStringFromCGPoint(touchedPointInScreen));
	//NSLog(@"currentPdfScrollView.scaleForDraw=%f", currentPdfScrollView.scaleForDraw);
	//NSLog(@"pdfScale=%f", pdfScale);
	//NSLog(@"location in original page =%f, %f", currentPdfScrollView.originalPageWidth, currentPdfScrollView.originalPageHeight);
	*/
	
	CGFloat scaleToFitWidth;
	if (currentPdfScrollView.originalPageWidth < CACHE_IMAGE_WIDTH_MIN) {
		scaleToFitWidth = CACHE_IMAGE_WIDTH_MIN / currentPdfScrollView.originalPageWidth;
	} else {
		scaleToFitWidth = 1.0f;
	}
	touchedPointInOriginalPdf = CGPointMake(touchedPoint.x / scaleToFitWidth,
											touchedPoint.y / scaleToFitWidth);
	//NSLog(@"touched point in currentPdfScrollView.pageImageView=%@", NSStringFromCGPoint(touchedPoint));
	//NSLog(@"touched point in Original PDF = %@", NSStringFromCGPoint(touchedPointInOriginalPdf));	
	
	
	// Check if TocView, ThumbnailView, BookmarkVew shown, then hide it.
	if (isShownTocView) {
		[self hideTocView];
		return;
	}
	
	// Compare with URL Link in page.
	//LOG_CURRENT_METHOD;
	//NSLog(@"linksInCurrentPage=%@", [linksInCurrentPage description]);
	for (NSMutableDictionary* tmpDict in linksInCurrentPage) {
		if (!tmpDict) {
			continue;
		}
		//NSLog(@"tmpDict=%@", [tmpDict description]);
		NSValue* val = [tmpDict objectForKey:LINK_DICT_KEY_RECT];
		CGRect r = [val CGRectValue];
		//NSLog(@"frame with URL Link=%@", NSStringFromCGRect(r));
		//NSLog(@"touchedPoint=%@", NSStringFromCGPoint(touchedPoint));
		//NSLog(@"touchedPointInOriginalPdf=%@", NSStringFromCGPoint(touchedPointInOriginalPdf));
		//NSLog(@"touched point in Screen = %@", NSStringFromCGPoint(touchedPointInScreen));
		
		if (CGRectContainsPoint(r, touchedPointInOriginalPdf)) {
			NSString* urlStr = [tmpDict objectForKey:LINK_DICT_KEY_URL];
			//NSLog(@"URL link touched. url=%@", urlStr);
			
			//open with another view.
			//[self showWebView:urlStr];
			//open with Safari.
			//[self showWebWithSafari:urlStr];
			//open with anotherView/Safari(show selecter).
			[self showWebViewSelector:urlStr];
			
			//no-continue.
			return;
		}
	}
	
	// Compare with Movie Link in page.
	for (NSMutableDictionary* movieInfo in movieDefine) {
		int targetPageNum = [[movieInfo valueForKey:MD_PAGE_NUMBER] intValue];
		if (targetPageNum == currentPageNum) {
			CGRect rect;
			rect.origin.x	= [[movieInfo valueForKey:MD_AREA_X] floatValue];
			rect.origin.y	= [[movieInfo valueForKey:MD_AREA_Y] floatValue];
			rect.size.width	= [[movieInfo valueForKey:MD_AREA_WIDTH] floatValue];
			rect.size.height= [[movieInfo valueForKey:MD_AREA_HEIGHT] floatValue];
			//NSLog(@"frame with movie info=%@", NSStringFromCGRect(rect));
			//NSLog(@"touchedPoint=%@", NSStringFromCGPoint(touchedPoint));
			//NSLog(@"touchedPointInOriginalPdf=%@", NSStringFromCGPoint(touchedPointInOriginalPdf));
			
			if (CGRectContainsPoint(rect, touchedPointInOriginalPdf)) {
				NSString* filename = [movieInfo valueForKey:MD_MOVIE_FILENAME];
				//NSLog(@"movie link touched. filename=%@", filename);
				
				//open with another view.
				[self showMoviePlayer:filename];
				
				//no-continue.
				return;
			}
		}
	}
	
	// Compare with Popover Scroll Image Link in page.
	for (NSMutableDictionary* popoverScrollImageInfo in popoverScrollImageDefine) {
		int targetPageNum = [[popoverScrollImageInfo valueForKey:MD_PAGE_NUMBER] intValue];
		if (targetPageNum == currentPageNum) {
			CGRect rect;
			rect.origin.x	= [[popoverScrollImageInfo valueForKey:MD_AREA_X] floatValue];
			rect.origin.y	= [[popoverScrollImageInfo valueForKey:MD_AREA_Y] floatValue];
			rect.size.width	= [[popoverScrollImageInfo valueForKey:MD_AREA_WIDTH] floatValue];
			rect.size.height= [[popoverScrollImageInfo valueForKey:MD_AREA_HEIGHT] floatValue];
			//NSLog(@"frame with popover Scroll Image Info info=%@", NSStringFromCGRect(rect));
			//NSLog(@"touchedPoint=%@", NSStringFromCGPoint(touchedPoint));
			//NSLog(@"touchedPointInOriginalPdf=%@", NSStringFromCGPoint(touchedPointInOriginalPdf));
			
			if (CGRectContainsPoint(rect, touchedPointInOriginalPdf)) {
				NSString* filename = [popoverScrollImageInfo valueForKey:MD_MOVIE_FILENAME];
				//NSLog(@"popoverScrollImageInfo link touched. filename=%@", filename);
				
				//open with another view.
				[self showPopoverScrollImagePlayer:filename];
				
				//no-continue.
				return;
			}
		}
	}

	// Compare with in left_area, in right_area.
	CGRect leftTapArea, rightTapArea, bottomTapArea, topTapArea;
	CGFloat baseWidthForParentView, baseHeightForParentView;
	//baseWidth  = currentPdfScrollView.originalPageWidth;
	//baseHeight = currentPdfScrollView.originalPageHeight;
	baseWidthForParentView = self.view.frame.size.width;
	baseHeightForParentView = self.view.frame.size.height;
	
	leftTapArea = CGRectMake(0.0f,
							 baseHeightForParentView * 0.15f,
							 baseWidthForParentView  * 0.40f,
							 baseHeightForParentView * 1.0f);
	rightTapArea = CGRectMake(baseWidthForParentView * 0.60f,
							  baseHeightForParentView* 0.15f,
							  baseWidthForParentView  * 0.40f,
							  baseHeightForParentView * 1.0f);
	topTapArea = CGRectMake(0.0f,
							0.0f,
							baseWidthForParentView  * 1.00f,
							baseHeightForParentView * 0.15f);
	bottomTapArea = CGRectMake(0.0f,
							   0.0f,
							   0.0f,
							   0.0f);
	//NSLog(@"leftTapArea=%@", NSStringFromCGRect(leftTapArea));
	//NSLog(@"rightTapArea=%@", NSStringFromCGRect(rightTapArea));
	//NSLog(@"topTapArea=%@", NSStringFromCGRect(topTapArea));
	//NSLog(@"bottomTapArea=%@", NSStringFromCGRect(bottomTapArea));
	
	CGPoint touchedPointInParentView = [gestureRecognizer locationInView:self.view];
	//NSLog(@"location in parent view = %@", NSStringFromCGPoint(touchedPointInParentView));
	if (CGRectContainsPoint(leftTapArea, touchedPointInParentView)) {
		[self handleTapInLeftArea:gestureRecognizer];
	} else if (CGRectContainsPoint(rightTapArea, touchedPointInParentView)) {
		[self handleTapInRightArea:gestureRecognizer];
	} else if (CGRectContainsPoint(topTapArea, touchedPointInParentView)) {
		[self handleTapInTopArea:gestureRecognizer];
	} else if (CGRectContainsPoint(bottomTapArea, touchedPointInParentView)) {
		[self handleTapInBottomArea:gestureRecognizer];
	} else {
		[self hideMenuBar];
	}
}

//- (void)handleTapInScrollView:(UIGestureRecognizer*)sender
//{ LOG_CURRENT_METHOD; }
- (void)handleTapInLeftArea:(UIGestureRecognizer*)gestureRecognizer;
{
	[self hideMenuBar];
	if ([self isVerticalWriting]) {
		[self gotoNextPage];
	} else {
		[self gotoPrevPage];
	}
	
}
- (void)handleTapInRightArea:(UIGestureRecognizer*)gestureRecognizer
{
	[self hideMenuBar];
	if ([self isVerticalWriting]) {
		[self gotoPrevPage];
	} else {
		[self gotoNextPage];
	}
}
- (void)handleTapInTopArea:(UIGestureRecognizer*)gestureRecognizer
{
	[self toggleMenuBar];
}
- (void)handleTapInBottomArea:(UIGestureRecognizer*)gestureRecognizer
{
	//[self toggleMenuBar];
	//Do nothing for iPhone/iPod touch. User often touch bottom for page change.
}

- (void)handleTapInScrollView:(UIGestureRecognizer*)sender
{
	LOG_CURRENT_METHOD;
}

- (void)handleSwipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
	//Switch to next/prev page.
	if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
		//left to right, goto next.
		[self hideMenuBar];
		if ([self isVerticalWriting]) {
			[self gotoNextPage];
		} else {
			[self gotoPrevPage];
		}
	} else {
		//right to left, goto prev.
		[self hideMenuBar];
		if ([self isVerticalWriting]) {
			[self gotoPrevPage];
		} else {
			[self gotoNextPage];
		}
	}		
}

- (void)handlePan:(UIPanGestureRecognizer*)sender
{
	//LOG_CURRENT_METHOD;
	if (sender.state == UIGestureRecognizerStateBegan) {
		LOG_CURRENT_LINE;
		panStartPoint = [sender translationInView:sender.view];
		panTargetView = sender.view;
	}
	/*
	 if (sender.state == UIGestureRecognizerStateChanged) {
	 //LOG_CURRENT_LINE;
	 panEndPoint = [sender translationInView:sender.view];
	 //changed another view.
	 if (panTargetView != sender.view) {
	 panStartPoint = panEndPoint;
	 }
	 }
	 */
	if (sender.state == UIGestureRecognizerStateEnded) {
		LOG_CURRENT_LINE;
		panEndPoint = [sender translationInView:sender.view];
		
		//judge with distance.
		/*
		 CGFloat dx = panEndPoint.x - panStartPoint.x;
		 CGFloat dy = panEndPoint.y - panStartPoint.y;
		 CGFloat distance = sqrt(dx*dx + dy*dy );
		 */
		CGFloat dx = panEndPoint.x - panStartPoint.x;
		CGFloat distance = sqrt(dx*dx);
		NSLog(@"distance=%f", distance);
		if (PAN_DISTANCE_MINIMUM < distance) {
			if (dx < 0) {
				[self gotoNextPage];
				[sender cancelsTouchesInView];
				panStartPoint = panEndPoint;
				//Disable pan Gesture.
				//[self disableAllPanGesture];
			} else {
				[self gotoPrevPage];
				[sender cancelsTouchesInView];
				panStartPoint = panEndPoint;
				//Disable pan Gesture.
				//[self disableAllPanGesture];
			}
		}
		
		//[sender cancelsTouchesInView];
		panStartPoint = panEndPoint;
		//Enable pan Gesture.
		[self enableAllPanGesture];
	}
	if (sender.state == UIGestureRecognizerStateCancelled) {
		LOG_CURRENT_LINE;
		panTargetView = nil;
		//Enable pan Gesture.
		[self enableAllPanGesture];
	}
}

- (void)enableAllPanGesture {
	panRecognizer1.enabled = TRUE;
	panRecognizer2.enabled = TRUE;
	panRecognizer3.enabled = TRUE;
}
- (void)disableAllPanGesture {
	panRecognizer1.enabled = FALSE;
	panRecognizer2.enabled = FALSE;
	panRecognizer3.enabled = FALSE;
}


#pragma mark -
#pragma mark Treat URL Link.
/**
 * @see:http://stackoverflow.com/questions/4080373/get-pdf-hyperlinks-on-ios-with-quartz
 */
- (void) renderPageLinkAtIndex:(NSUInteger)index
{
	//LOG_CURRENT_METHOD;
	
	//Remove old view for URL_Link.
	[linksInCurrentPage removeAllObjects];
	
	id pool = [ [ NSAutoreleasePool alloc] init];
	
	//get pdf document.
	CGPDFDocumentRef pdfDocument;
	pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
	if (!pdfDocument) {
		LOG_CURRENT_LINE;
		NSLog(@"cannot open PDF document.");
		[pool release];
		return;
	}
	
	//get target page in PDF.
    CGPDFPageRef pageAd = CGPDFDocumentGetPage(pdfDocument, index);
	if (!pageAd) {
		LOG_CURRENT_LINE;
		NSLog(@"CGPDFPageRef is nil.");
		//Release PDFDocument.
		if (pdfDocument) {
			CGPDFDocumentRelease(pdfDocument);
			pdfDocument = nil;
		}
		[pool release];
		return;
	}
	
    CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(pageAd);
	if (!pageDictionary) {
		LOG_CURRENT_LINE;
		NSLog(@"CGPDFDictionaryRef is nil.");
		//Release PDFDocument.
		if (pdfDocument) {
			CGPDFDocumentRelease(pdfDocument);
			pdfDocument = nil;
		}
		[pool release];
		return;
	}
	
    CGPDFArrayRef outputArray = nil;
    if(!CGPDFDictionaryGetArray(pageDictionary, "Annots", &outputArray)) {
		//LOG_CURRENT_LINE;
		//Release PDFDocument.
		if (pdfDocument) {
			CGPDFDocumentRelease(pdfDocument);
			pdfDocument = nil;
		}
		//NSLog(@"Annots not found");
		[pool release];
        return;
    }
	
    int arrayCount = CGPDFArrayGetCount( outputArray );
    if(!arrayCount) {
        //continue;
    }
	
    for( int j = 0; j < arrayCount; ++j ) {
        CGPDFObjectRef aDictObj;
        if(!CGPDFArrayGetObject(outputArray, j, &aDictObj)) {
			[pool release];
            return;
        }
		
        CGPDFDictionaryRef annotDict = nil;
        if(!CGPDFObjectGetValue(aDictObj, kCGPDFObjectTypeDictionary, &annotDict)) {
			[pool release];
            return;
        }
		
        CGPDFDictionaryRef aDict = nil;
        if(!CGPDFDictionaryGetDictionary(annotDict, "A", &aDict)) {
			[pool release];
            return;
        }
		
        CGPDFStringRef uriStringRef = nil;
        if(!CGPDFDictionaryGetString(aDict, "URI", &uriStringRef)) {
			[pool release];
            return;
        }
		
        CGPDFArrayRef rectArray = nil;
        if(!CGPDFDictionaryGetArray(annotDict, "Rect", &rectArray)) {
			[pool release];
            return;
        }
		
        int arrayCount = CGPDFArrayGetCount( rectArray );
        CGPDFReal coords[4];
        for( int k = 0; k < arrayCount; ++k ) {
            CGPDFObjectRef rectObj;
            if(!CGPDFArrayGetObject(rectArray, k, &rectObj)) {
				[pool release];
                return;
            }
			
            CGPDFReal coord;
            if(!CGPDFObjectGetValue(rectObj, kCGPDFObjectTypeReal, &coord)) {
				[pool release];
                return;
            }
			
            coords[k] = coord;
        }               
		
		CGFloat x1 = coords[0];
		CGFloat y1 = coords[1];
		CGFloat x2 = coords[2];
		CGFloat y2 = coords[3];
		
		//Treat PageRotate in pdf(exchange width,height)
        CGPDFInteger pageRotateDegree = 0;
        CGPDFDictionaryGetInteger( pageDictionary, "Rotate", &pageRotateDegree ); 
		//NSLog(@"pageRotateDegree=%d", pageRotateDegree);
		if( pageRotateDegree == 90 || pageRotateDegree == 270 ) {
			//exchange x2 <=> y2.
			CGFloat wr;
			wr = x2;
			x2 = y2;
			y2 = wr;
			wr = 0;
        }
		
		//keep x1 < x2, y1 < y2.
		if (x2 < x1) {
			//exchange x1, x2. tmp<-x1<-x2<-tmp
			CGFloat fx;
			fx = x1;
			x1 = x2;
			x2 = fx;
			fx = 0.0f;
		}
		if (y2 < y1) {
			//exchange y1, y2. tmp<-y1<-y2<-tmp
			CGFloat fy;
			fy = y1;
			y1 = y2;
			y2 = fy;
			fy = 0.0f;
		}
		//NSLog(@"original link position= (x1,y1)-(x2,y2)=(%f, %f) - (%f, %f)", x1, y1, x2, y2);
		
		//Generate frame in original pdf.
		CGRect linkRectInOriginalPdf;
		linkRectInOriginalPdf = CGRectMake(x1,
										   currentPdfScrollView.originalPageHeight - y2,	//does not "y1".
										   fabsf(x2 - x1),
										   fabsf(y2 - y1));
		
		//NSLog(@"scaleForDraw=%f", currentPdfScrollView.scaleForDraw);
		//NSLog(@"linkRect   =%@", NSStringFromCGRect(linkRect));
		//NSLog(@"linkRectInOriginalPdf   =%@", NSStringFromCGRect(linkRectInOriginalPdf));
		//NSLog(@"pdfScale   =%f", pdfScale);
		//NSLog(@"currentPdfScrollView.originalPage Size={%1.0f, %1.0f}",
		//	  currentPdfScrollView.originalPageWidth,
		//	  currentPdfScrollView.originalPageHeight);
		//NSLog(@"originalPageRect.size=%@", NSStringFromCGSize(originalPageRect.size));
		//NSLog(@"self.view.frame.size=%@", NSStringFromCGSize(self.view.frame.size));
		
		//Add subView.
		UIView* areaView = [[UIView alloc] initWithFrame:CGRectZero];
#if TARGET_IPHONE_SIMULATOR
		//Only show on Simulator.
		[areaView setBackgroundColor:[UIColor blueColor]];
		[areaView setAlpha:0.2f];
#else
		[areaView setAlpha:0.0f];
#endif
		[currentPdfScrollView addScalableSubview:areaView withPdfBasedFrame:linkRectInOriginalPdf];
		
		
		//Add link infomation for touch.
        char *uriString = (char *)CGPDFStringGetBytePtr(uriStringRef);
        NSString *uri = [NSString stringWithCString:uriString encoding:NSUTF8StringEncoding];
		NSURL *url = [NSURL URLWithString:uri];
		//NSLog(@"URL=%@", url);
		NSMutableDictionary* tmpDict = [[[NSMutableDictionary alloc] init] autorelease];
		[tmpDict setValue:[url description] forKey:LINK_DICT_KEY_URL];
		[tmpDict setValue:[NSValue valueWithCGRect:linkRectInOriginalPdf] forKey:LINK_DICT_KEY_RECT];
		[linksInCurrentPage addObject:tmpDict];
		
		
		
		/**
		 *		From array to cgPoint variable.
		 */		
		//NSValue *val = [points objectAtIndex:0];
		//CGPoint p = [val CGPointValue];
	}
	//LOG_CURRENT_METHOD;
	//NSLog(@"linksInCurrentPage=%@", [linksInCurrentPage description]);
	/*
	 if (!pageAd) {
	 CGPDFPageRelease(pageAd);
	 pageAd = nil;
	 }
	 */
	
	//Release PDFDocument.
	if (pdfDocument) {
		CGPDFDocumentRelease(pdfDocument);
		pdfDocument = nil;
	}
	[pool release];
}


#pragma mark -
#pragma mark Treat Movie.
//Parse Movie Define.
- (void)parseMovieDefine
{
	movieDefine = [[NSMutableArray alloc] init];
	
	//parse csv file.
	NSString* targetFilename = @"movieDefine";
	NSArray* lines;
	//if ([self isMultiContents] == TRUE) {
	//	lines = [FileUtility parseDefineCsv:targetFilename contentId:currentContentId];
	//} else {
		lines = [FileUtility parseDefineCsv:targetFilename];
	//}
	
	//parse each line.
	NSMutableDictionary* tmpDict;
	for (NSString* line in lines) {
		NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
		if ([tmpCsvArray count] < 6) {
			NSLog(@"illigal CSV data. item count=%d, line=%@", [tmpCsvArray count], line);
			continue;	//Skip illigal line.
		}
		
		tmpDict = [[NSMutableDictionary alloc] init];
		//Page Number.
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:0] intValue]] forKey:MD_PAGE_NUMBER];
		//Position.
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:1] intValue]] forKey:MD_AREA_X];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:2] intValue]] forKey:MD_AREA_Y];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:3] intValue]] forKey:MD_AREA_WIDTH];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:4] intValue]] forKey:MD_AREA_HEIGHT];
		//Filename.
		NSString* tmpStr = [tmpCsvArray objectAtIndex:5];
		NSString* tmpStrFormatted = [self formatStringWithAlphaNumeric:tmpStr];
		[tmpDict setValue:tmpStrFormatted forKey:MD_MOVIE_FILENAME];
		
		//Check page range.
		if (maxPageNum < [[tmpDict objectForKey:MD_PAGE_NUMBER] intValue]) {
			continue;	//skip to next object. not add to define.
		}
		
		//Add to movie define.
		[movieDefine addObject:tmpDict];
	}
}

- (void) renderMovieLinkAtIndex:(NSUInteger)index
{
	for (NSMutableDictionary* movieInfo in movieDefine) {
		int targetPageNum = [[movieInfo valueForKey:MD_PAGE_NUMBER] intValue];
		if (targetPageNum == index) {
			CGRect linkRectInOriginalPdf;
			linkRectInOriginalPdf.origin.x	= [[movieInfo valueForKey:MD_AREA_X] floatValue];
			linkRectInOriginalPdf.origin.y	= [[movieInfo valueForKey:MD_AREA_Y] floatValue];
			linkRectInOriginalPdf.size.width	= [[movieInfo valueForKey:MD_AREA_WIDTH] floatValue];
			linkRectInOriginalPdf.size.height= [[movieInfo valueForKey:MD_AREA_HEIGHT] floatValue];
			//NSLog(@"linkRectInOriginalPdf for movie=%@", NSStringFromCGRect(linkRectInOriginalPdf));
			
			//NSString* filename = [movieInfo valueForKey:MD_MOVIE_FILENAME];
			
			//Show Movie link area with half-opaque.
			UIView* areaView = [[UIView alloc] initWithFrame:CGRectZero];
#if TARGET_IPHONE_SIMULATOR
			//Only show on Simulator.
			[areaView setBackgroundColor:[UIColor yellowColor]];
			[areaView setAlpha:0.2f];
#else
			[areaView setAlpha:0.0f];
#endif
			//LOG_CURRENT_METHOD;
			//NSLog(@"render movie link. rect=%f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
			//[currentPdfScrollView addSubview:areaView];
			[currentPdfScrollView addScalableSubview:areaView withPdfBasedFrame:linkRectInOriginalPdf];
		}
	}
}

- (void)showMoviePlayer:(NSString*)filename
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"filename=%@", filename);
	
	NSString* path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
	if (!path) {
		NSLog(@"illigal filename. filename=%@, bundle_resourceURL=%@", filename, [[NSBundle mainBundle] resourceURL]);
		NSLog(@"f = %@ %@", [filename stringByDeletingPathExtension], [filename pathExtension]);
		return;
	}
	NSURL* url;
	
	if ((url = [NSURL fileURLWithPath:path]) != nil) {
		MPMoviePlayerViewController* mpview;
		if ((mpview = [[MPMoviePlayerViewController alloc] initWithContentURL:url]) != nil) {
			[self presentMoviePlayerViewControllerAnimated:mpview];
			[mpview.moviePlayer play];
			[mpview release];
		}
	}
}

#pragma mark -
#pragma mark Treat InPage ScrollView.

#pragma mark -
#pragma mark Treat popover scroll image view.
- (void)parsePopoverScrollImageDefine
{
	popoverScrollImageDefine = [[NSMutableArray alloc] init];
	
	//parse csv file.
	NSString* targetFilename = @"popoverScrollImageDefine";
	NSArray* lines;
	//if ([self isMultiContents] == TRUE) {
	//	lines = [FileUtility parseDefineCsv:targetFilename contentId:currentContentId];
	//} else {
		lines = [FileUtility parseDefineCsv:targetFilename];
	//}
	
	//parse each line.
	NSMutableDictionary* tmpDict;
	for (NSString* line in lines) {
		NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
		if ([tmpCsvArray count] < 6) {
			NSLog(@"illigal CSV data. item count=%d, line=%@", [tmpCsvArray count], line);
			continue;	//Skip illigal line.
		}
		
		tmpDict = [[NSMutableDictionary alloc] init];
		//Page Number.
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:0] intValue]] forKey:MD_PAGE_NUMBER];
		//Position.
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:1] intValue]] forKey:MD_AREA_X];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:2] intValue]] forKey:MD_AREA_Y];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:3] intValue]] forKey:MD_AREA_WIDTH];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:4] intValue]] forKey:MD_AREA_HEIGHT];
		//Filename.
		NSString* tmpStr = [tmpCsvArray objectAtIndex:5];
		NSString* tmpStrFormatted = [self formatStringWithAlphaNumeric:tmpStr];
		[tmpDict setValue:tmpStrFormatted forKey:MD_MOVIE_FILENAME];
		
		//Check page range.
		if (maxPageNum < [[tmpDict objectForKey:MD_PAGE_NUMBER] intValue]) {
			continue;	//skip to next object. not add to define.
		}
		
		//Add to movie define.
		[popoverScrollImageDefine addObject:tmpDict];
	}
}

- (void) renderPopoverScrollImageLinkAtIndex:(NSUInteger)index
{
	for (NSMutableDictionary* popoverScrollImageInfo in popoverScrollImageDefine) {
		int targetPageNum = [[popoverScrollImageInfo valueForKey:MD_PAGE_NUMBER] intValue];
		if (targetPageNum == index) {
			CGRect linkRectInOriginalPdf;
			linkRectInOriginalPdf.origin.x	= [[popoverScrollImageInfo valueForKey:MD_AREA_X] floatValue];
			linkRectInOriginalPdf.origin.y	= [[popoverScrollImageInfo valueForKey:MD_AREA_Y] floatValue];
			linkRectInOriginalPdf.size.width	= [[popoverScrollImageInfo valueForKey:MD_AREA_WIDTH] floatValue];
			linkRectInOriginalPdf.size.height= [[popoverScrollImageInfo valueForKey:MD_AREA_HEIGHT] floatValue];
			//NSLog(@"linkRectInOriginalPdf for popoverScrollImageInfo=%@", NSStringFromCGRect(linkRectInOriginalPdf));
			
			//NSString* filename = [movieInfo valueForKey:MD_MOVIE_FILENAME];
			
			//Show PopoverScrollImage link area with half-opaque.
			UIView* areaView = [[UIView alloc] initWithFrame:CGRectZero];
#if TARGET_IPHONE_SIMULATOR
			//Only show on Simulator.
			[areaView setBackgroundColor:[UIColor orangeColor]];
			[areaView setAlpha:0.2f];
#else
			[areaView setAlpha:0.0f];
#endif
			//LOG_CURRENT_METHOD;
			//NSLog(@"render movie link. rect=%f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
			//[currentPdfScrollView addSubview:areaView];
			[currentPdfScrollView addScalableSubview:areaView withPdfBasedFrame:linkRectInOriginalPdf];
		}
	}
}

- (void)showPopoverScrollImagePlayer:(NSString*)filename
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"filename=%@", filename);
	CGRect rect;
	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (interfaceOrientation == UIInterfaceOrientationPortrait
		||
		interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		rect = self.view.frame;
	} else {
		rect = CGRectMake(self.view.frame.origin.x,
						  self.view.frame.origin.y,
						  self.view.frame.size.height,
						  self.view.frame.size.width);
	}
	
	
	PopoverScrollImageViewController* psivc;
	psivc = [[PopoverScrollImageViewController alloc] initWithImageFilename:filename frame:rect];
	//Save scrollView position, zoomScale.
	[psivc setParentScrollView:currentPdfScrollView
				  fromPosition:currentPdfScrollView.contentOffset
				 fromZoomScale:currentPdfScrollView.zoomScale];
	
	//
	//[currentPdfScrollView setContentOffset:CGPointZero];
	[currentPdfScrollView setZoomScale:currentPdfScrollView.minimumZoomScale];
	[currentPdfScrollView setScrollEnabled:NO];
	
	//
	[currentPdfScrollView addSubview:psivc.view];
}

#pragma mark -
#pragma mark Treat TOC.
- (BOOL)parseTocDefine
{
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	appDelegate.tocDefine = [[NSMutableArray alloc] init];
	
	NSMutableDictionary* tmpDict;
	
	//parse csv file.
	NSString* csvFilePath = [[NSBundle mainBundle] pathForResource:@"tocDefine" ofType:@"csv"];
	NSError* error;
	NSString* text = [NSString stringWithContentsOfFile:csvFilePath encoding:NSUTF8StringEncoding error:&error];
	
	bool hasError = FALSE;
	NSArray* lines = [text componentsSeparatedByString:@"\n"];
	for (NSString* line in lines) {
		if ([line length] <= 0) {
			continue;	//Skip blank line.
		}
		if ([line characterAtIndex:0] == '#'
			||
			[line characterAtIndex:0] == ';') {
			continue;	//Skip comment line.
		}
		NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
		if ([tmpCsvArray count] < 3) {
			NSLog(@"illigal CSV data. item count=%d, line=%@", [tmpCsvArray count], line);
			continue;	//Skip illigal line.
		}
		
		tmpDict = [[NSMutableDictionary alloc] init];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:0] intValue]] forKey:TOC_PAGE];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:1] intValue]] forKey:TOC_LEVEL];
		[tmpDict setValue:[tmpCsvArray objectAtIndex:2] forKey:TOC_TITLE];
		if (3 < [tmpCsvArray count]) {
			[tmpDict setValue:[tmpCsvArray objectAtIndex:3] forKey:TOC_FILENAME];
		}
		//if (3 < [tmpCsvArray count]) {
		//	[tmpDict setValue:[[tmpCsvArray objectAtIndex:2] stringValue] forKey:TOC_CELL_IMAGE];
		//}
		
		//Check page range.
		if (maxPageNum < [[tmpDict objectForKey:TOC_PAGE] intValue]) {
			continue;	//skip to next object. not add to define.
		}
		
		//Add to toc define.
		[appDelegate.tocDefine addObject:tmpDict];
	}
	return ! hasError;
}

- (void)showTocView
{
	[self.view addSubview:tocViewController.view];
	[tocViewController reloadDataForce];
}
- (void)hideTocView {
	[menuViewController hideTocView];
	[tocViewController.view removeFromSuperview];
}

#pragma mark Treat ThumbnailView(ImageTOC).

#pragma mark Treat Bookmark.

#pragma mark -
#pragma mark Treat Menu.
- (void)toggleMenuBar
{
	if (isShownMenuBar == NO) {
		[self showMenuBar];
	} else {
		[self hideMenuBar];
	}
}
- (void)showMenuBar
{
	[self.view bringSubviewToFront:menuViewController.view];
	[UIView beginAnimations:@"menuBarShow" context:nil];
	menuViewController.view.alpha = 1.0f;
	[UIView commitAnimations];
	
	isShownMenuBar = YES;
}
- (void)hideMenuBar
{
	[UIView beginAnimations:@"menuBarHide" context:nil];
	menuViewController.view.alpha = 0.0f;
	[UIView commitAnimations];
	
	isShownMenuBar = NO;
}


#pragma mark -
#pragma mark Show other view.
- (IBAction)showInfoView
{
	//LOG_CURRENT_METHOD;
	[self hideMenuBar];
	InfomationViewController* vc = [[InfomationViewController alloc] initWithNibName:@"InfomationView" bundle:[NSBundle mainBundle]];
	//Setup frame.
	CGRect infoViewFrame = vc.view.frame;	//Fit with self.view.
	infoViewFrame.size.width = self.view.frame.size.width;
	infoViewFrame.size.height = self.view.frame.size.height;
	vc.view.frame = infoViewFrame;
	//Show view.
	[self.view addSubview:vc.view];
}

#pragma mark -
#pragma mark Show Web view.
- (void)showWebViewSelector:(NSString*)urlString
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"urlString=%@", urlString);
	[urlForWeb setString:urlString];
	//NSLog(@"urlForWeb=%@", urlForWeb);
    UIActionSheet *sheet =[[UIActionSheet alloc]
                           initWithTitle:@"URLリンクを開く (リンクからAppStoreにアクセスする場合は、Safariを起動してください)"
						   delegate:self
						   cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:nil
                           otherButtonTitles:@"アプリ内のビューワで開く", @"Safariを起動して開く", nil];
	
    [sheet showInView:self.view];	//[sheet showInView:self.view.window];
    [sheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//LOG_CURRENT_METHOD;
	if (! urlForWeb) {
		LOG_CURRENT_LINE;
		NSLog(@"no URL set");
		return;
	}
	//NSLog(@"urlForWeb=%@", urlForWeb);
	
	if (buttonIndex == 0) {
		[self showWebView:urlForWeb];
	} else if (buttonIndex == 1) {
		[self showWebWithSafari:urlForWeb];
	}
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
	return;
}

- (void)showWebView:(NSString*)urlString
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"urlString = %@", urlString);
	[self hideMenuBar];
	
	if (webViewController) {
		webViewController.webView.delegate = nil;	//set nil before release because of ASync-load.
		[webViewController release];
		webViewController = nil;
	}
	webViewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:[NSBundle mainBundle]];
	CGRect webViewFrame = webViewController.view.frame;	//Fit with self.view.
	webViewFrame.size.width = self.view.frame.size.width;
	webViewFrame.size.height = self.view.frame.size.height;
	webViewController.view.frame = webViewFrame;
	
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[self.view addSubview:webViewController.view];
    [webViewController.webView loadRequest:request];
}

- (void)showWebWithSafari:(NSString*)urlString
{
	//LOG_CURRENT_METHOD;
	[self hideMenuBar];
	//NSLog(@"urlString = %@", urlString);
	
	
	NSURL* url = [NSURL URLWithString:urlString];
	if ([[UIApplication sharedApplication] canOpenURL:url]) {
		[[UIApplication sharedApplication] openURL:url];
	}
}

#pragma mark -
#pragma mark Handle Rotate.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (interfaceOrientation == UIInterfaceOrientationPortrait
		||
		interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		return YES;
	} else {
		return NO;
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	if ([self isChangeOrientationKind:self.interfaceOrientation newOrientation:toInterfaceOrientation] == YES) {
		//Rotate MyPdfScrollView.
		CGSize newSize;
		CGFloat statusBarHeight = 0.0f;	//20.0f;	//status bar is hidden.
		if (toInterfaceOrientation == UIInterfaceOrientationPortrait
			||
			toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			newSize = CGSizeMake(self.view.frame.size.width + statusBarHeight, self.view.frame.size.height);
		} else {
			newSize = CGSizeMake(self.view.frame.size.height + statusBarHeight, self.view.frame.size.width);
		}
		[prevPdfScrollView setupCurrentPageWithSize:newSize];
		[currentPdfScrollView setupCurrentPageWithSize:newSize];
		[nextPdfScrollView setupCurrentPageWithSize:newSize];
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[currentPdfScrollView resetScrollView];
}

- (bool)isChangeOrientationKind:(UIInterfaceOrientation)oldOrientation newOrientation:(UIInterfaceOrientation)newOrientation {
	if (oldOrientation == UIDeviceOrientationUnknown) { return NO; }
	if (newOrientation == UIDeviceOrientationUnknown) { return NO; }
	
	if (oldOrientation == UIDeviceOrientationPortrait
		||
		oldOrientation == UIDeviceOrientationPortraitUpsideDown) {
		if (newOrientation == UIDeviceOrientationLandscapeLeft
			||
			newOrientation == UIDeviceOrientationLandscapeRight) {
			return YES;
		} else {
			return NO;
		}
	} else {
		if (newOrientation == UIDeviceOrientationPortrait
			||
			newOrientation == UIDeviceOrientationPortraitUpsideDown) {
			return YES;
		} else {
			return NO;
		}
	}
}

#pragma mark utility method.
- (NSString*)formatStringWithAlphaNumeric:(NSString*)originalStr
{
	NSString* tmpStrWithoutDoubleQuote = [originalStr
										  stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x22]
										  withString:@""];	/* delete DoubleQuote. */
	NSString* tmpStrWithoutCR = [tmpStrWithoutDoubleQuote 
								 stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x0d]
								 withString:@""];	/* delete CR. */
	NSString* tmpStrWithoutLF = [tmpStrWithoutCR
								 stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x0a]
								 withString:@""];	/* delete LF. */
	
	return tmpStrWithoutLF;
}

#pragma mark Latest Read Page.
- (void)setLatestReadPage:(int)pageNum {
	NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
	[userDefault setInteger:pageNum forKey:USERDEFAULT_LATEST_READ_PAGE];
	[userDefault synchronize];
}
- (int)getLatestReadPage {
	NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	id obj = [settings valueForKey:USERDEFAULT_LATEST_READ_PAGE];
	if (obj) {
		return [obj intValue];
	} else {
		return -1;
	}
}

#pragma mark -
#pragma mark other methods.
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
