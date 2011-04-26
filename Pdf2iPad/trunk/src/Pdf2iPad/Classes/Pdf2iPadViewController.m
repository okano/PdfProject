//
//  Pdf2iPadViewController.m
//  Pdf2iPad
//
//  Created by okano on 10/12/04.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "Pdf2iPadViewController.h"

@implementation Pdf2iPadViewController
@synthesize imageView1, imageView2, imageView3;
@synthesize pdfURL;
@synthesize menuViewController, webViewController, /*tocViewController,*/ thumbnailScrollViewController;
@synthesize isShownTocView, isShownThumbnailScrollView;

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
	
	currentPageNum = 1;	//1-start.
	
#pragma mark (Setup ImageView, Pointer)
	//Initialized in xib file.
	//imageView1 = [[UIImageView alloc] init];
	//imageView2 = [[UIImageView alloc] init];
	//imageView3 = [[UIImageView alloc] init];
	//currentScrollView = [[UIScrollView alloc] init];
	
	//
	[pdfScrolView1 setupUiScrollView];
	[pdfScrolView2 setupUiScrollView];
	[pdfScrolView3 setupUiScrollView];
	
	//Set pointer.
	prevPdfScrollView	= pdfScrolView1;
	nextPdfScrollView	= pdfScrolView2;
	currentPdfScrollView= pdfScrolView3;
	
#pragma mark (gesture)
	//Add gesture recognizer to imageView1,2,3, scrollView.
	tapRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	tapRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	tapRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	[pdfScrolView1 addGestureRecognizer:tapRecognizer1];
	[pdfScrolView2 addGestureRecognizer:tapRecognizer2];
	[pdfScrolView3 addGestureRecognizer:tapRecognizer3];
	//
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
	[pdfScrolView1 addGestureRecognizer:swipeRecognizer1right];
	[pdfScrolView2 addGestureRecognizer:swipeRecognizer2right];
	[pdfScrolView3 addGestureRecognizer:swipeRecognizer3right];
	[pdfScrolView1 addGestureRecognizer:swipeRecognizer1left];
	[pdfScrolView2 addGestureRecognizer:swipeRecognizer2left];
	[pdfScrolView3 addGestureRecognizer:swipeRecognizer3left];
    
	//Setup Maker Pen.
    panRecognizer1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panRecognizer2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panRecognizer3 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [touchPenView addGestureRecognizer:panRecognizer1];
	
	[touchPenView setupView];
	[self loadMarkerPenFromUserDefault];
	[self setupTouchpenViewAtPage:currentPageNum];
    [self.view bringSubviewToFront:touchPenView];
	[touchPenView setNeedsDisplay];
	
	//[pdfScrolView1 addGestureRecognizer:panRecognizer1];
	//[pdfScrolView2 addGestureRecognizer:panRecognizer2];
	//[pdfScrolView3 addGestureRecognizer:panRecognizer3];
    menuBarForMakerPen = nil;   //generate when need.
    penModeLabel = nil; //generate when need.
    [self exitMarkerMode];
    
#pragma mark (Open PDF)
	//Open PDF file.
	//[self initPdfWithFilename:pdfFilename];
	//Setup maxPageNum.
	if ([self setupPdfBasicInfo] == FALSE) {
		NSLog(@"cannot get pdf infomation.");
		return;
	}
	
	//Generate Thumbnail image.
	[self generateThumbnailImage:100.0f];
	
	//Show top page.
	[self drawPageWithNumber:currentPageNum];
	[self.view setNeedsDisplay];
	
#pragma mark (MenuBar and other)
	CGRect rect;	//for change position.
	//Setup MenuBar.
	menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuView" bundle:[NSBundle mainBundle]];
	rect = menuViewController.view.frame;	//change position to bottom.
	rect.origin.y = self.view.frame.size.height - menuViewController.view.frame.size.height;
	menuViewController.view.frame = rect;
	[self.view addSubview:menuViewController.view];
	[self hideMenuBar];
	
	//Setup WebView.
	//(generate when need.)
	webViewController = nil;
	
	//Setup Links.
	linksInCurrentPage = [[NSMutableArray alloc] init];
	//[self getPdfDictionaryWithPageNum:currentPageNum];
	[self renderPageLinkAtIndex:currentPageNum];
	
	// Setup for Movie play.
	[self parseMovieDefine];
	[self renderMovieLinkAtIndex:currentPageNum];
	
	// Setup for PageJumpLink.
	[self parsePageJumpLinkDefine];
	[self renderPageJumpLinkAtIndex:currentPageNum];
	
	// Setup for InPage ScrollView.
	[self parseInPageScrollViewDefine];
	[self renderInPageScrollViewAtIndex:currentPageNum];

	// Setup for InPage Pdf.
	[self parseInPagePdfDefine];
	[self renderInPagePdfAtIndex:currentPageNum];
	
	// Setup for InPage Png image.
	[self parseInPagePngDefine];
	[self renderInPagePngAtIndex:currentPageNum];
	
	// Setup for Popover Image.
	[self parsePopoverImageDefine];
	[self renderPopoverImageLinkAtIndex:currentPageNum];
	
	// Setup TOC(Table Of Contents).
	[self parseTocDefine];
	//tocViewController = [[TocViewController alloc] initWithNibName:@"TocView" bundle:[NSBundle mainBundle]];
	//tocViewController = [[TocView alloc] initWithNibName:@"TocView" bundle:[NSBundle mainBundle]];
	/*
	tocViewController = [[TocView alloc] initWithNibName:@"TocView" bundle:[NSBundle mainBundle]];
	*/
	isShownTocView = FALSE;
	
	// Setup ThumbnailScrollView.
	thumbnailScrollViewController = [[ThumbnailScrollViewController alloc] init];
	isShownThumbnailScrollView = FALSE;
	
	// Setup Bookmark View.
	[self parseBookmarkDefine];
	bookmarkViewController = [[BookmarkViewController alloc] initWithNibName:@"BookmarkView" bundle:[NSBundle mainBundle]];
	isShownBookmarkView = FALSE;
	
	
	[self renderAllLinks];
}


#pragma mark -
#pragma mark Initialize PDF.
- (BOOL)setupPdfBasicInfo
{
	//Setup PDF filename.(chached in this clas)
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
	pdfURL = [[NSBundle mainBundle] URLForResource:pdfFilename withExtension:nil];
	[pdfURL retain]; //Owned by this class.
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
	//NSLog(@"set maxPageNum=%d", maxPageNum);
	
	//Set frame size from page1.
	CGPDFPageRef page1 = CGPDFDocumentGetPage(pdfDocument, 1);
	if (!page1) {
		NSLog(@"cannot get PDF page.");
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

- (void)generateThumbnailImage:(CGFloat)newWidth
{
	//LOG_CURRENT_METHOD;
	id pool = [ [ NSAutoreleasePool alloc] init];
	
	for (int i = 1; i <= maxPageNum; i = i + 1) {
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
	[pool release];
}


#pragma mark handle PDF infomation.
- (BOOL)isVerticalWriting
{
	return NO;
}

- (NSString*)getPageFilenameFull:(int)pageNum {
	NSString* filename = [NSString stringWithFormat:@"%@%d", PAGE_FILE_PREFIX, pageNum];
	NSString* targetFilenameFull = [[[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:PAGE_FILE_EXTENSION];
	return targetFilenameFull;
}

- (NSString*)getThumbnailFilenameFull:(int)pageNum {
	NSString* filename = [NSString stringWithFormat:@"%@%d", THUMBNAIL_FILE_PREFIX, pageNum];
	NSString* targetFilenameFull = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:THUMBNAIL_FILE_EXTENSION];
	return targetFilenameFull;
}


#pragma mark draw pdf to screen.
/**
 *
 *note:pageNum is 1-start.
 *
 */
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum
{
	//Check page range.
	if (maxPageNum < pageNum) {
		NSLog(@"illigal page fiven. pageNum=%d, maxPageNum=%d", pageNum, maxPageNum);
		return nil;
	}
	
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
		//return [self generateImageWithPageNum:pageNum];
		ImageGenerator* ig = [[ImageGenerator alloc] init];
		[ig generateImageWithPageNum:pageNum fromUrl:pdfURL pdfScale:pdfScale viewFrame:self.view.frame];
		[ig release];
		
		UIImage* pdfImage = [[UIImage alloc] initWithContentsOfFile:targetFilenameFull];
		if (pdfImage) {
			[self generateThumbnailImageFromImage:pdfImage width:THUMBNAIL_WIDTH pageNumForSave:pageNum];
			return pdfImage;
		} else {
			NSLog(@"page generate but can not open image from file. for page %d filename=%@", pageNum, targetFilenameFull);
			return nil;
		}
	}
	
	return nil;
}

- (void)generateThumbnailImageFromImage:(UIImage*)baseImage width:(CGFloat)newWidth pageNumForSave:(NSUInteger)pageNum
{
	LOG_CURRENT_METHOD;
	//Calicurate new size.
	CGFloat scale = baseImage.size.width / newWidth;
	CGSize newSize = CGSizeMake(baseImage.size.width / scale,
								baseImage.size.height / scale);
	NSLog(@"newSize=%f,%f", newSize.width, newSize.height);
	
	//Prepare new image.
	UIImage* resizedImage;
	CGInterpolationQuality quality = kCGInterpolationLow;
	
	//Resize.
	UIGraphicsBeginImageContext(newSize);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetInterpolationQuality(context, quality);
	[baseImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	resizedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	//Save to file.
	NSData *data = UIImagePNGRepresentation(resizedImage);
	NSString* targetFilenameFull = [self getThumbnailFilenameFull:pageNum];
	NSError* error = nil;
	[data writeToFile:targetFilenameFull options:NSDataWritingAtomic error:&error];
	if (error) {
		NSLog(@"thumbnail file write error. path=%@", targetFilenameFull);
		NSLog(@"error=%@, error code=%d", [error localizedDescription], [error code]);
		
	} else {
		NSLog(@"wrote thumbnail file to %@", targetFilenameFull);
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
- (void) renderPageLinkAtIndex:(NSUInteger)index
{
	//CGPDFPageRef page2 = CGPDFDocumentGetPage(pdf, index+1);
	//CGAffineTransform transform1 = aspectFit(CGPDFPageGetBoxRect(page, kCGPDFMediaBox),
	//										 CGContextGetClipBoundingBox(ctx));
	//CGContextConcatCTM(ctx, transform1);
	//CGContextDrawPDFPage(ctx, page2);
	
	//Remove old view for URL_Link.
	[linksInCurrentPage removeAllObjects];
	
	id pool = [[NSAutoreleasePool alloc] init];
	
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
	
    CGPDFArrayRef outputArray;
    if(!CGPDFDictionaryGetArray(pageDictionary, "Annots", &outputArray)) {
		//LOG_CURRENT_LINE;
		//NSLog(@"no Annots found. do nothing.");
		//Release PDFDocument.
		if (pdfDocument) {
			CGPDFDocumentRelease(pdfDocument);
			pdfDocument = nil;
		}
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
		
        CGPDFDictionaryRef annotDict;
        if(!CGPDFObjectGetValue(aDictObj, kCGPDFObjectTypeDictionary, &annotDict)) {
			[pool release];
            return;
        }
		
        CGPDFDictionaryRef aDict;
        if(!CGPDFDictionaryGetDictionary(annotDict, "A", &aDict)) {
			[pool release];
            return;
        }
		
        CGPDFStringRef uriStringRef;
        if(!CGPDFDictionaryGetString(aDict, "URI", &uriStringRef)) {
			[pool release];
            return;
        }
		
        CGPDFArrayRef rectArray;
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
		
        CGPDFInteger pageRotate = 0;
        CGPDFDictionaryGetInteger( pageDictionary, "Rotate", &pageRotate ); 
        CGRect pageRect2 = CGRectIntegral( CGPDFPageGetBoxRect( pageAd, kCGPDFMediaBox ));
        if( pageRotate == 90 || pageRotate == 270 ) {
            CGFloat temp = pageRect2.size.width;
            pageRect2.size.width = pageRect2.size.height;
            pageRect2.size.height = temp;
        }
		
		//Keep x1 < x2, y1 < y2.
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
		
		NSLog(@"original link position= (x1,y1)-(x2,y2)=(%f,%f) - (%f,%f)", x1, y1, x2, y2);
		
		//Generate frame for draw on pdf-image.
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
		
		/*
		CGRect rect = CGRectMake(x1,
								 y1,
								 fabsf(x2 - x1),
								 fabsf(y2 - y1));
		
        CGAffineTransform trans = CGAffineTransformIdentity;
        ////trans = CGAffineTransformTranslate(trans, 0, pageRect2.size.height);
        trans = CGAffineTransformTranslate(trans, 0, pageRect.size.height);
        trans = CGAffineTransformScale(trans, 1.0, -1.0);
		
        rect = CGRectApplyAffineTransform(rect, trans);
		//rect.origin.y = rect.origin.y * 0.5;
		//rect.origin.y = rect.origin.y * 2.15 - 567.0;
		rect.origin.y = rect.origin.y * 1.0 - 567.0;
		
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
		*/
		
		
		//Add subView.
		UIView* areaView = [[UIView alloc] initWithFrame:linkRect];
#if TARGET_IPHONE_SIMULATOR
		//Only show on Simulator.
		[areaView setBackgroundColor:[UIColor blueColor]];
		[areaView setAlpha:0.5f];
#else
		[areaView setAlpha:0.0f];
#endif
		
		[currentPdfScrollView addScalableSubview:areaView withNormalizedFrame:linkRect];
		
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
    //} 
	
	//Release PDFDocument.
	if (pdfDocument) {
		CGPDFDocumentRelease(pdfDocument);
		pdfDocument = nil;
	}
	//Release Autorelease pool.
	[pool release];
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
	[self renderAllLinks];
	
	/*
	NSLog(@"prev-subviews=%d, curr-subview=%d, next-subview=%d",
		  [prevPdfScrollView.subviews count],
		  [currentPdfScrollView.subviews count],
		  [nextPdfScrollView.subviews count]
		  );
	*/
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
	[self renderAllLinks];
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
	//[self.tocViewController.view removeFromSuperview];
	
	//Draw link to URL, Movie.
	[self renderAllLinks];
	
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
}

- (void)switchNextImageWithAnimationType:(NSString*)animationType
{ LOG_CURRENT_METHOD; }

- (void)renderAllLinks
{
	[self renderPageLinkAtIndex:currentPageNum];
	[self renderMovieLinkAtIndex:currentPageNum];
	[self renderPageJumpLinkAtIndex:currentPageNum];
	[self renderInPageScrollViewAtIndex:currentPageNum];
	[self renderInPagePdfAtIndex:currentPageNum];
	[self renderInPagePngAtIndex:currentPageNum];
	[self renderPopoverImageLinkAtIndex:currentPageNum];
	
	[self setupMarkerPenMenu];
	[self setupTouchpenViewAtPage:currentPageNum];
	[self renderTouchPenFromUserDefaultAtPage:currentPageNum];
	[self.view bringSubviewToFront:touchPenView];
}


#pragma mark -
#pragma mark handle Gesture.
- (void)handleTap:(UITapGestureRecognizer*)gestureRecognizer
{
	CGPoint touchedPoint = [gestureRecognizer locationInView:currentPdfScrollView.pageImageView];
	//NSLog(@"location=%@", NSStringFromCGPoint([gestureRecognizer locationInView:self.view]));
	//NSLog(@"location in scrollView = %@", NSStringFromCGPoint(touchedPoint));
	//
	//
	CGPoint touchedPointNormalize;
	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (interfaceOrientation == UIInterfaceOrientationPortrait
		||
		interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		touchedPointNormalize = CGPointMake(touchedPoint.x / currentPdfScrollView.scaleForDraw,
											touchedPoint.y / currentPdfScrollView.scaleForDraw);
	} else {
		touchedPointNormalize = CGPointMake(touchedPoint.x / currentPdfScrollView.scaleForDraw * (1024.0f / 768.0f),
											touchedPoint.y / currentPdfScrollView.scaleForDraw * (1024.0f / 768.0f));
	}
	//NSLog(@"location in scrollView normalized = %@", NSStringFromCGPoint(touchedPointNormalize));
	//NSLog(@"currentPdfScrollView.scaleForDraw=%f", currentPdfScrollView.scaleForDraw);
	
	CGPoint touchedPointInPdf = CGPointMake(touchedPoint.x / pdfScale,
											touchedPoint.y / pdfScale);
	//NSLog(@"touchedPointInPdf = %@", NSStringFromCGPoint(touchedPointInPdf));
	//NSLog(@"pdfScale = %f", pdfScale);
	
	//NSLog(@"original page =%f, %f", currentPdfScrollView.originalPageWidth, currentPdfScrollView.originalPageHeight);
	
	// Check if TocView, ImageTocView shown, then hide it.
	if (isShownTocView) {
		[self hideTocView];
		return;
	}
	if (isShownThumbnailScrollView) {
		[self hideThumbnailScrollView];
		return;
	}
	
	// Compare with URL Link in page.
	for (NSMutableDictionary* tmpDict in linksInCurrentPage) {
		NSValue* val = [tmpDict objectForKey:LINK_DICT_KEY_RECT];
		CGRect r = [val CGRectValue];
		if (CGRectContainsPoint(r, touchedPointInPdf)) {
			NSString* urlStr = [tmpDict objectForKey:LINK_DICT_KEY_URL];
			//NSLog(@"link touched. url=%@", urlStr);
			
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
			//NSLog(@"Movie Link = %@", NSStringFromCGRect(rect));
			
			if (CGRectContainsPoint(rect, touchedPointInPdf)) {
				NSString* filename = [movieInfo valueForKey:MD_MOVIE_FILENAME];
				//NSLog(@"movie link touched. filename=%@", filename);
				
				//no-continue.
				[self showMoviePlayer:filename];
				return;
			}
		}
	}
	
	// Compare with PageJumpLink in page.
	for (NSMutableDictionary* pageJumpLinkInfo in pageJumpLinkDefine) {
		int targetPageNum = [[pageJumpLinkInfo valueForKey:PJ_PAGE_NUMBER] intValue];
		if (targetPageNum == currentPageNum) {
			CGRect rect;
			rect.origin.x	= [[pageJumpLinkInfo valueForKey:PJ_PAGE_AREA_X] floatValue];
			rect.origin.y	= [[pageJumpLinkInfo valueForKey:PJ_PAGE_AREA_Y] floatValue];
			rect.size.width	= [[pageJumpLinkInfo valueForKey:PJ_PAGE_AREA_WIDTH] floatValue];
			rect.size.height= [[pageJumpLinkInfo valueForKey:PJ_PAGE_AREA_HEIGHT] floatValue];
			//NSLog(@"PageJumpLink = %@", NSStringFromCGRect(rect));
			
			if (CGRectContainsPoint(rect, touchedPointInPdf)) {
				int jumpToPage = [[pageJumpLinkInfo valueForKey:PJ_PAGE_JUMPTO] intValue];
				//NSLog(@"PageJumpLink touched. jumpToPage=%d", jumpToPage);
				
				//no-continue.
				[self switchToPage:jumpToPage];
				return;
			}
		}
	}
	
	// Compare with PopoverImage Link in page.
	for (NSMutableDictionary* popoverImageInfo in popoverImageDefine) {
		int targetPageNum = [[popoverImageInfo valueForKey:MD_PAGE_NUMBER] intValue];
		if (targetPageNum == currentPageNum) {
			CGRect rect;
			rect.origin.x	= [[popoverImageInfo valueForKey:MD_AREA_X] floatValue];
			rect.origin.y	= [[popoverImageInfo valueForKey:MD_AREA_Y] floatValue];
			rect.size.width	= [[popoverImageInfo valueForKey:MD_AREA_WIDTH] floatValue];
			rect.size.height= [[popoverImageInfo valueForKey:MD_AREA_HEIGHT] floatValue];
			
			if (CGRectContainsPoint(rect, touchedPointInPdf)) {
				NSString* filename = [popoverImageInfo valueForKey:MD_MOVIE_FILENAME];
				//NSLog(@"popoverImage link touched. filename=%@", filename);
				
				//no-continue.
				[self showPopoverImagePlayer:filename];
				return;
			}
		}
	}
	
	// Compare with in left_area, in right_area WITHOUT scale.
	CGRect leftTapArea, rightTapArea, bottomTapArea, topTapArea;
	CGFloat baseWidth, baseHeight;
	//baseWidth  = currentPdfScrollView.originalPageWidth;
	//baseHeight = currentPdfScrollView.originalPageHeight;
	//UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	//UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			baseWidth = self.view.frame.size.width;
			baseHeight = self.view.frame.size.height;
			break;		
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
		default:
			baseWidth = self.view.frame.size.height;
			baseHeight = self.view.frame.size.width;
			break;
	}
	
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
	//NSLog(@"location in currentPdfScrollView = %@", NSStringFromCGPoint(touchedPointInParentView));
	if (CGRectContainsPoint(leftTapArea, touchedPointInParentView)) {
		//NSLog(@"touch leftTapArea");
		[self handleTapInLeftArea:gestureRecognizer];
	} else if (CGRectContainsPoint(rightTapArea, touchedPointInParentView)) {
		//NSLog(@"touch rightTapArea");
		[self handleTapInRightArea:gestureRecognizer];
	} else if (CGRectContainsPoint(topTapArea, touchedPointInParentView)) {
		//NSLog(@"touch topTapArea");
		[self handleTapInTopArea:gestureRecognizer];
	} else if (CGRectContainsPoint(bottomTapArea, touchedPointInParentView)) {
		//NSLog(@"touch bottomTapArea");
		[self handleTapInBottomArea:gestureRecognizer];
	} else {
		//NSLog(@"touch other Area");
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
	[self showMenuBar];
}
- (void)handleTapInBottomArea:(UIGestureRecognizer*)gestureRecognizer
{
	[self showMenuBar];
}

- (void)handleTapInScrollView:(UIGestureRecognizer*)sender
{
	LOG_CURRENT_METHOD;
}

- (void)handleSwipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
	LOG_CURRENT_METHOD;
	//Switch to next/prev page.
	if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
		//left to right, goto next.
		[self handleTapInLeftArea:gestureRecognizer];
	} else {
		//right to left, goto prev.
		[self handleTapInRightArea:gestureRecognizer];
	}
}


//MARK: -
//MARK: Treat marker touch pen.
- (void)enterMarkerMode
{
    //Hide original menu.
    [self hideMenuBar];
    
    //Show touchpen view.
    [self.view bringSubviewToFront:touchPenView];

    //Show menu bar, label for MakerPen.
	[self setupMarkerPenMenu];
    menuBarForMakerPen.hidden = NO;
    penModeLabel.hidden = NO;
    [touchPenView addSubview:menuBarForMakerPen];    
    [touchPenView addSubview:penModeLabel];
    
    //Enable touch with view for maker.
    touchPenView.userInteractionEnabled = YES;
    
    //Enable gesture.
    panRecognizer1.enabled = YES;
    panRecognizer2.enabled = YES;
    panRecognizer3.enabled = YES;
}
- (void)setupMarkerPenMenu
{
	//MenuBar.
	CGFloat menuBarHeight = 44.0f;
    if (! menuBarForMakerPen) {
        menuBarForMakerPen = [[UIToolbar alloc] initWithFrame:CGRectZero];
		
		//Add Done button.
		UIBarButtonItem* doneButton = [[UIBarButtonItem alloc]
									   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
									   target:self 
									   action:@selector(exitMarkerMode)];
		[menuBarForMakerPen setItems:[NSArray arrayWithObject:doneButton]];
	}
	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (interfaceOrientation == UIInterfaceOrientationPortrait
		||
		interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        CGRect rect = CGRectMake(0.0f,
                                 self.view.frame.size.height - menuBarHeight, 
                                 self.view.frame.size.width,
                                 menuBarHeight);
		menuBarForMakerPen.frame = rect;
	} else {
		CGRect rect = menuBarForMakerPen.frame;
		rect.size.width = self.view.frame.size.height;
		rect.origin.y = self.view.frame.size.width - menuBarHeight;
		menuBarForMakerPen.frame = rect;
	}
	
	
	//Label.
	if (! penModeLabel) {
        //CGRect rectForLabel = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 120.0f);

        penModeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        penModeLabel.textColor = [UIColor redColor];
        penModeLabel.backgroundColor = [[UIColor alloc] initWithRed: 0.0f
                                                              green: 0.5f
                                                               blue: 1.0f
                                                              alpha: 0.3f];
        penModeLabel.font = [UIFont systemFontOfSize:72.0f];
        penModeLabel.text = @"Marker Pen Mode.";
    }
	if (interfaceOrientation == UIInterfaceOrientationPortrait
		||
		interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		CGRect rectForLabel = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 120.0f);
		penModeLabel.frame = rectForLabel;

	} else {
		//Reposition with rotate.
		CGRect rectForLabel = CGRectMake(0.0f, 0.0f, self.view.frame.size.height, 120.0f);
		penModeLabel.frame = rectForLabel;
	}
}

- (void)exitMarkerMode
{
    //Hide menu bar for marker pen.
    if (menuBarForMakerPen) {
        menuBarForMakerPen.hidden = YES;
    }
    if (penModeLabel) {
        penModeLabel.hidden = YES;
    }
    //
    panRecognizer1.enabled = NO;
    panRecognizer2.enabled = NO;
    panRecognizer3.enabled = NO;
    //
    touchPenView.userInteractionEnabled = NO;
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    //LOG_CURRENT_METHOD;
    //

    if (! markerPenArray) {
        markerPenArray = [[NSMutableArray alloc] init];
    }
    if (! linePointArray) {
        linePointArray = [[NSMutableArray alloc] init];
    }
    
    CGPoint touchedPoint;
	//LOG_CURRENT_METHOD;
	if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
        //NSLog(@"Possible");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        //NSLog(@"Began");
		
		//Setup line info on TouchPenView.
		[touchPenView willStartAddLine];
		
		//Create new array.
        linePointArray = [[NSMutableArray alloc] init];
		
		//Add Point into array.
		CGPoint p = [gestureRecognizer locationInView:self.view];
        [linePointArray addObject:NSStringFromCGPoint(p)];
		
	} else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        //NSLog(@"Changed");
        touchedPoint = [gestureRecognizer locationInView:self.view];
		
		//Add line info on TouchPenView.
		[touchPenView addLineWithPoint:touchedPoint];
		[touchPenView setNeedsDisplay];
		
		//Add Point into array.
		CGPoint p = [gestureRecognizer locationInView:self.view];
        [linePointArray addObject:NSStringFromCGPoint(p)];
		
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        //NSLog(@"Ended");
        
        touchedPoint = [gestureRecognizer locationInView:self.view];
        /*
		//[touchedPointsForMakerPen addObject:[NSValue valueWithCGPoint:touchedPoint]];
        //
        //[(TouchPenView*)(self.view) addLineInfoWithArray:touchedPointsForMakerPen];
        
        [touchPenView addLineInfoFrom:prevTouchPointForMakerPen
                                                 to:touchedPoint];
        [self renderTouchPen];
        */
        
		//Add line info on TouchPenView.
		[touchPenView addLineWithPoint:touchedPoint];
		[touchPenView didEndAddLine];
		
        //Refresh marker view.
        [self renderTouchPenFromUserDefaultAtPage:currentPageNum];
		
		//Add Point into array.
		CGPoint p = [gestureRecognizer locationInView:self.view];
        [linePointArray addObject:NSStringFromCGPoint(p)];
		
		
		//Generate dictionary for add array.
		NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
		[tmpDict setValue:[NSNumber numberWithInt:currentPageNum] forKey:MARKERPEN_PAGE_NUMBER];
		[tmpDict setValue:@"" forKey:MARKERPEN_COMMENT];
		[tmpDict setValue:linePointArray forKey:MARKERPEN_POINT_ARRAY];
		[markerPenArray addObject:tmpDict];
		
        //Save to UserDefault.
        [self saveMarkerPenToUserDefault];

	} else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"pan gesture Cancelled");
	} else if (gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        NSLog(@"pan gesture Failed");
    }
}

/**
 *argument:lineInfoArray is Array of CGPointValue.
 */
/*
- (void)saveMarkerWithCurrentPageWithArray:(NSArray*)lineInfoArray
{
	//Convert CGPoint array to NSString array for store NSUserDefault.
	NSMutableArray* lineInfoStrArray = [[NSMutableArray alloc] init];
	for (id obj in lineInfoArray) {
		if (![obj isKindOfClass:[NSValue class]]) {
			LOG_CURRENT_LINE;
			NSLog(@"illigal marker pen infomation. class=%@", [obj class]);
			continue;
		}
		NSString* pointStr = NSStringFromCGPoint([obj CGPointValue]);
		[lineInfoStrArray addObject:pointStr];
	}
	
	//Generate marker pen item with current pageNum.
    NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
    [tmpDict setObject:[NSNumber numberWithInt:currentPageNum] forKey:MARKERPEN_PAGE_NUMBER];
    //[tmpDict setObject:lineInfoArray forKey:MARKERPEN_LINE_ARRAY];
    [tmpDict setObject:lineInfoStrArray forKey:MARKERPEN_LINE_ARRAY];
    [tmpDict setObject:@"" forKey:MARKERPEN_COMMENT];
    
    //Marge marker pen infomation with saved data in UserDefault.
    NSArray* savedInfo = [self loadMarkerWithCurrentPage];
    NSMutableArray* arrayForSave = [[NSMutableArray alloc] initWithArray:savedInfo];
    [arrayForSave addObject:tmpDict];
	
	//Store marker pen infomation to UserDefault.
	NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
	[userDefault setObject:arrayForSave forKey:MARKERPEN_ARRAY];
	//[userDefault setObject:@"test save1" forKey:MARKERPEN_ARRAY];
	
    BOOL result;
	result = [userDefault synchronize];
    NSLog(@"save result=%d, YES=%d, NO=%d", result, YES, NO);
}
*/

- (void)saveMarkerPenToUserDefault
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"before save: markerPenArray=%@", [markerPenArray description]);

	if (! markerPenArray) {
		return;
	}
	
	//Store marker pen infomation to UserDefault.
	NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
	[userDefault setObject:markerPenArray forKey:MARKERPEN_ARRAY];
}

- (NSArray*)loadMarkerWithCurrentPage
{
	//LOG_CURRENT_METHOD;
    //load from UserDefault.
    NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	id obj = [settings valueForKey:MARKERPEN_ARRAY];
	if (!obj) {		//no markerpen exists.
        NSLog(@"no markerpen infomation in UserDefault.");
		return nil;
	}
	if (![obj isKindOfClass:[NSArray class]]) {
		NSLog(@"illigal marker pen infomation. class=%@", [obj class]);
		return NO;
	}
    
	//Pickup only line in this page.
	NSMutableArray* resultArray =[[NSMutableArray alloc] init];
	//Add line info from UserDefault to touchPenView.
	for (NSMutableDictionary* markerInfo in obj) {
		int targetPageNum = [[markerInfo valueForKey:MARKERPEN_PAGE_NUMBER] intValue];
		if (targetPageNum == currentPageNum) {
			[resultArray addObject:markerInfo];
		}
	}
	//NSLog(@"%d object in page %d", [resultArray count], currentPageNum);
	
    return resultArray;
}

- (void)loadMarkerPenFromUserDefault
{
	//LOG_CURRENT_METHOD;
	//load from UserDefault.
    NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	
	id obj = [settings valueForKey:MARKERPEN_ARRAY];
	if (!obj) {		//no markerpen exists.
        NSLog(@"no markerpen infomation in UserDefault.");
		return;
	}
	if (![obj isKindOfClass:[NSArray class]]) {
		NSLog(@"illigal marker pen infomation. class=%@", [obj class]);
		return;
	}

	if (! markerPenArray) {
		markerPenArray = [[NSMutableArray alloc] init];
	}
	[markerPenArray addObjectsFromArray:obj];
	
	//NSLog(@"loaded. markerPenArray=%@", [markerPenArray description]);
}


/*
- (void)renderTouchPenAtIndex:(NSUInteger)index
{
    [touchPenView setNeedsDisplay];
    [self.view bringSubviewToFront:touchPenView];
}
*/

- (void)renderTouchPenFromUserDefaultAtPage:(NSUInteger)pageNum
{
	//LOG_CURRENT_METHOD;
    //has been Readed marker pen infomation.
	if (! markerPenArray) {
		NSLog(@"no marker pen info at page %d.", pageNum);
		return;
	}
	/*
	//
    [touchPenView clearLine];
    
    //Add line info from UserDefault to touchPenView.
    for (id obj in markerPenArray) {
		
		if (!obj) {
			continue;
		}
		if (![obj isKindOfClass:[NSArray class]]) {
			continue;
		}
		
		NSMutableDictionary* markerInfo = [[NSMutableDictionary alloc] initWithDictionary:obj];
		
		int targetPageNum = [[markerInfo valueForKey:MARKERPEN_PAGE_NUMBER] intValue];
		if (targetPageNum == pageNum) {
			[touchPenView addLinesWithDictionary:markerInfo];
		}
    }
	*/
	[touchPenView setNeedsDisplay];
}


- (void)setupTouchpenViewAtPage:(NSUInteger)pageNum
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"markerPenArray=%@", [markerPenArray description]);
	
	
	[touchPenView clearLine];
	
    //Add line info from UserDefault to touchPenView.
    for (id obj in markerPenArray) {
		if (!obj) {
			continue;
		}
		if (! [obj isKindOfClass:[NSDictionary class]]) {
			NSLog(@"Illigal markerPenArray.");
			continue;
		}
		
		NSMutableDictionary* markerInfo = [[NSMutableDictionary alloc] initWithDictionary:obj];
		
		int targetPageNum = [[markerInfo valueForKey:MARKERPEN_PAGE_NUMBER] intValue];
		if (targetPageNum == pageNum) {
			[touchPenView addLinesWithDictionary:markerInfo];
		}
    }
}

- (void)clearTouchPenView 
{
	[touchPenView clearLine];
	[touchPenView setNeedsDisplay];
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
			//UIView* areaView = [[UIView alloc] initWithFrame:rect];
			UIView* areaView = [[UIView alloc] initWithFrame:touchableArea];
			
#if TARGET_IPHONE_SIMULATOR
			//Only show on Simulator.
			[areaView setBackgroundColor:[UIColor yellowColor]];
			[areaView setAlpha:0.2f];
#else
			[areaView setAlpha:0.0f];
#endif
			
			//[currentPdfScrollView addSubview:areaView];
			//[currentPdfScrollView addScalableSubview:areaView withNormalizedFrame:rect];
			[currentPdfScrollView addScalableSubview:areaView withNormalizedFrame:touchableArea];
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
#pragma mark Treat page jump link.
//Parse PageJumpLink Define.
- (BOOL)parsePageJumpLinkDefine
{
	pageJumpLinkDefine = [[NSMutableArray alloc] init];
	
	NSMutableDictionary* tmpDict;
	
	//parse csv file.
	NSString* csvFilePath = [[NSBundle mainBundle] pathForResource:@"pageJumpLinkDefine" ofType:@"csv"];
	NSError* error;
	NSString* text = [NSString stringWithContentsOfFile:csvFilePath encoding:NSUTF8StringEncoding error:&error];
	/*
	if (error) {
		NSLog(@"error=%@, error code=%d", [error localizedDescription], [error code]);
		return FALSE;
	}
	*/
	
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
		}
		
		tmpDict = [[NSMutableDictionary alloc] init];
		//Page Number.(From)
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:0] intValue]] forKey:PJ_PAGE_NUMBER];
		//Position.
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:1] intValue]] forKey:PJ_PAGE_AREA_X];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:2] intValue]] forKey:PJ_PAGE_AREA_Y];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:3] intValue]] forKey:PJ_PAGE_AREA_WIDTH];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:4] intValue]] forKey:PJ_PAGE_AREA_HEIGHT];
		//Page Number.(Jump TO)
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:5] intValue]] forKey:PJ_PAGE_JUMPTO];
		
		[pageJumpLinkDefine addObject:tmpDict];
	}
	//
	
	return ! hasError;
}

- (void) renderPageJumpLinkAtIndex:(NSUInteger)index
{
	for (NSMutableDictionary* pageJumpLinkInfo in pageJumpLinkDefine) {
		int targetPageNum = [[pageJumpLinkInfo valueForKey:PJ_PAGE_NUMBER] intValue];
		if (targetPageNum == index) {
			CGRect rect;
			rect.origin.x	= [[pageJumpLinkInfo valueForKey:PJ_PAGE_AREA_X] floatValue];
			rect.origin.y	= [[pageJumpLinkInfo valueForKey:PJ_PAGE_AREA_Y] floatValue];
			rect.size.width	= [[pageJumpLinkInfo valueForKey:PJ_PAGE_AREA_WIDTH] floatValue];
			rect.size.height= [[pageJumpLinkInfo valueForKey:PJ_PAGE_AREA_HEIGHT] floatValue];
			//int jumpToPage	= [[pageJumpLinkInfo valueForKey:PJ_PAGE_JUMPTO] floatValue];
			//NSLog(@"rect for pageJumpLink=%@, jumpto=%d", NSStringFromCGRect(rect), jumpToPage);
			
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
			//NSLog(@"rect for pageJumpLink arranged=%@", NSStringFromCGRect(touchableArea));
			//NSLog(@"pdfScale=%f", pdfScale);
			
			
			//Show pageJumpLink link area with half-opaque.
			//UIView* areaView = [[UIView alloc] initWithFrame:rect];
			UIView* areaView = [[UIView alloc] initWithFrame:touchableArea];
			
#if TARGET_IPHONE_SIMULATOR
			//Only show on Simulator.
			[areaView setBackgroundColor:[UIColor purpleColor]];
			[areaView setAlpha:0.2f];
#else
			[areaView setAlpha:0.0f];
#endif
			
			//[currentPdfScrollView addSubview:areaView];
			//[currentPdfScrollView addScalableSubview:areaView withNormalizedFrame:rect];
			[currentPdfScrollView addScalableSubview:areaView withNormalizedFrame:touchableArea];
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
			//NSLog(@"rect for ipsvScrollView=%@", NSStringFromCGRect(rect));
			//(filename(s))
			NSMutableArray* filenames = (NSMutableArray*)[ipsvInfo objectForKey:IPSD_FILENAMES];
			
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
			
			//Show ScrollView.
			UIScrollView* ipsvScrollView = [[UIScrollView alloc] initWithFrame:rect];
			ipsvScrollView.backgroundColor = IPSD_BACKGROUND_COLOR;
			ipsvScrollView.pagingEnabled = YES;
			ipsvScrollView.bounces = NO;
			ipsvScrollView.alwaysBounceVertical = NO;
			ipsvScrollView.alwaysBounceHorizontal = YES;
			ipsvScrollView.scrollIndicatorInsets = UIEdgeInsetsFromString(IPSD_SCROLL_INDICATOR_INSET_STRING);
			ipsvScrollView.userInteractionEnabled = YES;
			float x_space = 0.0f;
			float x_offset = 0 + x_space;
			float y_space = 0.0f;
			float y_maxHeight = 0.0f;
			for (NSString* filename in filenames) {
				//Add each image.
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
				
				//Add white-space under ScrollBar.
				CGFloat scrollBarInsetMinus = 10.0f;

				//fit to ScrollView-Height.
				CGFloat scaleWithHeight = (rect.size.height - scrollBarInsetMinus) / image.size.width;	//scale for fit Height with ScrollView.
				//Streatch images when Landscape mode.
				CGRect rectForStretchImage = CGRectMake(0.0f,
														0.0f,
														image.size.width * pdfScale * scaleWithHeight,
														image.size.height * pdfScale * scaleWithHeight);
				UIGraphicsBeginImageContextWithOptions(rectForStretchImage.size, NO, 0.0f);
				[image drawInRect:rectForStretchImage];
				UIImage* shrinkedImage = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();
				[image release];
				image = shrinkedImage;
				
				//Add with UIImageView.
				UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
				CGRect rectForImageView = imageView.frame;
				rectForImageView.origin.x = x_offset;
				rectForImageView.origin.y = y_space;
				imageView.frame = rectForImageView;
				[imageView retain];
				
				//Add images to ScrollView.
				[ipsvScrollView addSubview:imageView];
				
				//move offset.
				x_offset = x_offset + image.size.width + x_space;
				if (y_maxHeight < image.size.height) {
					y_maxHeight = image.size.height;
				}
			}
			ipsvScrollView.contentSize = CGSizeMake(x_offset, y_maxHeight);
			
			//[currentPdfScrollView addSubview:ipsvScrollView];
			//[currentPdfScrollView addScalableSubview:ipsvScrollView withNormalizedFrame:rect];
			[currentPdfScrollView addScalableSubview:ipsvScrollView withNormalizedFrame:touchableArea];
			[ipsvScrollView flashScrollIndicators];
		}
	}
}

#pragma mark -
#pragma mark Treat InPage Pdf.
//Parse InPage Pdf Define.
- (BOOL)parseInPagePdfDefine
{
	inPagePdfDefine = [[NSMutableArray alloc] init];
	
	NSMutableDictionary* tmpDict;
	
	//parse csv file.
	NSString* csvFilePath = [[NSBundle mainBundle] pathForResource:@"inPagePdfDefine" ofType:@"csv"];
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
		}
		
		tmpDict = [[NSMutableDictionary alloc] init];
		//Page Number.
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:0] intValue]] forKey:IPPD_PAGE_NUMBER];
		//Position.
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:1] intValue]] forKey:IPPD_AREA_X];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:2] intValue]] forKey:IPPD_AREA_Y];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:3] intValue]] forKey:IPPD_AREA_WIDTH];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:4] intValue]] forKey:IPPD_AREA_HEIGHT];
		//Filename.
		NSString* tmpStr = [tmpCsvArray objectAtIndex:5];
		NSString* tmpStrWithoutDoubleQuote = [tmpStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x22] withString:@""];	/* delete DoubleQuote. */
		//NSString* tmpStrURLEncoded = [tmpStrWithoutDoubleQuote stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		//[tmpDict setValue:tmpStrURLEncoded forKey:MD_MOVIE_FILENAME];
		[tmpDict setValue:tmpStrWithoutDoubleQuote forKey:IPPD_FILENAME];
		
		[inPagePdfDefine addObject:tmpDict];
	}
	//
	return ! hasError;
}

- (BOOL) renderInPagePdfAtIndex:(NSUInteger)index
{
	return NO;	//do nothing.
	
	for (NSMutableDictionary* ippInfo in inPagePdfDefine) {
		int targetPageNum = [[ippInfo valueForKey:IPPD_PAGE_NUMBER] intValue];
		if (targetPageNum == index) {
			//(area)
			CGRect rect;
			rect.origin.x	= [[ippInfo valueForKey:IPPD_AREA_X] floatValue];
			rect.origin.y	= [[ippInfo valueForKey:IPPD_AREA_Y] floatValue];
			rect.size.width	= [[ippInfo valueForKey:IPPD_AREA_WIDTH] floatValue];
			rect.size.height= [[ippInfo valueForKey:IPPD_AREA_HEIGHT] floatValue];
			//(filename(s))
			//NSString* filename = (NSString*)[ippInfo objectForKey:IPPD_FILENAME];
			
			/*
			//Show by UIImageView.
			CGPDFDocumentRef ippPdf;
			CGPDFPageRef ippPage;
			CGRect ippPageRect;
			CGFloat ippPdfScale;
			int pageNum = 1;
			
			//Open pdf file.
			NSURL *pdfURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
			if (!pdfURL) {
				NSLog(@"PDF file not exist. filename=%@", filename);
				return NO;
			}
			ippPdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
			if (!ippPdf) {
				NSLog(@"PDF file cannot open. filename=%@", filename);
				return NO;
			}
			
			//Set frame size from page1.
			ippPage = CGPDFDocumentGetPage(ippPdf, 1);
			ippPageRect = CGPDFPageGetBoxRect(ippPage, kCGPDFMediaBox);
			ippPdfScale = 1.0f;	//self.view.frame.size.width / ippPageRect.size.width;
			ippPageRect.size = CGSizeMake(ippPageRect.size.width*ippPdfScale, ippPageRect.size.height*ippPdfScale);
			
			
			// Create a low res image representation of the PDF page to display before the TiledPDFView
			// renders its content.
			UIGraphicsBeginImageContext(ippPageRect.size);
			
			CGContextRef context = UIGraphicsGetCurrentContext();
			
			// First fill the background with white.
			CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
			CGContextFillRect(context, ippPageRect);
			
			CGContextSaveGState(context);
			// Flip the context so that the PDF page is rendered
			// right side up.
			CGContextTranslateCTM(context, 0.0, ippPageRect.size.height);
			CGContextScaleCTM(context, 1.0, -1.0);
			
			// Scale the context so that the PDF page is rendered 
			// at the correct size for the zoom level.
			CGContextScaleCTM(context, ippPdfScale, ippPdfScale);	
			
			ippPage = CGPDFDocumentGetPage(ippPdf, pageNum);
			if (! ippPage) {
				NSLog(@"illigal page. source line=%d, pageNum=%d", __LINE__, pageNum);
				return NO;
			}
			
			CGPDFPageRetain(ippPage);	////
			CGContextDrawPDFPage(context, ippPage);
			CGContextRestoreGState(context);
			
			UIImage *ippPdfImage = UIGraphicsGetImageFromCurrentImageContext();
			[ippPdfImage retain];//(needs count down in calling method.)
			
			UIGraphicsEndImageContext();
			if (! ippPdfImage) {
				NSLog(@"UIGraphicsGetImageFromCurrentImageContext returns nil.");
			}
				
				
				
			UIImageView* imageView = [[UIImageView alloc] initWithImage:ippPdfImage];
			imageView.frame = rect;
			[imageView retain];
			[currentPdfScrollView addScalableSubview:imageView withNormalizedFrame:imageView.frame];
			*/
			//Show by MyPdfScrollView.
			MyPdfScrollView* ippPdfScrollView = [[MyPdfScrollView alloc] init];
			//[ippPdfScrollView initPdfWithFilename:filename];
			[ippPdfScrollView setupWithPageNum:1];
			[ippPdfScrollView setBounces:NO];
			[ippPdfScrollView setBackgroundColor:[UIColor whiteColor]];
			
			UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
			if (interfaceOrientation == UIInterfaceOrientationPortrait
				||
				interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
				[ippPdfScrollView setupCurrentPageWithSize:rect.size];
			} else {
				CGSize sizeForLandscape = CGSizeMake(rect.size.width * (1024.0f / 768.0f),
													 rect.size.height * (1024.0f / 768.0f));
				[ippPdfScrollView setupCurrentPageWithSize:sizeForLandscape];
			}
			[currentPdfScrollView addScalableSubview:ippPdfScrollView withNormalizedFrame:rect];
			[ippPdfScrollView flashScrollIndicators];
		}
		//[currentPdfScrollView addScalableSubview:ipsvScrollView withNormalizedFrame:rect];
	}
	return YES;
}


#pragma mark -
#pragma mark Treat InPage Png Image.
//Parse InPage Png Define.
- (BOOL)parseInPagePngDefine
{
	inPagePngDefine = [[NSMutableArray alloc] init];
	
	NSMutableDictionary* tmpDict;
	
	//parse csv file.
	NSString* csvFilePath = [[NSBundle mainBundle] pathForResource:@"inPagePngDefine" ofType:@"csv"];
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
		}
		
		tmpDict = [[NSMutableDictionary alloc] init];
		//Page Number.
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:0] intValue]] forKey:IPPD_PAGE_NUMBER];
		//Position.
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:1] intValue]] forKey:IPPD_AREA_X];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:2] intValue]] forKey:IPPD_AREA_Y];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:3] intValue]] forKey:IPPD_AREA_WIDTH];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:4] intValue]] forKey:IPPD_AREA_HEIGHT];
		//Filename.
		NSString* tmpStr = [tmpCsvArray objectAtIndex:5];
		NSString* tmpStrWithoutDoubleQuote = [tmpStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x22] withString:@""];	/* delete DoubleQuote. */
		//NSString* tmpStrURLEncoded = [tmpStrWithoutDoubleQuote stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		//[tmpDict setValue:tmpStrURLEncoded forKey:MD_MOVIE_FILENAME];
		[tmpDict setValue:tmpStrWithoutDoubleQuote forKey:IPPD_FILENAME];
		
		[inPagePngDefine addObject:tmpDict];
	}
	//
	return ! hasError;
}

- (BOOL) renderInPagePngAtIndex:(NSUInteger)index
{
	for (NSMutableDictionary* ippInfo in inPagePngDefine) {
		int targetPageNum = [[ippInfo valueForKey:IPPD_PAGE_NUMBER] intValue];
		if (targetPageNum == index) {
			//(area)
			CGRect rect;
			rect.origin.x	= [[ippInfo valueForKey:IPPD_AREA_X] floatValue];
			rect.origin.y	= [[ippInfo valueForKey:IPPD_AREA_Y] floatValue];
			rect.size.width	= [[ippInfo valueForKey:IPPD_AREA_WIDTH] floatValue];
			rect.size.height= [[ippInfo valueForKey:IPPD_AREA_HEIGHT] floatValue];
			//(filename)
			NSString* filename = (NSString*)[ippInfo objectForKey:IPPD_FILENAME];
			
			//Open png image file.
			UIImage* image = nil;
			if (filename) {
				// Open image from mainBundle.
				image = [UIImage imageNamed:filename];
				if (! image) {
					LOG_CURRENT_METHOD;
					LOG_CURRENT_LINE;
					NSLog(@"file not found in mainBundle, filename=%@", filename);
					continue;	//skip to next object.
				}
			}
			UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
			
			//Show by UIScrollView.
			UIScrollView* inPagePngScrollView = [[UIScrollView alloc] initWithFrame:rect];
			[inPagePngScrollView setBounces:NO];
			[inPagePngScrollView addSubview:imageView];
			inPagePngScrollView.contentSize = image.size;
			
			[currentPdfScrollView addScalableSubview:inPagePngScrollView withNormalizedFrame:rect];
			[inPagePngScrollView flashScrollIndicators];
			
			//Set Delegate for zoom.
			inPagePngScrollView.delegate = self;
			
			//Set ZoomScale.
			CGFloat scaleFitWidth;
			//UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
			//if (interfaceOrientation == UIInterfaceOrientationPortrait
			//	||
			//	interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			//	scaleFitWidth = rect.size.width / image.size.width;
			//} else {
			//	//scaleFitWidth = rect.size.height / image.size.height;
			//	////scaleFitWidth = rect.size.width / image.size.width / currentPdfScrollView.scaleForDraw;
			//	scaleFitWidth = rect.size.width / image.size.width;
			//}
			scaleFitWidth = rect.size.width / image.size.width;
			
			inPagePngScrollView.minimumZoomScale = scaleFitWidth;
			inPagePngScrollView.maximumZoomScale = 8.0f;
			inPagePngScrollView.zoomScale = scaleFitWidth;
			
			//NSLog(@"contentSize=%@", NSStringFromCGSize( inPagePngScrollView.contentSize));
			//NSLog(@"zoomScale=%f", inPagePngScrollView.zoomScale);
			//NSLog(@"zooming=%d", inPagePngScrollView.zooming);
			//NSLog(@"currentPdfScrollView.scaleForDraw=%f", currentPdfScrollView.scaleForDraw);
		}
	}
	return YES;
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	if (0 < [[scrollView subviews] count]) {
		return [[scrollView subviews] objectAtIndex:0];
	} else {
		return nil;
	}
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	return;
}

#pragma mark -
#pragma mark Treat Popover Image.
//Parse PopoverImage Define. (like MovieDefine.)
- (BOOL)parsePopoverImageDefine
{
	popoverImageDefine = [[NSMutableArray alloc] init];
	
	NSMutableDictionary* tmpDict;
	
	//parse csv file.
	NSString* csvFilePath = [[NSBundle mainBundle] pathForResource:@"popoverImageDefine" ofType:@"csv"];
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
		
		[popoverImageDefine addObject:tmpDict];
	}
	//
	
	return ! hasError;
}

- (void) renderPopoverImageLinkAtIndex:(NSUInteger)index
{
	//LOG_CURRENT_METHOD;
	for (NSMutableDictionary* popoverImageInfo in popoverImageDefine) {
		int targetPageNum = [[popoverImageInfo valueForKey:MD_PAGE_NUMBER] intValue];
		if (targetPageNum == index) {
			//NSString* filename = [movieInfo valueForKey:MD_MOVIE_FILENAME];
			CGRect rect;
			rect.origin.x	= [[popoverImageInfo valueForKey:MD_AREA_X] floatValue];
			rect.origin.y	= [[popoverImageInfo valueForKey:MD_AREA_Y] floatValue];
			rect.size.width	= [[popoverImageInfo valueForKey:MD_AREA_WIDTH] floatValue];
			rect.size.height= [[popoverImageInfo valueForKey:MD_AREA_HEIGHT] floatValue];
			
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
			//NSLog(@"rect for PopoverImageLink arranged=%@", NSStringFromCGRect(touchableArea));
			//NSLog(@"pdfScale=%f", pdfScale);
			
			//Show Movie link area with half-opaque.
			UIView* areaView = [[UIView alloc] initWithFrame:touchableArea];
#if TARGET_IPHONE_SIMULATOR
			//Only show on Simulator.
			[areaView setBackgroundColor:[UIColor greenColor]];
			[areaView setAlpha:0.2f];
#else
			[areaView setAlpha:0.0f];
#endif
			
			//[currentPdfScrollView addSubview:areaView];
			[currentPdfScrollView addScalableSubview:areaView withNormalizedFrame:touchableArea];
		}
	}
}

- (void)showPopoverImagePlayer:(NSString*)filename
{
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

	PopoverImageViewController* psivc;
	psivc = [[PopoverImageViewController alloc] initWithImageFilename:filename frame:rect];
	//Save scrollView position, zoomScale.
	[psivc setParentScrollView:currentPdfScrollView
				  fromPosition:currentPdfScrollView.contentOffset
				 fromZoomScale:currentPdfScrollView.zoomScale];
	
	//
	[currentPdfScrollView setContentOffset:CGPointZero];
	[currentPdfScrollView setZoomScale:currentPdfScrollView.minimumZoomScale];
	[currentPdfScrollView setScrollEnabled:NO];
	
	//
	[currentPdfScrollView addSubview:psivc.view];
	return;
	
	
	//Hide(clear) marker pen.
	[self clearTouchPenView];
}

#if 0==1
- (void)hidePopoverImagePlayer
{
	LOG_CURRENT_METHOD;
	//Close.
	//[self dismissModalViewControllerAnimated:YES];
	
	//Close(Subview) with class of UIScrollView.
	NSArray* views = currentPdfScrollView.subviews;
	for (UIView* v in views) {
		NSLog(@"view class is %@", [v class]);
		if ([v isKindOfClass:[UIScrollView class]]) {
			
			//Show PopoverView.(Subview, CATransitionAnimation)
			CATransition* animation1 = [CATransition animation];
			[animation1 setDelegate:self];
			[animation1 setDuration:PAGE_ANIMATION_DURATION_NEXT];
			[animation1 setTimingFunction:UIViewAnimationCurveEaseInOut];
			[animation1 setType:kCATransitionFade];
			//[animation1 setSubtype:kCATransitionFromTop];
			[[self.view layer] addAnimation:animation1 forKey:@"animation_Hide_PopoverView"];
			[v removeFromSuperview];
			NSLog(@"removed from superView.");
			if ([v isKindOfClass:[PopoverImageViewController class]]) {
				[(PopoverImageViewController*)v repositionParentScrollView];
			} 
			
			/*
			//Hide PopoverView.(Subview, UIView-BlockBasedAnimation)
			[UIView beginAnimations:@"flip" context:nil];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDuration:1.5];
			[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:currentPdfScrollView.superview cache:NO];
			[v removeFromSuperview];
			[UIView commitAnimations];
			 */
		}
	}
	
	[self drawPageWithNumber:currentPageNum];
	[self renderAllLinks];
	
	[thumbnailScrollViewController setupViewFrame];
	[thumbnailScrollViewController setupScrollViewFrame];
	[bookmarkViewController setupViewFrame];
}
#endif

#pragma mark -
#pragma mark Treat TOC.
- (BOOL)parseTocDefine
{
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
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
		[appDelegate.tocDefine addObject:tmpDict];
	}
	return ! hasError;
}

/*
- (void)showTocView
{
	[self.view addSubview:tocViewController.view];
}
*/
- (void)hideTocView {
	[menuViewController hideTocView];
	//[tocViewController.view removeFromSuperview];
}
#pragma mark -
- (void)showThumbnailScrollView {
	//Setup with tocDefine.
	[thumbnailScrollViewController setupImages];
	
	
	//Show by addSubview.
	[self.view addSubview:thumbnailScrollViewController.view];
	[self.view bringSubviewToFront:thumbnailScrollViewController.view];
	
	//Set flag.
	isShownThumbnailScrollView = TRUE;
}
- (void)hideThumbnailScrollView {
	//Hide by removeSuperView.
	[thumbnailScrollViewController.view removeFromSuperview];
	isShownThumbnailScrollView = FALSE;
}
#pragma mark -
- (BOOL)parseBookmarkDefine
{
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
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
- (void)showBookmarkView
{
	[self.view addSubview:bookmarkViewController.view];
	//[tocViewController reloadDataForce];
	[bookmarkViewController reloadDataForce];
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
{
	[self showWebView:MENU_INFO_URL];
	return;
}
- (void)showHelpView {
	//[self showPopoverImagePlayer:HELP_SCREEN_IMAGE];
	[self showWebView:MENU_HELP_URL];
	return;
}
- (void)showWebView:(NSString*)urlString
{
	LOG_CURRENT_METHOD;
	NSLog(@"urlString = %@", urlString);
	
	//[webViewController loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
	
	if (webViewController) {
		webViewController.webView.delegate = nil;	//set nil before release bcause of ASync-load.
		[webViewController release];
		webViewController = nil;
	}
	webViewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:[NSBundle mainBundle]];
	
	//re-config frame size of WebView every show. (think of show-rotate-show.)
	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
		||
		interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		//
		CGRect rect = self.view.frame;
		rect.size.width = self.view.frame.size.height;
		rect.size.height = self.view.frame.size.width;
		webViewController.view.frame = rect;
	} else {
		//CGRect rect = self.view.frame;
		//rect.size.width = self.view.frame.size.height;
		//rect.size.height = self.view.frame.size.width;
		webViewController.view.frame = self.view.frame;
	}

	[self.view addSubview:webViewController.view];
	
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webViewController.webView loadRequest:request];
	
}
- (void)gotoTopPage {
	[self switchToPage:MENU_TOP_PAGE_NUMBER];
}
- (void)gotoCoverPage {
	[self switchToPage:MENU_COVER_PAGE_NUMBER];
}


#pragma mark -
#pragma mark Handle Rotate.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
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
		[self hideThumbnailScrollView];
		if (1 < currentPageNum) {
			[prevPdfScrollView setupCurrentPageWithSize:newSize];
		}
		[currentPdfScrollView setupCurrentPageWithSize:newSize];
		if (currentPageNum < maxPageNum) {
			[nextPdfScrollView setupCurrentPageWithSize:newSize];
		}
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self renderAllLinks];
	
	[thumbnailScrollViewController setupViewFrame];
	[thumbnailScrollViewController setupScrollViewFrame];
	[bookmarkViewController setupViewFrame];
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
