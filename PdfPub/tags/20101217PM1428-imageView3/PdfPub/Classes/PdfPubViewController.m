//
//  PdfPubViewController.m
//  PdfPub
//
//  Created by okano on 10/12/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PdfPubViewController.h"

@implementation PdfPubViewController
@synthesize imageView1, imageView2, imageView3;
@synthesize image1, image2, image3;
@synthesize menuViewController;
@synthesize webViewController;
//@synthesize tocViewController;
@synthesize tocViewController;
//@synthesize tocDefine;
@synthesize currentImageView;

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
	
	// Initialize imageViews. -> init in Xib file!.
	// Set pointer with imageView.
	prevImageView		= imageView1;
	currentImageView	= imageView3;
	nextImageView		= imageView2;
	
	//Ignore default gesture recognizer.
	[imageView1 removeGestureRecognizer:[[imageView1 gestureRecognizers] objectAtIndex:0]];
	[imageView2 removeGestureRecognizer:[[imageView2 gestureRecognizers] objectAtIndex:0]];
	[imageView3 removeGestureRecognizer:[[imageView3 gestureRecognizers] objectAtIndex:0]];

	//
	//Add gesture recognizer to imageView1,2,3, scrollView.
	tapRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	tapRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	tapRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	[imageView1 addGestureRecognizer:tapRecognizer1];
	[imageView2 addGestureRecognizer:tapRecognizer2];
	[imageView3 addGestureRecognizer:tapRecognizer3];
	
	//Open PDF file.
	NSString* csvFilePath = [[NSBundle mainBundle] pathForResource:@"pdfDefine" ofType:@"csv"];
	NSError* error;
	NSString* text = [NSString stringWithContentsOfFile:csvFilePath encoding:NSUTF8StringEncoding error:&error];
	NSArray* lines = [text componentsSeparatedByString:@"\n"];
	NSString* pdfFilename;
	if ([lines count] < 1) {
		NSLog(@"no PDF file specified.");
		pdfFilename = [NSString stringWithFormat:@"TestPage.pdf"];
	} else {
		pdfFilename = [lines objectAtIndex:0];
	}
	[self initPdfWithFilename:pdfFilename];
	
	//Show top page.
	[self drawPageWithNumber:currentPageNum];
	
	//Setup MenuBar.
	menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuView" bundle:[NSBundle mainBundle]];
	[self.view addSubview:menuViewController.view];
	[self hideMenuBar];
	
	//Setup WebView.
	webViewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:[NSBundle mainBundle]];
	//webViewController.webView.delegate = webViewController;
	
	//
	linksInCurrentPage = [[NSMutableArray alloc] init];
	
	//
	//[self getPdfDictionaryWithPageNum:currentPageNum];
	[self renderPageLinkAtIndex:currentPageNum];
	
	// Setup for Movie play.
	[self parseMovieDefine];
	[self renderMovieLinkAtIndex:currentPageNum];
	
	// Setup TOC(Table Of Contents).
	[self parseTocDefine];
	//tocViewController = [[TocViewController alloc] initWithNibName:@"TocView" bundle:[NSBundle mainBundle]];
	//tocViewController = [[TocView alloc] initWithNibName:@"TocView" bundle:[NSBundle mainBundle]];
	tocViewController = [[TocView alloc] initWithNibName:@"TocView" bundle:[NSBundle mainBundle]];
}


#pragma mark -
#pragma mark Initialize PDF.
/**
 *Initialize pdf file.
 */
- (BOOL)initPdfWithFilename:(NSString*)filename
{
	//Open pdf file.
	NSURL *pdfURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
	if (!pdfURL) {
		NSLog(@"PDF file not exist. filename=%@", filename);
		return NO;
	}
	pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
	if (!pdf) {
		NSLog(@"PDF file cannot open. filename=%@", filename);
		return NO;
	}

	maxPageNum = CGPDFDocumentGetNumberOfPages(pdf);
	NSLog(@"maxPageNum=%d", maxPageNum);
	
	//Set frame size from page1.
	page = CGPDFDocumentGetPage(pdf, 1);
	pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
	pdfScale = self.view.frame.size.width / pageRect.size.width;
	pageRect.size = CGSizeMake(pageRect.size.width*pdfScale, pageRect.size.height*pdfScale);
	
	return YES;
}

#pragma mark handle PDF infomation.
- (BOOL)isVerticalWriting
{
	return NO;
}


/*
- (void)getPdfDictionaryWithPageNum:(NSUInteger)pageNum
{
    CGPDFPageRef tmpPage = CGPDFDocumentGetPage(pdf, pageNum);
	
	//PDF Drawing infomation.
	//CGPDFDocumentRef pageDocument = CGPDFPageGetDocument(tmpPage);
	
	//PDF key-value pairs can specify any kind of PDF object, including another dictionary.
    CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(tmpPage);
	
    CGPDFArrayRef outputArray;
    if(!CGPDFDictionaryGetArray(pageDictionary, "Annots", &outputArray)) {
        return;
    }
	int arrayCount = CGPDFArrayGetCount( outputArray );
	if (arrayCount <= 0) {
		return;
	}
	
	int i;
	for (i = 0; i < arrayCount; i = i + 1) {
        CGPDFObjectRef aDictObj;
        if(!CGPDFArrayGetObject(outputArray, i, &aDictObj)) {
            NSLog(@"CGPDFArrayGetObject returns false.");
        }
		
        CGPDFDictionaryRef annotDict;
        if(!CGPDFObjectGetValue(aDictObj, kCGPDFObjectTypeDictionary, &annotDict)) {
            NSLog(@"CGPDFObjectGetValue returns false.");
        }
		
        CGPDFDictionaryRef aDict;
        if(!CGPDFDictionaryGetDictionary(annotDict, "A", &aDict)) {
            NSLog(@"CGPDFDictionaryGetDictionary returns false.");
        }
		if (! aDict) {
			LOG_CURRENT_LINE;
			NSLog(@"aDict is false.");
		} else {
			NSLog(@"aDict is %@", [aDict description] );
		}

		
        CGPDFStringRef uriStringRef;
        if(!CGPDFDictionaryGetString(aDict, "URI", &uriStringRef)) {
            NSLog(@"CGPDFDictionaryGetString returns false.");
			
			char *uriString = (char *)CGPDFStringGetBytePtr(uriStringRef);
			
			NSString *uri = [NSString stringWithCString:uriString encoding:NSUTF8StringEncoding];
			NSLog(@"uri=%@", uri);
        }
	}

	

	return;
}
*/




- (void) renderPageLinkAtIndex:(NSUInteger)index
{
	
	//CGPDFPageRef page2 = CGPDFDocumentGetPage(pdf, index+1);
	//CGAffineTransform transform1 = aspectFit(CGPDFPageGetBoxRect(page, kCGPDFMediaBox),
	//										 CGContextGetClipBoundingBox(ctx));
	//CGContextConcatCTM(ctx, transform1);
	//CGContextDrawPDFPage(ctx, page2);
	
	[linksInCurrentPage removeAllObjects];
	
    CGPDFPageRef pageAd = CGPDFDocumentGetPage(pdf, index);
	
    CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(pageAd);
	
    CGPDFArrayRef outputArray;
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
		
        CGPDFDictionaryRef annotDict;
        if(!CGPDFObjectGetValue(aDictObj, kCGPDFObjectTypeDictionary, &annotDict)) {
            return;
        }
		
        CGPDFDictionaryRef aDict;
        if(!CGPDFDictionaryGetDictionary(annotDict, "A", &aDict)) {
            return;
        }
		
        CGPDFStringRef uriStringRef;
        if(!CGPDFDictionaryGetString(aDict, "URI", &uriStringRef)) {
            return;
        }
		
        CGPDFArrayRef rectArray;
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
		
        char *uriString = (char *)CGPDFStringGetBytePtr(uriStringRef);
		
        NSString *uri = [NSString stringWithCString:uriString encoding:NSUTF8StringEncoding];
        CGRect rect = CGRectMake(coords[0],coords[1],coords[2],coords[3]);
		
        CGPDFInteger pageRotate = 0;
        CGPDFDictionaryGetInteger( pageDictionary, "Rotate", &pageRotate ); 
        CGRect pageRect2 = CGRectIntegral( CGPDFPageGetBoxRect( page, kCGPDFMediaBox ));
        if( pageRotate == 90 || pageRotate == 270 ) {
            CGFloat temp = pageRect2.size.width;
            pageRect2.size.width = pageRect2.size.height;
            pageRect2.size.height = temp;
        }
		
        rect.size.width -= rect.origin.x;
        rect.size.height -= rect.origin.y;
		
        CGAffineTransform trans = CGAffineTransformIdentity;
        ////trans = CGAffineTransformTranslate(trans, 0, pageRect2.size.height);
        trans = CGAffineTransformTranslate(trans, 0, pageRect.size.height);
        trans = CGAffineTransformScale(trans, 1.0, -1.0);
		
        rect = CGRectApplyAffineTransform(rect, trans);
		//rect.origin.y = rect.origin.y * 0.5;
		rect.origin.y = rect.origin.y * 2.15 - 567.0;
		
		float widthAspect = 320.0 / pageRect2.size.width;
		float heightApsect = 480.0 / pageRect2.size.height;
		NSLog(@"screen/PDF widthAspect = %f, heightAspect = %f", widthAspect, heightApsect);
		
		rect.size.width = rect.size.width * 2.2;
		rect.size.height = rect.size.height * 1.5;
		
		// do whatever you need with the coordinates.
		// e.g. you could create a button and put it on top of your page
		// and use it to open the URL with UIApplication's openURL
		NSURL *url = [NSURL URLWithString:uri];
		NSLog(@"URL: %@, rext.(x,y)=%f,%f rect.width=%f, rect.height=%f", url, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
		//          CGPDFContextSetURLForRect(ctx, (CFURLRef)url, rect);
		UIButton *button = [[UIButton alloc] initWithFrame:rect];
		[button setTitle:@"LINK" forState:UIControlStateNormal];
		[button setTitle:[url description] forState:UIControlStateNormal];
		[button setBackgroundColor:[UIColor blueColor]];
		[button setAlpha:0.5f];
		[button addTarget:self action:@selector(openLink:) forControlEvents:UIControlEventTouchUpInside];
		[currentImageView addSubview:button];
		// CFRelease(url);
		
		NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
		[tmpDict setValue:[url description] forKey:LINK_DICT_KEY_URL];
		[tmpDict setValue:[NSValue valueWithCGRect:rect] forKey:LINK_DICT_KEY_RECT];
		[linksInCurrentPage addObject:tmpDict];
		/**
		 *		From array to cgPoint variable.
		 */		
		//NSValue *val = [points objectAtIndex:0];
		//CGPoint p = [val CGPointValue];
		
	}
    //} 
	
	
}

- (void)openLink:(id)sender
{
	NSLog(@"openLink function.");
}








#pragma mark Draw PDF.
/**
 *note:pageNum is 1-start.
 */
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum
{
	// Create a low res image representation of the PDF page to display before the TiledPDFView
	// renders its content.
	UIGraphicsBeginImageContext(pageRect.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// First fill the background with white.
	CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
	CGContextFillRect(context, pageRect);
	
	CGContextSaveGState(context);
	// Flip the context so that the PDF page is rendered
	// right side up.
	CGContextTranslateCTM(context, 0.0, pageRect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	// Scale the context so that the PDF page is rendered 
	// at the correct size for the zoom level.
	CGContextScaleCTM(context, pdfScale, pdfScale);	
	
	page = CGPDFDocumentGetPage(pdf, pageNum);
	if (! page) {
		LOG_CURRENT_METHOD;
		NSLog(@"illigal page. source line=%d, pageNum=%d", __LINE__, pageNum);
		return nil;
	}
	
	CGPDFPageRetain(page);	/**/
	CGContextDrawPDFPage(context, page);
	CGContextRestoreGState(context);
	
	UIImage *pdfImage = UIGraphicsGetImageFromCurrentImageContext();
	[pdfImage retain];//(needs count down in calling method.)
	
	UIGraphicsEndImageContext();
	if (! pdfImage) {
		NSLog(@"UIGraphicsGetImageFromCurrentImageContext returns nil.");
	}
	return pdfImage;
}

- (void)drawPageWithNumber:(int)newPageNum
{
    UIImage*    image;
	
	//Check currentPageNum.
	if (newPageNum <= 0) {
		newPageNum = 1;	//1-start.
	}
	if (maxPageNum < newPageNum) {
		newPageNum = maxPageNum;
	}
	
	//Draw current rough imageView.
	image = [self getPdfPageImageWithPageNum:newPageNum];
	currentImageView.image = image;
	[image release];
	//bring ScrollView to Front.
	[self.view bringSubviewToFront:currentImageView];
	
	//Draw next imageView.
	if (currentPageNum + 1 <= maxPageNum) {
		image = [self getPdfPageImageWithPageNum:newPageNum + 1];
		nextImageView.image = image;
		[image release];
	}
	
	//Draw prev imageView.
	if (1 <= currentPageNum - 1) {
		image = [self getPdfPageImageWithPageNum:newPageNum - 1];
		prevImageView.image = image;
		[image release];
	}
}

#pragma mark -
#pragma mark Move Page.
- (void)gotoNextPage
{
	if (currentPageNum == maxPageNum) {
		return;
	}
	
	//Erase child view(like LINK button).
    for (UIView *v in currentImageView.subviews) {
        [v removeFromSuperview];
    }
	
	// Set animation
	CATransition* animation1 = [CATransition animation];
	[animation1 setDelegate:self];
	[animation1 setDuration:PAGE_ANIMATION_DURATION_NEXT];
	[animation1 setTimingFunction:UIViewAnimationCurveEaseInOut];
	[animation1 setType:kCATransitionPush];
	[animation1 setSubtype:kCATransitionFromRight];
	[animation1 setValue:MY_ANIMATION_KIND_PAGE_FROM_RIGHT forKey:MY_ANIMATION_KIND];
	[[self.view layer] addAnimation:animation1 forKey:@"animation_to_NextPage"];
	
	
	// Move NextImageView to Front.
	[self.view bringSubviewToFront:nextImageView];
	
	// Shift view pointer.
	// tmp <- prev <- current <- next <- tmp.
	//(before)
	//(after)
	UIImageView* tmpPointer;
	tmpPointer		= prevImageView;
	prevImageView	= currentImageView;
	currentImageView= nextImageView;
	nextImageView	= tmpPointer;
	tmpPointer		= nil;
	
	//
	currentPageNum = currentPageNum + 1;
	if (maxPageNum < currentPageNum) {
		currentPageNum = maxPageNum;
	}
	
	// Load (new)nextImage.
	UIImage*    image;
	if (currentPageNum - 1 < maxPageNum) {
		image = [self getPdfPageImageWithPageNum:currentPageNum + 1];
	} else {
		image = nil;
	}
	nextImageView.image = image;
	[image release];
	
	//
	//[self getPdfDictionaryWithPageNum:currentPageNum];
	[self renderPageLinkAtIndex:currentPageNum];
	[self renderMovieLinkAtIndex:currentPageNum];
}

- (void)gotoPrevPage
{
	if (currentPageNum == 1) {
		return;
	}
	
	//Erase child view(like LINK button).
    for (UIView *v in currentImageView.subviews) {
        [v removeFromSuperview];
    }
	
	if (currentPageNum <= 1) {
		return;
	}
	
	// Set animation
	CATransition* animation1 = [CATransition animation];
	[animation1 setDelegate:self];
	[animation1 setDuration:PAGE_ANIMATION_DURATION_PREV];
	[animation1 setTimingFunction:UIViewAnimationCurveEaseInOut];
	[animation1 setType:kCATransitionPush];
	[animation1 setSubtype:kCATransitionFromLeft];
	[animation1 setValue:MY_ANIMATION_KIND_PAGE_FROM_LEFT forKey:MY_ANIMATION_KIND];
	[[self.view layer] addAnimation:animation1 forKey:@"animation_to_PrevPage"];
	
	
	// Move PrevImageView to Front.
	[self.view bringSubviewToFront:prevImageView];
	
	// Shift view pointer.
	// tmp -> prev -> current -> next -> tmp.
	//(before)
	//(after)
	UIImageView* tmpPointer;
	tmpPointer		= nextImageView;
	nextImageView	= currentImageView;
	currentImageView= prevImageView;
	prevImageView	= tmpPointer;
	tmpPointer		= nil;
	
	//
	currentPageNum = currentPageNum - 1;
	if (currentPageNum < 1) {
		currentPageNum = 1;
	}
	
	// Load (new)prevImage.
	UIImage*    image;
	if (1 < currentPageNum) {
		image = [self getPdfPageImageWithPageNum:currentPageNum - 1];
	} else {
		image = nil;
	}
	prevImageView.image = image;
	[image release];
	
	//
	[self renderPageLinkAtIndex:currentPageNum];
	[self renderMovieLinkAtIndex:currentPageNum];
}

- (void)switchToPage:(int)newPageNum
{
	//Check page range.
	if (newPageNum < 1 || maxPageNum < newPageNum) {
		return;
	}
	
	currentPageNum = newPageNum;
	
	UIImage*    image;
	// Load (new)currentImage.
	image = [self getPdfPageImageWithPageNum:currentPageNum];
	currentImageView.image = image;
	[image release];
	
	// Load (new)nextImage.
	if (currentPageNum - 1 < maxPageNum) {
		image = [self getPdfPageImageWithPageNum:currentPageNum + 1];
	} else {
		image = nil;
	}
	nextImageView.image = image;
	[image release];
	
	// Load (new)prevImage.
	if (1 < currentPageNum) {
		image = [self getPdfPageImageWithPageNum:currentPageNum - 1];
	} else {
		image = nil;
	}
	prevImageView.image = image;
	[image release];
	
	
	//Erase child view(like LINK button).
    for (UIView *v in currentImageView.subviews) {
        [v removeFromSuperview];
    }
	
	//Hide TOCView.
	[self.tocViewController.view removeFromSuperview];
	
	//Draw link to URL, Movie.
	[self renderPageLinkAtIndex:currentPageNum];
	[self renderMovieLinkAtIndex:currentPageNum];
	
	// Set animation
	CATransition* animation1 = [CATransition animation];
	[animation1 setDelegate:self];
	[animation1 setDuration:0.2f];
	[animation1 setTimingFunction:UIViewAnimationCurveEaseInOut];
	[animation1 setType:kCATransitionFade];
	[animation1 setValue:MY_ANIMATION_KIND_FADE forKey:MY_ANIMATION_KIND];
	[[self.view layer] addAnimation:animation1 forKey:@"animation_to_SpecifyPage"];
	
	
	// Move CurrentImageView to Front.
	[self.view bringSubviewToFront:currentImageView];
}

- (void)switchNextImageWithAnimationType:(NSString*)animationType
{ LOG_CURRENT_METHOD; }

/*
- (void)animationDidStart:(CAAnimation *)theAnimation
{
	LOG_CURRENT_METHOD;
	NSString* wtf = [theAnimation valueForKey:MY_ANIMATION_KIND]; 
	NSLog(@"animation type=%@", wtf);
	
	// Stop touch handle while change page.
	if ([wtf compare:MY_ANIMATION_KIND_PAGE_FROM_RIGHT]
		||
		[wtf compare:MY_ANIMATION_KIND_PAGE_FROM_LEFT]) {
		imageView1.userInteractionEnabled = NO;
		imageView2.userInteractionEnabled = NO;
		imageView3.userInteractionEnabled = NO;
	}
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	LOG_CURRENT_METHOD;
	NSString* wtf = [theAnimation valueForKey:MY_ANIMATION_KIND]; 
	NSLog(@"animation type=%@", wtf);
	
	// Start touch handle wend change page.
	if ([wtf compare:MY_ANIMATION_KIND_PAGE_FROM_RIGHT]
		||
		[wtf compare:MY_ANIMATION_KIND_PAGE_FROM_LEFT]) {
		imageView1.userInteractionEnabled = YES;
		imageView2.userInteractionEnabled = YES;
		imageView3.userInteractionEnabled = YES;
	}
}
*/


#pragma mark -
#pragma mark handle Gesture.
- (void)handleTap:(UITapGestureRecognizer*)gestureRecognizer
{
	NSLog(@"location=%@", NSStringFromCGPoint([gestureRecognizer locationInView:self.view]));
	
	// Compare with URL Link in page.
	for (NSMutableDictionary* tmpDict in linksInCurrentPage) {
		NSValue* val = [tmpDict objectForKey:LINK_DICT_KEY_RECT];
		CGRect r = [val CGRectValue];
		if (CGRectContainsPoint(r, [gestureRecognizer locationInView:self.view])) {
			NSString* urlStr = [tmpDict objectForKey:LINK_DICT_KEY_URL];
			NSLog(@"link touched. url=%@", urlStr);
			
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
			
			if (CGRectContainsPoint(rect, [gestureRecognizer locationInView:self.view])) {
				NSString* filename = [movieInfo valueForKey:MD_MOVIE_FILENAME];
				NSLog(@"movie link touched. filename=%@", filename);
				
				//no-continue.
				[self showMoviePlayer:filename];
				return;
			}
		}
	}
	
	// Compare with in left_area, in right_area.
	CGRect leftTapArea = CGRectMake(TAP_AREA_LEFT_X, TAP_AREA_LEFT_Y, TAP_AREA_LEFT_WIDTH, TAP_AREA_LEFT_HEIGHT);
	CGRect rightTapArea = CGRectMake(TAP_AREA_RIGHT_X, TAP_AREA_RIGHT_Y, TAP_AREA_RIGHT_WIDTH, TAP_AREA_RIGHT_HEIGHT);
	CGRect topTapArea = CGRectMake(TAP_AREA_TOP_X, TAP_AREA_TOP_Y, TAP_AREA_TOP_WIDTH, TAP_AREA_TOP_HEIGHT);
	
	if (CGRectContainsPoint(leftTapArea, [gestureRecognizer locationInView:self.view])) {
		[self handleTapInLeftArea:gestureRecognizer];
	}
	if (CGRectContainsPoint(rightTapArea, [gestureRecognizer locationInView:self.view])) {
		[self handleTapInRightArea:gestureRecognizer];
	}
	if (CGRectContainsPoint(topTapArea, [gestureRecognizer locationInView:self.view])) {
		[self handleTapInTopArea:gestureRecognizer];
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
	[self showMenuBar];
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
		NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
		if ([tmpCsvArray count] < 6) {
			NSLog(@"illigal CSV data. item count=%d, line=%@", [tmpCsvArray count], line);
		}
		
		tmpDict = [[NSMutableDictionary alloc] init];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:0] intValue]] forKey:MD_PAGE_NUMBER];
		NSString* tmpStr = [tmpCsvArray objectAtIndex:1];
		NSString* tmpStrWithoutDoubleQuote = [tmpStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x22] withString:@""];	/* delete DoubleQuote. */
		NSString* tmpStrURLEncoded = [tmpStrWithoutDoubleQuote stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[tmpDict setValue:tmpStrURLEncoded forKey:MD_MOVIE_FILENAME];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:2] intValue]] forKey:MD_AREA_X];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:3] intValue]] forKey:MD_AREA_Y];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:4] intValue]] forKey:MD_AREA_WIDTH];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:5] intValue]] forKey:MD_AREA_HEIGHT];
		
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
			
			//Show Movie link area with half-opaque.
			UIView* areaView = [[UIView alloc] initWithFrame:rect];
			[areaView setBackgroundColor:[UIColor yellowColor]];
			[areaView setAlpha:0.1f];
			[currentImageView addSubview:areaView];
		}
	}
}

- (void)showMoviePlayer:(NSString*)filename
{
	LOG_CURRENT_METHOD;
	NSLog(@"filename=%@", filename);
	
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
#pragma mark Treat TOC.
- (BOOL)parseTocDefine
{
	PdfPubAppDelegate* appDelegate = (PdfPubAppDelegate*)[[UIApplication sharedApplication] delegate];
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
		NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
		if ([tmpCsvArray count] < 3) {
			NSLog(@"illigal CSV data. item count=%d, line=%@", [tmpCsvArray count], line);
		}
		
		tmpDict = [[NSMutableDictionary alloc] init];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:0] intValue]] forKey:TOC_PAGE];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:1] intValue]] forKey:TOC_LEVEL];
		[tmpDict setValue:[tmpCsvArray objectAtIndex:2] forKey:TOC_TITLE];
		//if (3 < [tmpCsvArray count]) {
		//	[tmpDict setValue:[[tmpCsvArray objectAtIndex:2] stringValue] forKey:TOC_CELL_IMAGE];
		//}
		[appDelegate.tocDefine addObject:tmpDict];
	}
	return ! hasError;
}

- (void)showTocView
{
	[self.view addSubview:tocViewController.view];
}


#pragma mark -
#pragma mark Treat Menu.
- (void)toggleMenuBar
{ LOG_CURRENT_METHOD; }
- (void)showMenuBar
{
	[self.view bringSubviewToFront:menuViewController.view];
	[UIView beginAnimations:@"menuBarShow" context:nil];
	menuViewController.view.alpha = 1.0f;
	[UIView commitAnimations];
}
- (void)hideMenuBar
{
	[UIView beginAnimations:@"menuBarHide" context:nil];
	menuViewController.view.alpha = 0.0f;
	[UIView commitAnimations];
}


#pragma mark -
#pragma mark Show other view.
- (IBAction)showInfoView
{ LOG_CURRENT_METHOD; }

- (void)showWebView:(NSString*)urlString
{
	LOG_CURRENT_METHOD;
	NSLog(@"urlString = %@", urlString);

	//[webViewController loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
	
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webViewController.webView loadRequest:request];
	
	[self.view addSubview:webViewController.view];
}


#pragma mark -
#pragma mark other method.
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
