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
//@synthesize imageView1, imageView2, imageView3;
//@synthesize image1, image2, image3;
@synthesize menuViewController, webViewController, tocViewController, thumbnailViewController, bookmarkViewController;
@synthesize isShownMenuBar, isShownTocView, isShownThumbnailView, isShownBookmarkView;
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
	
	
	//Open and init PDF file.
	if ([self openAndInitPdf] == FALSE) {
		return;
	}
	
	//Generate Thumbnail image.
	//generate when need.(for launch speed up.)
	//[self generateThumbnailImage:100.0f];
	
	//Show top page.
	[self drawPageWithNumber:currentPageNum];
	[self.view setNeedsDisplay];
	
#pragma mark (MenuBar and other)
	//Setup MenuBar.
	menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuView" bundle:[NSBundle mainBundle]];
	[self.view addSubview:menuViewController.view];
	[self hideMenuBar];
	
	//Setup WebView.
	//generate when need.
	webViewController = nil;
	
	//Setup Links.
	linksInCurrentPage = [[NSMutableArray alloc] init];
	[self renderPageLinkAtIndex:currentPageNum];
	
	// Setup for Movie play.
	[self parseMovieDefine];
	[self renderMovieLinkAtIndex:currentPageNum];
	
	// Setup for InPage ScrollView.
	[self parseInPageScrollViewDefine];
	[self renderInPageScrollViewAtIndex:currentPageNum];
	
	// Setup TOC(Table Of Contents).
	[self parseTocDefine];
	tocViewController = [[TocViewController alloc] initWithNibName:@"TocView" bundle:[NSBundle mainBundle]];
	isShownTocView = FALSE;
	
	// Setup Thumbnail Image Toc View.
	thumbnailViewController = [[ThumbnailViewController alloc] init];
	isShownThumbnailView = FALSE;
	
	// Setup Bookmark View.
	[self parseBookmarkDefine];
	bookmarkViewController = [[BookmarkViewController alloc] initWithNibName:@"BookmarkView" bundle:[NSBundle mainBundle]];
	isShownBookmarkView = FALSE;
	
#pragma mark (Read LastReadPage from UserDefault)
	int lastReadPage = [self getLatestReadPage];
	if (0 < lastReadPage) {
		[self switchToPage:lastReadPage];
	}
}


#pragma mark -
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self renderPageLinkAtIndex:currentPageNum];
	[self renderMovieLinkAtIndex:currentPageNum];
	[self renderInPageScrollViewAtIndex:currentPageNum];
}

#pragma mark -
#pragma mark Open / Initialize PDF.
//Open PDF file.
- (BOOL)openAndInitPdf
{
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
	bool result;
	result = [self initPdfWithFilename:pdfFilename];
	if (result == FALSE) {
		//
		UILabel* errorMessageLabel = [[UILabel alloc] init];
		errorMessageLabel.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 40.0f);
		errorMessageLabel.text = @"PDF File cannot open.";
		[self.view addSubview:errorMessageLabel];
		return FALSE;
	}
	return TRUE;
}
/**
 *Initialize pdf file.
 */
- (BOOL)initPdfWithFilename:(NSString*)filename
{
	//Open pdf file.
	NSURL *pdfURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
	if (!pdfURL) {
		NSLog(@"PDF file not exist. filename=%@", filename);
		return FALSE;
	}
	pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
	if (!pdf) {
		NSLog(@"PDF file cannot open. filename=%@", filename);
		return FALSE;
	}
	
	//Set filename to pdfScrollView.
	//[pdfScrollView1 initPdfWithFilename:filename];
	//[pdfScrollView2 initPdfWithFilename:filename];
	//[pdfScrollView3 initPdfWithFilename:filename];
	
	//Set max page number.
	maxPageNum = CGPDFDocumentGetNumberOfPages(pdf);
	//NSLog(@"maxPageNum=%d", maxPageNum);
	
	//Set frame size from page1.
	page = CGPDFDocumentGetPage(pdf, 1);
	originalPageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
	pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
	pdfScale = self.view.frame.size.width / pageRect.size.width;
	pageRect.size = CGSizeMake(pageRect.size.width*pdfScale, pageRect.size.height*pdfScale);
	LOG_CURRENT_METHOD;
	NSLog(@"pdfScale=%f", pdfScale);
	NSLog(@"originalPageRect in page 1 = %@", NSStringFromCGRect(originalPageRect));
	NSLog(@"pageRect in page 1 = %@", NSStringFromCGRect(pageRect));
	
	return TRUE;
}

#pragma mark -
- (NSString*)getThumbnailFilenameFull:(int)pageNum {
	NSString* filename = [NSString stringWithFormat:@"%@%d", THUMBNAIL_FILE_PREFIX, pageNum];
	NSString* targetFilenameFull = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
									stringByAppendingPathComponent:filename]
								   stringByAppendingPathExtension:THUMBNAIL_FILE_EXTENSION];
	return targetFilenameFull;
}

- (void)generateThumbnailImage:(CGFloat)newWidth
{
	//LOG_CURRENT_METHOD;
	for (int i = 1; i < maxPageNum; i = i + 1) {
		NSString* targetFilenameFull = [self getThumbnailFilenameFull:i];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if (! [fileManager fileExistsAtPath:targetFilenameFull]) {
			NSLog(@"thumbnail file for page %d not exist. generate. filename=%@", i, targetFilenameFull);
			
			//Get original image.
			UIImage* image = [self getPdfPageImageWithPageNum:i];
			
			//Calicurate new size.
			CGFloat scale = image.size.width / newWidth;
			CGSize newSize = CGSizeMake(image.size.width / scale,
										image.size.height / scale);
			NSLog(@"newSize=%f,%f", newSize.width, newSize.height);
			
			
			UIImage* resizedImage;
			CGInterpolationQuality quality = kCGInterpolationLow;
			
			UIGraphicsBeginImageContext(newSize);
			CGContextRef context = UIGraphicsGetCurrentContext();
			CGContextSetInterpolationQuality(context, quality);
			[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
			resizedImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			
			/*
			CGRect rect = CGRectMake(0, 0,
									 image.size.width  * ratio,
									 image.size.height * ratio);
			
			UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0); // 変更
			
			
			UIImage* shrinkedImage = UIGraphicsGetImageFromCurrentImageContext();
			
			UIGraphicsEndImageContext();
			*/
			
			//Save to file.
			NSData *data = UIImagePNGRepresentation(resizedImage);
			NSError* error = nil;
			[data writeToFile:targetFilenameFull options:NSDataWritingAtomic error:&error];
			if (error) {
				NSLog(@"thumbnail file write error. path=%@", targetFilenameFull);
				NSLog(@"error=%@, error code=%d", [error localizedDescription], [error code]);
				continue; //skip to next file.
			} else {
				NSLog(@"wrote thumbnail file to %@", targetFilenameFull);
			}

		}
	}
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




#pragma mark draw pdf to screen.
- (NSString*)getPageFilenameFull:(int)pageNum {
	NSString* filename = [NSString stringWithFormat:@"%@%d", PAGE_FILE_PREFIX, pageNum];
	NSString* targetFilenameFull = [[[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:PAGE_FILE_EXTENSION];
	return targetFilenameFull;
}



/**
 *
 *note:pageNum is 1-start.
 *
 */
- (BOOL)preparePdfPageImageWithPageNum:(NSUInteger)pageNum
{
	LOG_CURRENT_METHOD;
	if (maxPageNum < pageNum) {
		NSLog(@"illigal page given. pageNum=%d, maxPageNum=%d", pageNum, maxPageNum);
		return FALSE;
	}
	
	//Get image from file if exists.
	NSString* targetFilenameFull = [self getPageFilenameFull:pageNum];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:targetFilenameFull]) {
		//Image file already exists. do nothing.
		return TRUE;
	}
	
	NSLog(@"page file for page %d not exist. generate. filename=%@", pageNum, targetFilenameFull);
	BOOL result;
	result = [self generatePdfPageImageWithPageNum:pageNum];
	return result;
}

/**
 *note:pageNum is 1-start.
 */
- (BOOL)generatePdfPageImageWithPageNum:(NSUInteger)pageNum
{
	//Determin image frame size.
	CGRect imageFrame;
	if (originalPageRect.size.width <= self.view.frame.size.width) {
		//PDF.width <= Screen.width
		imageFrame = pageRect;
	} else {
		imageFrame = originalPageRect;
	}
	LOG_CURRENT_METHOD;
	NSLog(@"imageFrame=%@", NSStringFromCGRect(imageFrame));
	
	// Create a low res image representation of the PDF page to display before the TiledPDFView
	// renders its content.
	UIGraphicsBeginImageContext(imageFrame.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// First fill the background with white.
	CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
	CGContextFillRect(context, imageFrame);
	
	CGContextSaveGState(context);
	// Flip the context so that the PDF page is rendered
	// right side up.
	CGContextTranslateCTM(context, 0.0, imageFrame.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	// Scale the context so that the PDF page is rendered 
	// at the correct size for the zoom level.
	//CGContextScaleCTM(context, pdfScale, pdfScale);	
	
	page = CGPDFDocumentGetPage(pdf, pageNum);
	if (! page) {
		NSLog(@"illigal page. source line=%d, pageNum=%d", __LINE__, pageNum);
		return FALSE;
	}
	
	CGPDFPageRetain(page);	/**/
	
	//Scale PDF for fit Screen. (streatch only PDF smaller than Screen.)
	if (originalPageRect.size.width <= self.view.frame.size.width) {
		//PDF.width <= Screen.width
		CGContextScaleCTM(context, pdfScale, pdfScale);
	}
	
	//Draw PDF.
	CGContextDrawPDFPage(context, page);
	CGContextRestoreGState(context);
	
	UIImage *pdfImage = UIGraphicsGetImageFromCurrentImageContext();
	[pdfImage retain];//(needs count down in calling method.)
	
	UIGraphicsEndImageContext();
	if (! pdfImage) {
		NSLog(@"UIGraphicsGetImageFromCurrentImageContext returns nil.");
	}
	
	//Save to file.
	NSString* targetFilenameFull = [self getPageFilenameFull:pageNum];
	NSData *data = UIImagePNGRepresentation(pdfImage);
	NSError* error = nil;
	[data writeToFile:targetFilenameFull options:NSDataWritingAtomic error:&error];
	if (error) {
		NSLog(@"page file write error. path=%@", targetFilenameFull);
		NSLog(@"error=%@, error code=%d", [error localizedDescription], [error code]);
		return FALSE;
	} else {
		NSLog(@"wrote page file to %@", targetFilenameFull);
	}
	
	return TRUE;
}	


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
	[self preparePdfPageImageWithPageNum:pageNum];

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
		NSLog(@"page file for page %d not exist. generate. filename=%@", pageNum, targetFilenameFull);
		return nil;
	}
	
	return nil;
}

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
	[self preparePdfPageImageWithPageNum:newPageNum];
	
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
#pragma mark URL Link.
/**
 * @see:http://stackoverflow.com/questions/4080373/get-pdf-hyperlinks-on-ios-with-quartz
 */
- (void) renderPageLinkAtIndex:(NSUInteger)index
{
	//LOG_CURRENT_METHOD;
	
	//CGPDFPageRef page2 = CGPDFDocumentGetPage(pdf, index+1);
	//CGAffineTransform transform1 = aspectFit(CGPDFPageGetBoxRect(page, kCGPDFMediaBox),
	//										 CGContextGetClipBoundingBox(ctx));
	//CGContextConcatCTM(ctx, transform1);
	//CGContextDrawPDFPage(ctx, page2);
	
	[linksInCurrentPage removeAllObjects];
	
    CGPDFPageRef pageAd = CGPDFDocumentGetPage(pdf, index);
	
    CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(pageAd);
	
    CGPDFArrayRef outputArray = nil;
    if(!CGPDFDictionaryGetArray(pageDictionary, "Annots", &outputArray)) {
        return;
    }
	
    int arrayCount = CGPDFArrayGetCount( outputArray );
    if(!arrayCount) {
        //continue;
    }
	
    for( int j = 0; j < arrayCount; ++j ) {
        CGPDFObjectRef aDictObj;
        if(!CGPDFArrayGetObject(outputArray, j, &aDictObj)) {
            return;
        }
		
        CGPDFDictionaryRef annotDict = nil;
        if(!CGPDFObjectGetValue(aDictObj, kCGPDFObjectTypeDictionary, &annotDict)) {
            return;
        }
		
        CGPDFDictionaryRef aDict = nil;
        if(!CGPDFDictionaryGetDictionary(annotDict, "A", &aDict)) {
            return;
        }
		
        CGPDFStringRef uriStringRef = nil;
        if(!CGPDFDictionaryGetString(aDict, "URI", &uriStringRef)) {
            return;
        }
		
        CGPDFArrayRef rectArray = nil;
        if(!CGPDFDictionaryGetArray(annotDict, "Rect", &rectArray)) {
            return;
        }
		
        int arrayCount = CGPDFArrayGetCount( rectArray );
        CGPDFReal coords[4];
        for( int k = 0; k < arrayCount; ++k ) {
            CGPDFObjectRef rectObj;
            if(!CGPDFArrayGetObject(rectArray, k, &rectObj)) {
                return;
            }
			
            CGPDFReal coord;
            if(!CGPDFObjectGetValue(rectObj, kCGPDFObjectTypeReal, &coord)) {
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
		
		//Generate frame for draw on pdf-image.
		CGRect linkRect;
		//if (self.view.frame.size.width < originalPageRect.size.width) {
		if (self.view.frame.size.width < currentPdfScrollView.originalPageWidth) {
			linkRect = CGRectMake(x1 / pdfScale,
								  (currentPdfScrollView.originalPageHeight - y2) / pdfScale,	//does not "y1".
								  fabsf(x2 - x1) / pdfScale,
								  fabsf(y2 - y1) / pdfScale);
			
		} else {
			//Arrange frame if PDF.Width < Screen.Width
			linkRect = CGRectMake(x1 * pdfScale,
								  (currentPdfScrollView.originalPageHeight - (y2 * pdfScale)),
								  fabsf(x2 - x1) * pdfScale,
								  fabsf(y2 - y1) * pdfScale);
		}
		//NSLog(@"scaleForDraw=%f", currentPdfScrollView.scaleForDraw);
		//NSLog(@"linkRect   =%@", NSStringFromCGRect(linkRect));
		//NSLog(@"pdfScale   =%f", pdfScale);
		//NSLog(@"currentPdfScrollView.originalPage Size={%1.0f, %1.0f}",
		//	  currentPdfScrollView.originalPageWidth,
		//	  currentPdfScrollView.originalPageHeight);
		//NSLog(@"originalPageRect.size=%@", NSStringFromCGSize(originalPageRect.size));
		//NSLog(@"self.view.frame.size=%@", NSStringFromCGSize(self.view.frame.size));
		
		//Add subView.
		UIView* areaView = [[UIView alloc] initWithFrame:linkRect];
#if TARGET_IPHONE_SIMULATOR
		//Only show on Simulator.
		[areaView setBackgroundColor:[UIColor blueColor]];
		[areaView setAlpha:0.2f];
#else
		[areaView setAlpha:0.0f];
#endif
		[currentPdfScrollView addScalableSubview:areaView withPdfBasedFrame:linkRect];
		

		//Add link infomation for touch.
        char *uriString = (char *)CGPDFStringGetBytePtr(uriStringRef);
        NSString *uri = [NSString stringWithCString:uriString encoding:NSUTF8StringEncoding];
		NSURL *url = [NSURL URLWithString:uri];
		//NSLog(@"URL=%@", url);
		NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
		[tmpDict setValue:[url description] forKey:LINK_DICT_KEY_URL];
		[tmpDict setValue:[NSValue valueWithCGRect:linkRect] forKey:LINK_DICT_KEY_RECT];
		[linksInCurrentPage addObject:tmpDict];
		
		
		
		/**
		 *		From array to cgPoint variable.
		 */		
		//NSValue *val = [points objectAtIndex:0];
		//CGPoint p = [val CGPointValue];
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
	[self renderInPageScrollViewAtIndex:currentPageNum];
	
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
	[self renderInPageScrollViewAtIndex:currentPageNum];
	
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
	[self renderInPageScrollViewAtIndex:currentPageNum];
	
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
	CGPoint touchedPointNormalize = CGPointMake(touchedPoint.x / currentPdfScrollView.scaleForDraw,
												touchedPoint.y / currentPdfScrollView.scaleForDraw);
	//NSLog(@"location in scrollView normalized = %@", NSStringFromCGPoint(touchedPointNormalize));
	//NSLog(@"location in original page =%f, %f", currentPdfScrollView.originalPageWidth, currentPdfScrollView.originalPageHeight);
	
	// Check if TocView, ThumbnailView, BookmarkVew shown, then hide it.
	if (isShownTocView) {
		[self hideTocView];
		return;
	}
	if (isShownThumbnailView) {
		[self hideThumbnailView];
		return;
	}
	if (isShownBookmarkView) {
		[self hideBookmarkView];
	}
	
	// Compare with URL Link in page.
	for (NSMutableDictionary* tmpDict in linksInCurrentPage) {
		NSValue* val = [tmpDict objectForKey:LINK_DICT_KEY_RECT];
		CGRect r = [val CGRectValue];
		if (CGRectContainsPoint(r, touchedPointNormalize)) {
			NSString* urlStr = [tmpDict objectForKey:LINK_DICT_KEY_URL];
			NSLog(@"URL link touched. url=%@", urlStr);
			
			//no-continue.
			[self showWebView:urlStr];
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
			
			if (CGRectContainsPoint(rect, touchedPointNormalize)) {
				NSString* filename = [movieInfo valueForKey:MD_MOVIE_FILENAME];
				NSLog(@"movie link touched. filename=%@", filename);
				
				//no-continue.
				[self showMoviePlayer:filename];
				return;
			}
		}
	}
	
	// Compare with in left_area, in right_area.
	CGRect leftTapArea, rightTapArea, bottomTapArea, topTapArea;
	CGFloat baseWidth, baseHeight;
	baseWidth  = currentPdfScrollView.originalPageWidth;
	baseHeight = currentPdfScrollView.originalPageHeight;
	leftTapArea = CGRectMake(0.0f,
							 baseHeight * 0.15f,
							 baseWidth  * 0.40f,
							 baseHeight * 0.70f);
	rightTapArea = CGRectMake(baseWidth * 0.60f,
							  baseHeight* 0.15f,
							  baseWidth  * 0.40f,
							  baseHeight * 0.70f);
	topTapArea = CGRectMake(0.0f,
							0.0f,
							baseWidth  * 1.00f,
							baseHeight * 0.15f);
	bottomTapArea = CGRectMake(0.0f,
							   baseHeight * 0.85f,
							   baseWidth  * 1.00f,
							   baseHeight * 0.15f);
	//NSLog(@"leftTapArea=%@", NSStringFromCGRect(leftTapArea));
	//NSLog(@"rightTapArea=%@", NSStringFromCGRect(rightTapArea));
	//NSLog(@"topTapArea=%@", NSStringFromCGRect(topTapArea));
	//NSLog(@"bottomTapArea=%@", NSStringFromCGRect(bottomTapArea));
	
	CGPoint touchedPointInParentView = [gestureRecognizer locationInView:self.view];
	NSLog(@"location in parent view = %@", NSStringFromCGPoint(touchedPointInParentView));
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
#pragma mark Treat Movie.
//Parse Movie Define.
- (BOOL)parseMovieDefine
{
	movieDefine = [[NSMutableArray alloc] init];
	
	NSMutableDictionary* tmpDict;
	
	//parse csv file.
	NSString* csvFilePath = [[NSBundle mainBundle] pathForResource:@"movieDefine" ofType:@"csv"];
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
		NSString* tmpStrWithoutDoubleQuote = [tmpStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x22] withString:@""];	/* delete DoubleQuote. */
		//NSString* tmpStrURLEncoded = [tmpStrWithoutDoubleQuote stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		//[tmpDict setValue:tmpStrURLEncoded forKey:MD_MOVIE_FILENAME];
		[tmpDict setValue:tmpStrWithoutDoubleQuote forKey:MD_MOVIE_FILENAME];
		
		//Check page range.
		if (maxPageNum < [[tmpDict objectForKey:MD_PAGE_NUMBER] intValue]) {
			continue;	//skip to next object. not add to define.
		}
		
		//Add to movie define.
		[movieDefine addObject:tmpDict];
	}
	//
	
	return ! hasError;
}

- (void) renderMovieLinkAtIndex:(NSUInteger)index
{
	for (NSMutableDictionary* movieInfo in movieDefine) {
		int targetPageNum = [[movieInfo valueForKey:MD_PAGE_NUMBER] intValue];
		if (targetPageNum == index) {
			//NSString* filename = [movieInfo valueForKey:MD_MOVIE_FILENAME];
			CGRect rect;
			rect.origin.x	= [[movieInfo valueForKey:MD_AREA_X] floatValue];
			rect.origin.y	= [[movieInfo valueForKey:MD_AREA_Y] floatValue];
			rect.size.width	= [[movieInfo valueForKey:MD_AREA_WIDTH] floatValue];
			rect.size.height= [[movieInfo valueForKey:MD_AREA_HEIGHT] floatValue];
			//NSLog(@"rect for movie=%@", NSStringFromCGRect(rect));
			
			CGRect touchableArea;
			//if (self.view.frame.size.width < originalPageRect.size.width) {
			if (self.view.frame.size.width < currentPdfScrollView.originalPageWidth) {
				touchableArea = CGRectMake(rect.origin.x / pdfScale,
									 rect.origin.y / pdfScale,
									 rect.size.width / pdfScale,
									 rect.size.height / pdfScale);
			} else {
				//Arrange frame if PDF.Width < Screen.Width
				touchableArea = CGRectMake(rect.origin.x * pdfScale,
									 rect.origin.y * pdfScale,
									 rect.size.width * pdfScale,
									 rect.size.height * pdfScale);
			}
			//NSLog(@"rect for movie arranged=%@", NSStringFromCGRect(touchableArea));
			//NSLog(@"pdfScale=%f", pdfScale);

			//Show Movie link area with half-opaque.
			UIView* areaView = [[UIView alloc] initWithFrame:touchableArea];
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
			[currentPdfScrollView addScalableSubview:areaView withPdfBasedFrame:rect];
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
	
	if (url = [NSURL fileURLWithPath:path]) {
		MPMoviePlayerViewController* mpview;
		if (mpview = [[MPMoviePlayerViewController alloc] initWithContentURL:url]) {
			[self presentMoviePlayerViewControllerAnimated:mpview];
			[mpview.moviePlayer play];
			[mpview release];
		}
	}
}


#pragma mark -
#pragma mark Treat InPage ScrollView.
//Parse InPage ScrollView Define.
- (BOOL)parseInPageScrollViewDefine
{
	inPageScrollViewDefine = [[NSMutableArray alloc] init];
	
	NSMutableDictionary* tmpDict;
	
	//parse csv file.
	NSString* csvFilePath = [[NSBundle mainBundle] pathForResource:@"inPageScrollViewDefine" ofType:@"csv"];
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
		if ([tmpCsvArray count] < 6) {
			NSLog(@"illigal CSV data. item count=%d, line=%@", [tmpCsvArray count], line);
			continue;	//Skip illigal line.
		}
		
		tmpDict = [[NSMutableDictionary alloc] init];
		//Page Number.
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:0] intValue]] forKey:IPSD_PAGE_NUMBER];
		//Position.
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:1] intValue]] forKey:IPSD_AREA_X];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:2] intValue]] forKey:IPSD_AREA_Y];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:3] intValue]] forKey:IPSD_AREA_WIDTH];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:4] intValue]] forKey:IPSD_AREA_HEIGHT];
		//Filenames.
		NSMutableArray* filenamesArray = [[NSMutableArray alloc] init];
		int i;
		for (i = 5; i < [tmpCsvArray count]; i = i + 1) {
			NSString* tmpStr = [tmpCsvArray objectAtIndex:i];
			NSString* tmpStrWithoutDoubleQuote = [tmpStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x22] withString:@""];	/* delete DoubleQuote. */
			//NSString* tmpStrURLEncoded = [tmpStrWithoutDoubleQuote stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			//[tmpDict setValue:tmpStrURLEncoded forKey:MD_MOVIE_FILENAME];
			[filenamesArray addObject:tmpStrWithoutDoubleQuote];
		}
		
		[tmpDict setValue:filenamesArray forKey:IPSD_FILENAMES];
		
		
		//Check page range.
		if (maxPageNum < [[tmpDict objectForKey:IPSD_PAGE_NUMBER] intValue]) {
			continue;	//skip to next object. not add to define.
		}
		
		//Add to ipsd define.
		[inPageScrollViewDefine addObject:tmpDict];
	}
	//
	return ! hasError;
}

- (void) renderInPageScrollViewAtIndex:(NSUInteger)index
{
	for (NSMutableDictionary* ipsvInfo in inPageScrollViewDefine) {
		int targetPageNum = [[ipsvInfo valueForKey:IPSD_PAGE_NUMBER] intValue];
		if (targetPageNum == index) {
			//(area)
			CGRect rect;
			rect.origin.x	= [[ipsvInfo valueForKey:IPSD_AREA_X] floatValue];
			rect.origin.y	= [[ipsvInfo valueForKey:IPSD_AREA_Y] floatValue];
			rect.size.width	= [[ipsvInfo valueForKey:IPSD_AREA_WIDTH] floatValue];
			rect.size.height= [[ipsvInfo valueForKey:IPSD_AREA_HEIGHT] floatValue];
			//(filename(s))
			NSMutableArray* filenames = (NSMutableArray*)[ipsvInfo objectForKey:IPSD_FILENAMES];
			
			//Show ScrollView.
			UIScrollView* ipsvScrollView = [[UIScrollView alloc] initWithFrame:rect];
			ipsvScrollView.pagingEnabled = YES;
			ipsvScrollView.userInteractionEnabled = YES;
			int x_space = 0.0f;
			int x_offset = 0 + x_space;
			int y_space = 0.0f;
			int y_maxHeight = 0.0f;
			for (NSString* filename in filenames) {
				NSString *path= [[NSBundle mainBundle] pathForResource:filename ofType:nil];
				if (!path) {
					NSLog(@"file not found:%@", filename);
					continue;	//next file.
				}
				UIImage* image = [[UIImage alloc] initWithContentsOfFile:path];
				if (!image) {
					NSLog(@"can not create image:%@", filename);
					continue;	//next file.
				}
				
				UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
				CGRect rect = imageView.frame;
				rect.origin.x = x_offset;
				rect.origin.y = y_space;
				imageView.frame = rect;
				[imageView retain];
				
				[ipsvScrollView addSubview:imageView];
				
				x_offset = x_offset + image.size.width + x_space;
				if (y_maxHeight < image.size.height) {
					y_maxHeight = image.size.height;
				}
			}
			ipsvScrollView.contentSize = CGSizeMake(x_offset, y_maxHeight);
			
			//LOG_CURRENT_METHOD;
			//NSLog(@"render InPageScrollView. rect=%f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
			//[currentPdfScrollView addSubview:ipsvScrollView];
			[currentPdfScrollView addScalableSubview:ipsvScrollView withPdfBasedFrame:rect];
		}
	}
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
- (BOOL)parseBookmarkDefine
{
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	appDelegate.bookmarkDefine = [[NSMutableArray alloc] init];

	NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	id obj = [settings valueForKey:BOOKMARK_ARRAY];
	if (!obj) {		//no bookmark exists.
		return YES;
	}
	if (![obj isKindOfClass:[NSArray class]]) {
		NSLog(@"illigal bookmark infomation. class=%@", [obj class]);
		return NO;
	}
	[appDelegate.bookmarkDefine addObjectsFromArray:obj];
	return YES;
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
- (void)showThumbnailView {
	[self hideMenuBar];
	
	//Setup with tocDefine.
	[thumbnailViewController setupImages];
	
	//Show by addSubview.
	//Add to superview. think with toolbar.
	[self.view.superview addSubview:thumbnailViewController.view];
	
	//Set flag.
	isShownThumbnailView = TRUE;
}
- (void)hideThumbnailView {
	//Hide by removeSuperView.
	[thumbnailViewController.view removeFromSuperview];
	isShownThumbnailView = FALSE;
}

#pragma mark Treat Bookmark.
- (void)showBookmarkView
{
	[self.view addSubview:bookmarkViewController.view];
	[tocViewController reloadDataForce];
}
- (void)hideBookmarkView {
	[menuViewController hideBookmarkView];
	[bookmarkViewController.view removeFromSuperview];
}
- (void)showBookmarkModifyView {
	[self hideMenuBar];
	BookmarkModifyViewController* bmvc = [[BookmarkModifyViewController alloc] initWithNibName:@"BookmarkModifyView" bundle:[NSBundle mainBundle]];
	[self presentModalViewController:bmvc animated:YES];
	
	//Set pageNumber after view loaded.
	[bmvc setPageNumberForPrint:currentPageNum];
}
- (void)addBookmarkWithCurrentPageWithName:(NSString*)bookmarkName {
	//LOG_CURRENT_METHOD;
	
	//Read bookmark infomation.
	NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	NSMutableArray* bookmarks = [[NSMutableArray alloc] init];
	id obj = [settings valueForKey:BOOKMARK_ARRAY];
	if (obj && [obj isKindOfClass:[NSArray class]]) {
		[bookmarks addObjectsFromArray:obj];
	}
	
	//Generate bookmark item from current pageNum.
	NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
	[tmpDict setObject:[NSNumber numberWithInt:currentPageNum] forKey:BOOKMARK_PAGE_NUMBER];
	[tmpDict setObject:bookmarkName forKey:BOOKMARK_PAGE_MEMO];
	[bookmarks addObject:tmpDict];
	
	//Store bookmark infomation to UserDefault.
	NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
	[userDefault setObject:bookmarks forKey:BOOKMARK_ARRAY];
	[userDefault synchronize];
	
	//Refresh TOC view and bookmark in appDelegate with UserDefault.
	[self parseBookmarkDefine];
	[bookmarkViewController reloadDataForce];
}

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
	[self.view addSubview:vc.view];
}

- (void)showWebView:(NSString*)urlString
{
	//LOG_CURRENT_METHOD;
	[self hideMenuBar];
	//NSLog(@"urlString = %@", urlString);
	
	if (webViewController) {
		webViewController.webView.delegate = nil;	//set nil before release because of ASync-load.
		[webViewController release];
		webViewController = nil;
	}
	webViewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:[NSBundle mainBundle]];
	
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[self.view addSubview:webViewController.view];
    [webViewController.webView loadRequest:request];
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
