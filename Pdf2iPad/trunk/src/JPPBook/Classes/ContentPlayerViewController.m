//
//  Pdf2iPadViewController.m
//  Pdf2iPad
//
//  Created by okano on 10/12/04.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "ContentPlayerViewController.h"

@implementation ContentPlayerViewController
@synthesize imageView1, imageView2, imageView3;
@synthesize pdfURL;
@synthesize menuViewController, webViewController, /*tocViewController,*/ thumbnailScrollViewController;
@synthesize isShownTocView, isShownThumbnailScrollView;
@synthesize isMarkerPenMode;
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
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle contentId:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	currentContentId = cid;
	return [self initWithNibName:nibName bundle:nibBundle];
}

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
	pdfScrolView1.currentContentId = currentContentId;
	pdfScrolView2.currentContentId = currentContentId;
	pdfScrolView3.currentContentId = currentContentId;
	
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
    
	//Gesture for MarkerPen.
	panRecognizer1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan2:)];
	panRecognizer2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan2:)];
	panRecognizer3 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan2:)];
	[pdfScrolView1 addGestureRecognizer:panRecognizer1];
	[pdfScrolView2 addGestureRecognizer:panRecognizer2];
	[pdfScrolView3 addGestureRecognizer:panRecognizer3];
	
	//Setup Maker Pen.
	[self loadMarkerPenFromUserDefault];
	[self setupMarkerPenView];
	[self setupMarkerPenMenu];
	[self exitMarkerMode];
    
#pragma mark (Open PDF)
	//Open PDF file.
	//[self initPdfWithFilename:pdfFilename];
	//Setup maxPageNum.
	BOOL errorInSetupPdfBasicInfo = NO;	//***use before exit "viewDidLoad"!.
	if ([self setupPdfBasicInfo] == FALSE) {
		NSLog(@"cannot get pdf infomation.");
		//Show alert.
		UIAlertView *alert = [[[UIAlertView alloc]
							   initWithTitle:nil
							   message:@"cannot open pdf file."
							   delegate:self
							   cancelButtonTitle:nil
							   otherButtonTitles:@"OK", nil]
							  autorelease];
		alert.tag = ALERTVIEW_TAG_CANNOT_GET_PDF_INFOMATION;
		[alert show];
		
		
		//close this view after setup complete.
		errorInSetupPdfBasicInfo = YES;
		
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
	[self parseAndRenderUrlLinkDefine:currentPageNum];
	
	// Setup for Movie play.
	[self parseMovieDefine];
	
	// Setup for Sound play.
	[self parseSoundOnPageDefine];
	audioPlayer = nil;	//init when use.
	
	// Setup for PageJumpLink.
	[self parsePageJumpLinkDefine];
	
	// Setup for InPage ScrollView.
	[self parseInPageScrollViewDefine];

	// Setup for InPage Pdf.
	[self parseInPagePdfDefine];
	
	// Setup for InPage Png image.
	[self parseInPagePngDefine];
	
	// Setup for Popover Image.
	[self parsePopoverImageDefine];
	
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
	[self playSoundAtIndex:currentPageNum];
	
	
	//
	if (errorInSetupPdfBasicInfo == YES) {
		NSLog(@"errorInSetupPdfBasicInfo=%d", errorInSetupPdfBasicInfo);
		[self showMenuBar];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == ALERTVIEW_TAG_CANNOT_GET_PDF_INFOMATION) {
		//Close this view. show (inner)ContentListView.
		Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate hideContentPlayerView];
		[appDelegate showContentListView];
	}
}




#pragma mark -
#pragma mark Initialize PDF.
- (BOOL)setupPdfBasicInfo
{
	//parse csv file.
	NSString* pdfFilename;
	if ([self isMultiContents] == TRUE) {
		pdfFilename = [FileUtility getPdfFilename:currentContentId];
	} else {
		pdfFilename = [FileUtility getPdfFilename];
	}
	
	//Open PDF file from (1)ContentBody Directory (2)mainBundle
	NSString* pdfFilenameFull = [ContentFileUtility getContentBodyFilenamePdf:[NSString stringWithFormat:@"%d", currentContentId]];
	//(1)get from ContentBody Directory.
	pdfURL = [NSURL fileURLWithPath:pdfFilenameFull];
	//NSLog(@"pdfFilenameFull=%@",pdfFilenameFull);
	//NSLog(@"pdfURL=%@", [pdfURL description]);
	if (!pdfURL)
	{
		//(2)get from mainBundle
		pdfURL = [[NSBundle mainBundle] URLForResource:pdfFilename withExtension:nil];
	}
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
	originalPageRect = CGPDFPageGetBoxRect(page1, kCGPDFMediaBox);
	pdfScale = self.view.frame.size.width / originalPageRect.size.width;
	pdfScaleForCache = CACHE_IMAGE_WIDTH / originalPageRect.size.width;
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
	
	int maxCount = 3;
	if (maxPageNum < 3) {
		maxCount = maxPageNum;
	}
	for (int i = 1; i <= maxCount; i = i + 1) {
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
			[image release];
			
			/*
			 CGRect rect = CGRectMake(0, 0,
			 image.size.width  * ratio,
			 image.size.height * ratio);
			 
			 UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0); // 変更
			 
			 
			 UIImage* shrinkedImage = UIGraphicsGetImageFromCurrentImageContext();
			 
			 UIGraphicsEndImageContext();
			 */
			
			//Generate directory for save.
			[FileUtility makeDir:[targetFilenameFull stringByDeletingLastPathComponent]];
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

- (BOOL)isTransitionWithCurl
{
#if defined(IS_TRANSITION_CURL) && IS_TRANSITION_CURL != 0
	return YES;	//Curl
#else
	return NO;	//Slide
#endif
}

- (BOOL)isMultiContents
{
#if defined(IS_MULTI_CONTENTS) && IS_MULTI_CONTENTS != 0
	return YES;	//True, multi contents.
#else
	return NO;	//False, single content.
#endif	
}


#pragma mark -
#pragma mark draw pdf to screen.
- (NSString*)getPageFilenameFull:(int)pageNum {
	return [FileUtility getPageFilenameFull:pageNum];
	/*
	NSString* filename = [NSString stringWithFormat:@"%@%d", PAGE_FILE_PREFIX, pageNum];
	NSString* targetFilenameFull = [[[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:PAGE_FILE_EXTENSION];
	return targetFilenameFull;
	*/
}

- (NSString*)getThumbnailFilenameFull:(int)pageNum {
	if ([self isMultiContents] == TRUE) {
		return [FileUtility getThumbnailFilenameFull:pageNum WithContentId:currentContentId];
	} else {
		return [FileUtility getThumbnailFilenameFull:pageNum];
	}
	/*
	NSString* filename = [NSString stringWithFormat:@"%@%d", THUMBNAIL_FILE_PREFIX, pageNum];
	NSString* targetFilenameFull = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:THUMBNAIL_FILE_EXTENSION];
	return targetFilenameFull;
	*/
}

- (NSString*)getThumbnailFilenameFullWithFilename:(NSString*)filename withCid:(ContentId)cid {
	return [FileUtility getThumbnailFilenameFullWithFilename:filename WithContentId:cid];	
}


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
	NSString* targetFilenameFull;
#if defined(IS_MULTI_CONTENTS) && IS_MULTI_CONTENTS != 0
	targetFilenameFull = [FileUtility getPageFilenameFull:pageNum WithContentId:currentContentId];
#else
	targetFilenameFull = [FileUtility getPageFilenameFull:pageNum];
#endif
	
	
	/*
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
	*/
	
	//NSLog(@"targetFilenameFull=%@", targetFilenameFull);
	return [self getPdfPageImageWithPageNum:pageNum WithTargetFilenameFull:targetFilenameFull];
}
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum WithContentId:(ContentId)cid
{
	if (maxPageNum < pageNum) {
		NSLog(@"illigal page given. pageNum=%d, maxPageNum=%d", pageNum, maxPageNum);
		return nil;
	}
	//Get image from file if exists.
	NSString* targetFilenameFull = [FileUtility getPageFilenameFull:pageNum WithContentId:cid];
	return [self getPdfPageImageWithPageNum:pageNum WithTargetFilenameFull:targetFilenameFull];
}
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum WithTargetFilenameFull:(NSString*)targetFilenameFull
{
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
#if defined(IS_MULTI_CONTENTS) && IS_MULTI_CONTENTS != 0
		ig.currentContentId	= currentContentId;
#endif
		[ig generateImageWithPageNum:pageNum fromUrl:pdfURL width:CACHE_IMAGE_WIDTH];
		[ig release];
		
		UIImage* pdfImage = [[UIImage alloc] initWithContentsOfFile:targetFilenameFull];
		if (pdfImage) {
			//Thumbnail image is generated ondemand.
			//[self generateThumbnailImageFromImage:pdfImage width:THUMBNAIL_WIDTH pageNumForSave:pageNum];
			
			return pdfImage;
		} else {
			NSLog(@"page generate but can not open image from file. for page %d, filename=%@", pageNum, targetFilenameFull);
#if defined(IS_MULTI_CONTENTS) && IS_MULTI_CONTENTS != 0
			NSLog(@"currentContentId=%d", currentContentId);
#endif
			return nil;
		}
	}
	
	[targetFilenameFull release];
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
#if defined(IS_MULTI_CONTENTS) && IS_MULTI_CONTENTS != 0
	[currentPdfScrollView setupWithPageNum:newPageNum ContentId:currentContentId];
#else
	[currentPdfScrollView setupWithPageNum:newPageNum];
#endif
	//bring currentImageView to Front.
	[self.view bringSubviewToFront:currentPdfScrollView];
	//[currentPdfScrollView layoutIfNeeded];
	[currentPdfScrollView setNeedsLayout];
	[currentPdfScrollView setNeedsDisplay];
	
	//Draw next imageView.
	if (currentPageNum + 1 <= maxPageNum) {
		if ([self isMultiContents] == YES) {
			[nextPdfScrollView setupWithPageNum:(newPageNum + 1) ContentId:currentContentId];
		} else {
			[nextPdfScrollView setupWithPageNum:(newPageNum + 1)];
		}
	}
	
	//Draw prev imageView.
	if (1 <= currentPageNum - 1) {
		if ([self isMultiContents] == YES) {
			[prevPdfScrollView setupWithPageNum:(newPageNum - 1) ContentId:currentContentId];
		} else {
			[prevPdfScrollView setupWithPageNum:(newPageNum - 1)];
		}
	}
}


- (void)setupZoomScaleWithFrameSize:(CGSize)newSize
{
	[prevPdfScrollView setupZoomScaleWithSize:newSize];
	[currentPdfScrollView setupZoomScaleWithSize:newSize];
	[nextPdfScrollView setupZoomScaleWithSize:newSize];
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
		
		
		//Draw link area.
		CGRect linkRect;
		linkRect = CGRectMake(x1,
							  (currentPdfScrollView.originalPageSize.height - y2),	//does not "y1".
							  fabsf(x2 - x1),
							  fabsf(y2 - y1));
		[currentPdfScrollView addScalableColorView:[UIColor blueColor] alpha:0.5f withPdfBasedFrame:linkRect];
		//NSLog(@"linkRect   =%@", NSStringFromCGRect(linkRect));
		
		
		//Add link infomation for touch.
        char *uriString = (char *)CGPDFStringGetBytePtr(uriStringRef);
        NSString *uri = [NSString stringWithCString:uriString encoding:NSUTF8StringEncoding];
		NSURL *url = [NSURL URLWithString:uri];
		//NSLog(@"URL=%@", url);
		NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
		[tmpDict setValue:[url description] forKey:LINK_DICT_KEY_URL];
		[tmpDict setValue:[NSValue valueWithCGRect:linkRect] forKey:LINK_DICT_KEY_RECT];
		[linksInCurrentPage addObject:tmpDict];
	}
	
	//Release PDFDocument.
	if (pdfDocument) {
		CGPDFDocumentRelease(pdfDocument);
		pdfDocument = nil;
	}
	//Release Autorelease pool.
	[pool release];
}


#pragma mark -
#pragma mark Treat URL Link by file.
//Parse PageJumpLink Define.
- (BOOL)parseAndRenderUrlLinkDefine:(NSUInteger)index
{
	//linksInCurrentPageWithFile = [[NSMutableArray alloc] init];
	
	NSMutableDictionary* tmpDict;
	
	//parse csv file.
	NSString* csvFilePath = [[NSBundle mainBundle] pathForResource:CSVFILE_URLLINK ofType:@"csv"];
	NSError* error;
	NSString* text = [NSString stringWithContentsOfFile:csvFilePath encoding:NSUTF8StringEncoding error:&error];
	NSString* text2 = [text stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
	/*
	 if (error) {
	 NSLog(@"error=%@, error code=%d", [error localizedDescription], [error code]);
	 return FALSE;
	 }
	 */
	
	bool hasError = FALSE;
	NSArray* lines = [text2 componentsSeparatedByString:@"\n"];
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
		//URL.(Jump TO)
		[tmpDict setValue:[NSString stringWithString:[tmpCsvArray objectAtIndex:5]] forKey:PJ_PAGE_JUMPTO];
		NSLog(@"tmpDict=%@", [tmpDict description]);
		
		if ([[tmpDict valueForKey:PJ_PAGE_NUMBER] intValue] != index) {
			LOG_CURRENT_LINE;
			continue;	//skip to next line.
			return FALSE;
		}
		
		//Add link infomation for touch.
        NSString *uri = [NSString stringWithString:[NSString stringWithString:[tmpCsvArray objectAtIndex:5]]];
		NSURL *url = [NSURL URLWithString:uri];
		NSLog(@"URL=%@", [url description]);
		CGRect linkRectInOriginalPdf = CGRectMake([[tmpDict valueForKey:PJ_PAGE_AREA_X] floatValue],
												  [[tmpDict valueForKey:PJ_PAGE_AREA_Y] floatValue],
												  [[tmpDict valueForKey:PJ_PAGE_AREA_WIDTH] floatValue],
												  [[tmpDict valueForKey:PJ_PAGE_AREA_HEIGHT] floatValue]);
		NSLog(@"linkRectInOriginalPdf=%@", NSStringFromCGRect(linkRectInOriginalPdf));
		
		NSMutableDictionary* tmpDict2 = [[[NSMutableDictionary alloc] init] autorelease];
		[tmpDict2 setValue:[url description] forKey:LINK_DICT_KEY_URL];
		[tmpDict2 setValue:[NSValue valueWithCGRect:linkRectInOriginalPdf] forKey:LINK_DICT_KEY_RECT];
		[linksInCurrentPage addObject:tmpDict2];
		NSLog(@"linksInCurrentPage=%@", [linksInCurrentPage description]);
		
		//Render.
		UIView* areaView = [[UIView alloc] initWithFrame:CGRectZero];
		
#if TARGET_IPHONE_SIMULATOR
		//Only show on Simulator.
		[areaView setBackgroundColor:[UIColor redColor]];
		[areaView setAlpha:0.2f];
#else
		[areaView setAlpha:0.0f];
#endif
		
		[currentPdfScrollView addScalableSubview:areaView withNormalizedFrame:linkRectInOriginalPdf];
	}
	//
	
	return ! hasError;
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
	
	if ([self isTransitionWithCurl]) {	//transition with CurlUp,CurlDown.
		//change view order with animatin CurlUp
		[UIView beginAnimations:@"anim1" context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:1.0];
		//[UIView setAnimationDidStopSelector:@selector(bringNextViewToFront)];
		//[viewSecond setAlpha:0.0];
		//[viewFirst setAlpha:1.0];
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
							   forView:self.view
								 cache:YES];
		[self.view bringSubviewToFront:nextPdfScrollView];
		[UIView commitAnimations];
	} else {
		// Set animation
		CATransition* animation1 = [CATransition animation];
		[animation1 setDelegate:self];
		[animation1 setDuration:PAGE_ANIMATION_DURATION_NEXT];
		[animation1 setTimingFunction:UIViewAnimationCurveEaseInOut];
		[animation1 setType:kCATransitionPush];
		//UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
		//UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
		/*
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
		 */
		[animation1 setSubtype:kCATransitionFromRight];
		
		[animation1 setValue:MY_ANIMATION_KIND_PAGE_FROM_RIGHT forKey:MY_ANIMATION_KIND];
		[[self.view layer] addAnimation:animation1 forKey:@"animation_to_NextPage"];
		
		
		// Move NextImageView to Front.
		[self.view bringSubviewToFront:nextPdfScrollView];
	}
	
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
		if ([self isMultiContents] == YES) {
			[nextPdfScrollView setupWithPageNum:(currentPageNum + 1) ContentId:currentContentId];
		} else {
			[nextPdfScrollView setupWithPageNum:(currentPageNum + 1)];
		}
	}
	
	//Stop movie.
	if (mplayer != nil) {
		[mplayer stop];
	}
	
	//
	//[self getPdfDictionaryWithPageNum:currentPageNum];
	[self renderAllLinks];
	[self playSoundAtIndex:currentPageNum];	//play sound for new page.
	
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
	
	if ([self isTransitionWithCurl]) {	//transition with CurlUp,CurlDown.
		//change view order with animatin CurlUp
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:1.0];
		//[UIView setAnimationDidStopSelector:@selector(bringPrevViewToFront)];
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown
							   forView:self.view cache:YES];
		[self.view bringSubviewToFront:prevPdfScrollView];
		[UIView commitAnimations];
	} else {
		// Set animation
		CATransition* animation1 = [CATransition animation];
		[animation1 setDelegate:self];
		[animation1 setDuration:PAGE_ANIMATION_DURATION_PREV];
		[animation1 setTimingFunction:UIViewAnimationCurveEaseInOut];
		[animation1 setType:kCATransitionPush];
		//UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
		//UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
		/*
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
		*/
		[animation1 setSubtype:kCATransitionFromLeft];
		
		[animation1 setValue:MY_ANIMATION_KIND_PAGE_FROM_LEFT forKey:MY_ANIMATION_KIND];
		[[self.view layer] addAnimation:animation1 forKey:@"animation_to_PrevPage"];
		
		
		// Move PrevImageView to Front.
		[self.view bringSubviewToFront:prevPdfScrollView];
	}
	
	
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
		if ([self isMultiContents] == YES) {
			[prevPdfScrollView setupWithPageNum:(currentPageNum - 1) ContentId:currentContentId];
		} else {
			[prevPdfScrollView setupWithPageNum:(currentPageNum - 1)];
		}
	}
	
	//Stop movie.
	if (mplayer != nil) {
		[mplayer stop];
	}
	
	//NSLog(@"(new)currentPdfScrollView subviews = %d", [currentPdfScrollView.subviews count]);
	//
	[self renderAllLinks];
	[self playSoundAtIndex:currentPageNum];	//play sound for new page.
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
		if ([self isMultiContents] == YES) {
			[nextPdfScrollView setupWithPageNum:(currentPageNum + 1) ContentId:currentContentId];
		} else {		
			[nextPdfScrollView setupWithPageNum:(currentPageNum + 1)];
		}
	}
	
	// Load (new)prevImage.
	if (1 < currentPageNum) {
		if ([self isMultiContents] == YES) {
			[prevPdfScrollView setupWithPageNum:(currentPageNum - 1) ContentId:currentContentId];
		} else {
			[prevPdfScrollView setupWithPageNum:(currentPageNum - 1)];
		}
	}
	
	//Reset zoomScale
	[prevPdfScrollView resetScrollView];
	[currentPdfScrollView resetScrollView];
	[nextPdfScrollView resetScrollView];
	
	//Hide TOCView.
	//[self.tocViewController.view removeFromSuperview];
	
	//Draw link to URL, Movie.
	[self renderAllLinks];
	[self playSoundAtIndex:currentPageNum];	//play sound for new page.
	
	// Set animation
	CATransition* animation1 = [CATransition animation];
	[animation1 setDelegate:self];
	[animation1 setDuration:0.2f];
	[animation1 setTimingFunction:UIViewAnimationCurveEaseInOut];
	[animation1 setType:kCATransitionFade];
	[animation1 setValue:MY_ANIMATION_KIND_FADE forKey:MY_ANIMATION_KIND];
	[[self.view layer] addAnimation:animation1 forKey:@"animation_to_SpecifyPage"];
	
	//Stop movie.
	if (mplayer != nil) {
		[mplayer stop];
	}
	
	// Move CurrentImageView to Front.
	[self.view bringSubviewToFront:currentPdfScrollView];
}

- (void)switchNextImageWithAnimationType:(NSString*)animationType
{ LOG_CURRENT_METHOD; }

- (void)renderAllLinks
{
	[self renderPageLinkAtIndex:currentPageNum];
	[self parseAndRenderUrlLinkDefine:currentPageNum];
	[self renderMovieLinkAtIndex:currentPageNum];
	[self renderPageJumpLinkAtIndex:currentPageNum];
	[self renderInPageScrollViewAtIndex:currentPageNum];
	[self renderInPagePdfAtIndex:currentPageNum];
	[self renderInPagePngAtIndex:currentPageNum];
	[self renderPopoverImageLinkAtIndex:currentPageNum];
	
	[self setupMarkerPenMenu];
	//[self setupMarkerPenViewAtPage:currentPageNum];
	[self renderMarkerPenFromUserDefaultAtPage:currentPageNum];
	[self.view bringSubviewToFront:markerPenView2];
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
	CGPoint touchedPointInPdf2 = CGPointMake(touchedPoint.x / pdfScaleForCache,
											 touchedPoint.y / pdfScaleForCache);
	//NSLog(@"touchedPointInPdf = %@", NSStringFromCGPoint(touchedPointInPdf));
	//NSLog(@"touchedPointInPdf2 = %@", NSStringFromCGPoint(touchedPointInPdf2));
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
	
	// do nothing in MarkerMode.
	if (isMarkerPenMode == YES) {
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
			
			if (CGRectContainsPoint(rect, touchedPointInPdf2)) {
				NSString* filename = [movieInfo valueForKey:MD_MOVIE_FILENAME];
				//NSLog(@"movie link touched. filename=%@", filename);
				
				//no-continue.
				[self showMoviePlayer:filename WithFrame:rect];
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
			
			if (CGRectContainsPoint(rect, touchedPointInPdf2)) {
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
			
			if (CGRectContainsPoint(rect, touchedPointInPdf2)) {
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
	/*
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
	*/
	baseWidth = self.view.frame.size.width;
	baseHeight = self.view.frame.size.height;
	//NSLog(@"baseWidth=%f, baseHeight=%f", baseWidth, baseHeight);
	
	
	leftTapArea = CGRectMake(baseWidth   * TAP_AREA_LEFT_X,
							 baseHeight  * TAP_AREA_LEFT_Y,
							 baseWidth   * TAP_AREA_LEFT_WIDTH,
							 baseHeight  * TAP_AREA_LEFT_HEIGHT);
	rightTapArea = CGRectMake(baseWidth  * TAP_AREA_RIGHT_X,
							  baseHeight * TAP_AREA_RIGHT_Y,
							  baseWidth  * TAP_AREA_RIGHT_WIDTH,
							  baseHeight * TAP_AREA_RIGHT_HEIGHT);
	topTapArea = CGRectMake(baseWidth    * TAP_AREA_TOP_X,
							baseHeight   * TAP_AREA_TOP_Y,
							baseWidth    * TAP_AREA_TOP_WIDTH,
							baseHeight   * TAP_AREA_TOP_HEIGHT);
	bottomTapArea = CGRectMake(baseWidth * TAP_AREA_BOTTOM_X,
							   baseHeight* TAP_AREA_BOTTOM_Y,
							   baseWidth * TAP_AREA_BOTTOM_WIDTH,
							   baseHeight* TAP_AREA_BOTTOM_HEIGHT);
	//NSLog(@"leftTapArea=%@", NSStringFromCGRect(leftTapArea));
	//NSLog(@"rightTapArea=%@", NSStringFromCGRect(rightTapArea));
	//NSLog(@"topTapArea=%@", NSStringFromCGRect(topTapArea));
	//NSLog(@"bottomTapArea=%@", NSStringFromCGRect(bottomTapArea));
	
	CGPoint touchedPointInParentView = [gestureRecognizer locationInView:self.view];
	//NSLog(@"location in currentPdfScrollView = %@", NSStringFromCGPoint(touchedPointInParentView));
	if (CGRectContainsPoint(topTapArea, touchedPointInParentView)) {
		//NSLog(@"touch topTapArea");
		[self handleTapInTopArea:gestureRecognizer];
	} else if (CGRectContainsPoint(bottomTapArea, touchedPointInParentView)) {
		//NSLog(@"touch bottomTapArea");
		[self handleTapInBottomArea:gestureRecognizer];
	} else if (CGRectContainsPoint(leftTapArea, touchedPointInParentView)) {
		//NSLog(@"touch leftTapArea");
		[self handleTapInLeftArea:gestureRecognizer];
	} else if (CGRectContainsPoint(rightTapArea, touchedPointInParentView)) {
		//NSLog(@"touch rightTapArea");
		[self handleTapInRightArea:gestureRecognizer];
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
	
	//do nothing if in marker pen mode.
	if (isMarkerPenMode == YES) {
		return;
	}
	
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
//MARK: Treat marker marker pen.
- (void)setupMarkerPenView
{
	//Generate markerPenView-2.
	markerPenView2 = [[MarkerPenView alloc] initWithFrame:self.view.frame];
	//NSLog(@"markerPenView2 has %d recognizers", [[markerPenView2 gestureRecognizers] count]);
	[markerPenView2 clearLine];
	
	/*
	//Add gesture to markerPenView.(drag for add line.)
	panRecognizer21 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan2:)];
	panRecognizer21.enabled = YES;
	[markerPenView2 addGestureRecognizer:panRecognizer21];
	NSLog(@"markerPenView2 has %d recognizers", [[markerPenView2 gestureRecognizers] count]);
	for (id obj in [markerPenView2 gestureRecognizers]) {
		NSLog(@"class=%@", [obj class]);
		UIPanGestureRecognizer* r = (UIPanGestureRecognizer*)obj;
		NSLog(@"enabled=%d", r.enabled);
	}
	*/
}

- (void)setupMarkerPenMenu
{
	//LOG_CURRENT_METHOD;
	//MenuBar.
	CGFloat menuBarHeight = 44.0f;
    if (! menuBarForMakerPen) {
        menuBarForMakerPen = [[UIToolbar alloc] initWithFrame:CGRectZero];
		
		//Add Done button.
		UIBarButtonItem* doneButton = [[UIBarButtonItem alloc]
									   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
									   target:self 
									   action:@selector(exitMarkerMode)];
		//Add Delete button.
		UIImage* deleteButtonImage = [UIImage imageNamed:@"icon_recycle.png"];
		if (! deleteButtonImage) {
			LOG_CURRENT_LINE;
			return;
		}
		UIBarButtonItem* deleteButton = [[UIBarButtonItem alloc]
										 initWithImage:deleteButtonImage
										 style:UIBarButtonItemStylePlain
										 target:self
										 action:@selector(prepareDeleteMarkerPenWithCurrentPage)];
		
		//Add undo button.
		UIImage* undoButtonImage = [UIImage imageNamed:@"undo_selected.png"];
		if (! undoButtonImage) {
			LOG_CURRENT_LINE;
			return;
		}	
		UIBarButtonItem* undoButton = [[UIBarButtonItem alloc]
									   initWithImage:undoButtonImage
									   style:UIBarButtonItemStylePlain
									   target:self
									   action:@selector(deleteLastLine:)];
		
		//Add title label.
		NSString* titleStr = @"Marker Mode";
		CGSize labelSize = [titleStr sizeWithFont:[UIFont boldSystemFontOfSize:24]];
		UIBarButtonItem* titleLabelButton = [UIBarButtonItem alloc];
		[titleLabelButton initWithTitle:titleStr
								  style:UIBarButtonItemStylePlain
								 target:nil
								 action:nil];
		[titleLabelButton setWidth:165.0f];
		[titleLabelButton setWidth:labelSize.width];
		
		//Add FlexibleSpace.
		UIBarButtonItem *fspace1 = [[UIBarButtonItem alloc]
										  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
										  target:nil
										  action:nil];
		UIBarButtonItem *fspace2 = [[UIBarButtonItem alloc]
										   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
										   target:nil
										   action:nil];

		[menuBarForMakerPen setItems:[NSArray arrayWithObjects:doneButton, fspace1, titleLabelButton, fspace2, undoButton, deleteButton, nil]];
		[self.view addSubview:menuBarForMakerPen];
	}
	
	//Setup menu bar frame.
	/*
	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (interfaceOrientation == UIInterfaceOrientationPortrait
		||
		interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        CGRect rect = CGRectMake(0.0f,
                                 0.0f,	//self.view.frame.size.height - menuBarHeight, 
                                 self.view.frame.size.width,
                                 menuBarHeight);
		menuBarForMakerPen.frame = rect;
	} else {
		CGRect rect = menuBarForMakerPen.frame;
		rect.size.width = self.view.frame.size.width;
		rect.origin.y = 0.0f;	//self.view.frame.size.width - menuBarHeight;
		menuBarForMakerPen.frame = rect;
	}
	*/
	
	CGRect rect = CGRectMake(0.0f,
							 0.0f,
							 self.view.frame.size.width,
							 menuBarHeight);
	menuBarForMakerPen.frame = rect;
}

- (void)enterMarkerMode
{
	//LOG_CURRENT_METHOD;
    //Hide original menu.
    [self hideMenuBar];
    
    //Show markerPen view.
    //[self.view bringSubviewToFront:markerPenView];
	
	//Show menu bar, label for MakerPen.
	[self setupMarkerPenMenu];
    [self showMenuBarForMarker];
    
    //Enable touch with view for maker.
    markerPenView2.userInteractionEnabled = YES;
	currentPdfScrollView.userInteractionEnabled = NO;
    
	/*
    //Enable gesture for add line.
	panRecognizer21.enabled = YES;
	NSLog(@"markerPenView2 has %d recognizers", [[markerPenView2 gestureRecognizers] count]);
	for (id obj in [markerPenView2 gestureRecognizers]) {
		NSLog(@"class=%@", [obj class]);
		UIPanGestureRecognizer* r = (UIPanGestureRecognizer*)obj;
		NSLog(@"enabled=%d", r.enabled);
	}
	*/
	panRecognizer1.enabled = YES;
	panRecognizer2.enabled = YES;
	panRecognizer3.enabled = YES;
	
	//Set Flag.
	isMarkerPenMode = YES;
}
- (void)exitMarkerMode
{
	//LOG_CURRENT_METHOD;
    //Hide menu bar for marker pen.
    if (menuBarForMakerPen != nil) {
        //menuBarForMakerPen.hidden = YES;
		[self hideMenuBarForMarker];
    }
	
	/*
    //Disable gesture for add line.
	panRecognizer21.enabled = NO;
	*/
	panRecognizer1.enabled = NO;
	panRecognizer2.enabled = NO;
	panRecognizer3.enabled = NO;
	
    //Disable touch with view for maker.
    markerPenView2.userInteractionEnabled = NO;
	currentPdfScrollView.userInteractionEnabled = YES;
	
	//Set Flag.
	isMarkerPenMode = NO;
}

- (void)handlePan2:(UIPanGestureRecognizer *)gestureRecognizer
{
    //LOG_CURRENT_METHOD;
    //
	
    if (! markerPenArray) {
        markerPenArray = [[NSMutableArray alloc] init];
    }
    if (! pointsForSingleLine) {
        pointsForSingleLine = [[NSMutableArray alloc] init];
    }
    
    CGPoint touchedPoint;
	//LOG_CURRENT_METHOD;
	if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
        //NSLog(@"Possible");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"pan Began");
		
		//Setup line info on markerPenView2.
		[markerPenView2 willStartAddLine];
		
		//Create new array.
        pointsForSingleLine = [[NSMutableArray alloc] init];
		
		//Add Point into array.
		CGPoint p = [gestureRecognizer locationInView:markerPenView2];
        [pointsForSingleLine addObject:NSStringFromCGPoint(p)];
		
	} else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        //NSLog(@"Changed");
        touchedPoint = [gestureRecognizer locationInView:markerPenView2];
		
		//Add line info on markerPenView2.
		[markerPenView2 addLineWithPoint:touchedPoint];
		[markerPenView2 setNeedsDisplay];
		
		//Add Point into array.
		CGPoint p = [gestureRecognizer locationInView:markerPenView2];
        [pointsForSingleLine addObject:NSStringFromCGPoint(p)];
		
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"pan Ended");
        
        touchedPoint = [gestureRecognizer locationInView:markerPenView2];
		
		//Add line info on markerPenView2.
		[markerPenView2 addLineWithPoint:touchedPoint];
		[markerPenView2 didEndAddLine];
		
		//Add Point into array.
		CGPoint p = [gestureRecognizer locationInView:markerPenView2];
        [pointsForSingleLine addObject:NSStringFromCGPoint(p)];
		
		//Generate dictionary for add array.
		NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
		[tmpDict setValue:[NSNumber numberWithInt:currentPageNum] forKey:MARKERPEN_PAGE_NUMBER];
		[tmpDict setValue:@"" forKey:MARKERPEN_COMMENT];
		[tmpDict setValue:pointsForSingleLine forKey:MARKERPEN_POINT_ARRAY];
		[markerPenArray addObject:tmpDict];
		
        //Save to UserDefault.
        [self saveMarkerPenToUserDefault];
		
        //Refresh marker view.
        [self renderMarkerPenFromUserDefaultAtPage:currentPageNum];
	} else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"pan gesture Cancelled");
	} else if (gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        NSLog(@"pan gesture Failed");
    }
}

- (void)showMenuBarForMarker {
	//LOG_CURRENT_METHOD;
	menuBarForMakerPen.hidden = NO;
	[self.view bringSubviewToFront:menuBarForMakerPen];
}
- (void)hideMenuBarForMarker {
	//LOG_CURRENT_METHOD;
 	menuBarForMakerPen.hidden = YES;
}

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
	//Add line info from UserDefault to markerPenView.
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
	if (! markerPenArray) {
		markerPenArray = [[NSMutableArray alloc] init];
	}
	
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

	[markerPenArray addObjectsFromArray:obj];
	
	//NSLog(@"loaded. markerPenArray=%@", [markerPenArray description]);
}

- (void)renderMarkerPenFromUserDefaultAtPage:(NSUInteger)pageNum
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"markerPenView2 has %d recognizers", [[markerPenView2 gestureRecognizers] count]);
	for (id obj in [markerPenView2 gestureRecognizers]) {
		UIPanGestureRecognizer* r = (UIPanGestureRecognizer*)obj;
		NSLog(@"enabled=%d", r.enabled);
	}
	
    //has been Readed marker pen infomation.
	if (! markerPenArray) {
		LOG_CURRENT_LINE;
		NSLog(@"markerPenArray not initialized.(no marker pen info at page %d.)", pageNum);
		return;
	}
	
	//
	[markerPenView2 clearLine];

	//Add line info from UserDefault to markerPenView.
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
			[markerPenView2 addLinesWithDictionary:markerInfo];
		}
    }
	
	//Draw line dragging.(use nowDraggingLine).
	
	//
	CGRect rect = self.view.frame;
	[currentPdfScrollView addScalableSubview:markerPenView2 withNormalizedFrame:rect];
	[markerPenView2 setNeedsDisplay];
}


- (void)prepareDeleteMarkerPenWithCurrentPage
{
	//Show ActionSheet
	UIActionSheet *sheet;
	sheet = [[[UIActionSheet alloc]
			  initWithTitle:@"ページ内のマーカーを削除しますか？"
			  delegate: self 
			  cancelButtonTitle: NSLocalizedString(@"Cancel", nil) 
			  destructiveButtonTitle: nil
			  otherButtonTitles:NSLocalizedString(@"削除する", nil), NSLocalizedString(@"キャンセル", nil), nil]
			 autorelease];
	[sheet showInView: self.view];
}

- (void)actionSheet:(UIActionSheet *)sheet didDismissWithButtonIndex:(NSInteger)index
{
	//NSLog(@"action sheet: index=%d", index);
    if( index == [sheet cancelButtonIndex])
    {
        // Do Nothing
    }
    else if( index == [sheet destructiveButtonIndex] )
    {
        // Do Nothing
    }
    else if(index == 0) {
        // Delete line in current page.
		[self deleteMarkerPenAtPage:currentPageNum];
		[self saveMarkerPenToUserDefault];
		[self renderMarkerPenFromUserDefaultAtPage:currentPageNum];
    }
}

- (void)deleteMarkerPenAtPage:(NSUInteger)pageNum
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"pageNum=%d", pageNum);
	
	if (maxPageNum < pageNum) {
		LOG_CURRENT_LINE;
		NSLog(@"illigal page number. pageNum=%d, maxPageNum=%d", pageNum, maxPageNum);
		return;
	}
	
	if (! markerPenArray) {
		LOG_CURRENT_LINE;
		NSLog(@"markerPenArray not initialized.(no marker pen info at page %d.)", pageNum);
		return;
	}
	
	//Delete line info.
	for (id obj in [markerPenArray reverseObjectEnumerator]) {
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
			[markerPenArray removeObject:obj];
		}
    }
	//NSLog(@"after  line number=%d", [markerPenArray count]);
}


- (IBAction)deleteLastLine:(id)sender
{
	if (0 <  [markerPenArray count]) {
		[markerPenArray removeLastObject];
	}
 	[markerPenView2 deleteLastLine];
	[markerPenView2 setNeedsDisplay];
}

/*
- (void)setupMarkerPenViewAtPage:(NSUInteger)pageNum
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"markerPenArray=%@", [markerPenArray description]);
	
	
	//[markerPenView clearLine];
	
    //Add line info from UserDefault to markerPenView.
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
			//[markerPenView addLinesWithDictionary:markerInfo];
		}
    }
}
*/


- (void)clearMarkerPenView 
{
	[markerPenView2 clearLine];
	[markerPenView2 setNeedsDisplay];
}


#pragma mark -
#pragma mark Treat page jump link.
//Parse PageJumpLink Define.
- (void)parsePageJumpLinkDefine
{
	pageJumpLinkDefine = [[NSMutableArray alloc] init];
	
	//parse csv file.
	NSString* targetFilename = CSVFILE_PAGEJUMPLINK;
	NSArray* lines;
	if ([self isMultiContents] == TRUE) {
		lines = [FileUtility parseDefineCsv:targetFilename contentId:currentContentId];
	} else {
		lines = [FileUtility parseDefineCsv:targetFilename];
	}
	
	//parse each line.
	NSMutableDictionary* tmpDict;
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
			continue;	//Skip illegal line.
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
}

- (void) renderPageJumpLinkAtIndex:(NSUInteger)index
{
#if ! TARGET_IPHONE_SIMULATOR
	return;
#endif
	
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
			
			
			
			[currentPdfScrollView addScalableColorView:[UIColor purpleColor] alpha:0.2f withPdfBasedFrame:rect];
		}
	}
}


#pragma mark -
#pragma mark Treat InPage ScrollView.
//Parse InPage ScrollView Define.
- (void)parseInPageScrollViewDefine
{
	inPageScrollViewDefine = [[NSMutableArray alloc] init];
	
	//parse csv file.
	NSString* targetFilename = CSVFILE_INPAGE_SCROLLVIEW;
	NSArray* lines;
	if ([self isMultiContents] == TRUE) {
		lines = [FileUtility parseDefineCsv:targetFilename contentId:currentContentId];
	} else {
		lines = [FileUtility parseDefineCsv:targetFilename];
	}
	
	//parse each line.
	NSMutableDictionary* tmpDict;
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
			NSString* tmpStrWithoutCR = [tmpStrWithoutDoubleQuote stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x0d] withString:@""];	/* delete CR. */
			NSString* tmpStrWithoutLF = [tmpStrWithoutCR stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x22] withString:@""];	/* delete LF. */
			//NSString* tmpStrURLEncoded = [tmpStrWithoutDoubleQuote stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			//[tmpDict setValue:tmpStrURLEncoded forKey:MD_MOVIE_FILENAME];
			[filenamesArray addObject:tmpStrWithoutLF];
		}
		
		[tmpDict setValue:filenamesArray forKey:IPSD_FILENAMES];
		
		[inPageScrollViewDefine addObject:tmpDict];
	}
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
			
			NSMutableArray* images = [[NSMutableArray alloc] init];
			for (NSString* filename in filenames) {
				//Add each image from mainBundle.
				//NSString *path= [[NSBundle mainBundle] pathForResource:filename ofType:nil];
				
				//Add each image from contentBody image directory.
				NSString* cidStr = [NSString stringWithFormat:@"%d", currentContentId];
				NSString* path = [[ContentFileUtility getContentBodyImageDirectoryWithContentId:cidStr]
										  stringByAppendingPathComponent:filename];
				//if (!path) {
				//	NSLog(@"file not found. path=%@", [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
				//	continue;	//next file.
				//}
				UIImage* image = [[UIImage alloc] initWithContentsOfFile:path];
				if (!image) {
					NSLog(@"can not create image from %@", path);
					continue;	//next file.
				}
				
				[images addObject:image];
			}
			
			UIColor* bgColor = IPSD_BACKGROUND_COLOR;
			
			[currentPdfScrollView addScalableScrollView:images
									  withPdfBasedFrame:rect
										backgroundColor:bgColor
							scrollIndicatorInsetsString:IPSD_SCROLL_INDICATOR_INSET_STRING
								  flashScrollIndicators:YES];
		}
	}
}

#pragma mark -
#pragma mark Treat InPage Pdf.
//Parse InPage Pdf Define.
- (void)parseInPagePdfDefine
{
	inPagePdfDefine = [[NSMutableArray alloc] init];
	
	//parse csv file.
	NSString* targetFilename = CSVFILE_INPAGE_PDF;
	NSArray* lines;
	if ([self isMultiContents] == TRUE) {
		lines = [FileUtility parseDefineCsv:targetFilename contentId:currentContentId];
	} else {
		lines = [FileUtility parseDefineCsv:targetFilename];
	}
	
	//parse each line.
	NSMutableDictionary* tmpDict;
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
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:0] intValue]] forKey:IPPD_PAGE_NUMBER];
		//Position.
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:1] intValue]] forKey:IPPD_AREA_X];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:2] intValue]] forKey:IPPD_AREA_Y];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:3] intValue]] forKey:IPPD_AREA_WIDTH];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:4] intValue]] forKey:IPPD_AREA_HEIGHT];
		//Filename.
		NSString* tmpStr = [tmpCsvArray objectAtIndex:5];
		NSString* tmpStrWithoutDoubleQuote = [tmpStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x22] withString:@""];	/* delete DoubleQuote. */
		NSString* tmpStrWithoutCR = [tmpStrWithoutDoubleQuote stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x0d] withString:@""];	/* delete CR. */
		NSString* tmpStrWithoutLF = [tmpStrWithoutCR stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x22] withString:@""];	/* delete LF. */
		//NSString* tmpStrURLEncoded = [tmpStrWithoutDoubleQuote stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		//[tmpDict setValue:tmpStrURLEncoded forKey:MD_MOVIE_FILENAME];
		[tmpDict setValue:tmpStrWithoutLF forKey:IPPD_FILENAME];
		
		[inPagePdfDefine addObject:tmpDict];
	}
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
- (void)parseInPagePngDefine
{
	inPagePngDefine = [[NSMutableArray alloc] init];
	
	//parse csv file.
	NSString* targetFilename = CSVFILE_INPAGE_PNG;
	NSArray* lines;
	if ([self isMultiContents] == TRUE) {
		lines = [FileUtility parseDefineCsv:targetFilename contentId:currentContentId];
	} else {
		lines = [FileUtility parseDefineCsv:targetFilename];
	}
	
	//parse each line.
	NSMutableDictionary* tmpDict;
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
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:0] intValue]] forKey:IPPD_PAGE_NUMBER];
		//Position.
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:1] intValue]] forKey:IPPD_AREA_X];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:2] intValue]] forKey:IPPD_AREA_Y];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:3] intValue]] forKey:IPPD_AREA_WIDTH];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:4] intValue]] forKey:IPPD_AREA_HEIGHT];
		//Filename.
		NSString* tmpStr = [tmpCsvArray objectAtIndex:5];
		NSString* tmpStrWithoutDoubleQuote = [tmpStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x22] withString:@""];	/* delete DoubleQuote. */
		NSString* tmpStrWithoutCR = [tmpStrWithoutDoubleQuote stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x0d] withString:@""];	/* delete CR. */
		NSString* tmpStrWithoutLF = [tmpStrWithoutCR stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x22] withString:@""];	/* delete LF. */
		//NSString* tmpStrURLEncoded = [tmpStrWithoutDoubleQuote stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		//[tmpDict setValue:tmpStrURLEncoded forKey:MD_MOVIE_FILENAME];
		[tmpDict setValue:tmpStrWithoutLF forKey:IPPD_FILENAME];
		
		[inPagePngDefine addObject:tmpDict];
	}
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
				//image = [UIImage imageNamed:filename];
				
				// Open image from contentBody image directory.
				NSString* cidStr = [NSString stringWithFormat:@"%d", currentContentId];
				NSString* fullFilename = [[ContentFileUtility getContentBodyImageDirectoryWithContentId:cidStr]
										  stringByAppendingPathComponent:filename];
				image = [[UIImage alloc] initWithContentsOfFile:fullFilename];
				
				if (! image) {
					LOG_CURRENT_METHOD;
					LOG_CURRENT_LINE;
					NSLog(@"file not found in mainBundle, filename=%@", [filename stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
					continue;	//skip to next object.
				}
			}
			UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
			
			//Show by UIScrollView.
			UIScrollView* inPagePngScrollView = [[UIScrollView alloc] initWithFrame:rect];
			[inPagePngScrollView setBounces:NO];
			[inPagePngScrollView addSubview:imageView];
			inPagePngScrollView.contentSize = image.size;
			[inPagePngScrollView setShowsHorizontalScrollIndicator:NO];
			[inPagePngScrollView setShowsVerticalScrollIndicator:YES];
			
			//[currentPdfScrollView addScalableSubview:inPagePngScrollView withNormalizedFrame:rect];
			[currentPdfScrollView addScalableSubview2:inPagePngScrollView withPdfBasedFrame:rect];
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
			CGFloat scaleForCache = currentPdfScrollView.scaleForCache;
			scaleFitWidth = (rect.size.width * scaleForCache) / image.size.width;
			//NSLog(@"rect.size=%@, image.size=%@, scaleFitWidth=%f",NSStringFromCGSize(rect.size), NSStringFromCGSize(image.size), scaleFitWidth);
			//NSLog(@"scaleForCache=%f", scaleForCache);
			//NSLog(@"scaleFitWidth=%f", scaleFitWidth);
			
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
- (void)parsePopoverImageDefine
{
	popoverImageDefine = [[NSMutableArray alloc] init];
	
	//parse csv file.
	NSString* targetFilename = CSVFILE_POPOVER_IMAGE;
	NSArray* lines;
	if ([self isMultiContents] == TRUE) {
		lines = [FileUtility parseDefineCsv:targetFilename contentId:currentContentId];
	} else {
		lines = [FileUtility parseDefineCsv:targetFilename];
	}
	
	//parse each line.
	NSMutableDictionary* tmpDict;
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
		NSString* tmpStrWithoutCR = [tmpStrWithoutDoubleQuote stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x0d] withString:@""];	/* delete CR. */
		NSString* tmpStrWithoutLF = [tmpStrWithoutCR stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x22] withString:@""];	/* delete LF. */
		//NSString* tmpStrURLEncoded = [tmpStrWithoutDoubleQuote stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		//[tmpDict setValue:tmpStrURLEncoded forKey:MD_MOVIE_FILENAME];
		[tmpDict setValue:tmpStrWithoutLF forKey:MD_MOVIE_FILENAME];
		
		[popoverImageDefine addObject:tmpDict];
	}
}

- (void) renderPopoverImageLinkAtIndex:(NSUInteger)index
{
#if ! TARGET_IPHONE_SIMULATOR
	return;
#endif
	
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
			
			[currentPdfScrollView addScalableColorView:[UIColor greenColor] alpha:0.2f withPdfBasedFrame:rect];
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
	NSString* cidStr = [NSString stringWithFormat:@"%d", currentContentId];
	psivc = [[PopoverImageViewController alloc] initWithImageFilename:filename frame:rect withContentIdStr:cidStr];
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
	[self clearMarkerPenView];
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
	//Do not stop sound.
	
	[thumbnailScrollViewController setupViewFrame];
	[thumbnailScrollViewController setupScrollViewFrame];
	[bookmarkViewController setupViewFrame];
}
#endif

#pragma mark -
#pragma mark Treat TOC.
- (void)parseTocDefine
{
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	appDelegate.tocDefine = [[NSMutableArray alloc] init];
	
	//parse csv file.
	NSString* targetFilename = CSVFILE_TOC;
	NSArray* lines;
	if ([self isMultiContents] == TRUE) {
		lines = [FileUtility parseDefineCsv:targetFilename contentId:currentContentId];
	} else {
		lines = [FileUtility parseDefineCsv:targetFilename];
	}
	
	//parse each line.
	NSMutableDictionary* tmpDict;
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
	thumbnailScrollViewController.currentContentId = currentContentId;
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
	id obj = nil;
	if ([self isMultiContents] == YES) {
		NSArray* bookmarkForMultiContent = [settings valueForKey:BOOKMARK_MULTI_CONTENT];
		for (NSDictionary* tmpDict in bookmarkForMultiContent) {
			ContentId candidateCid = [[tmpDict valueForKey:CONTENT_CID] intValue];
			if (candidateCid == currentContentId) {
				obj = [tmpDict valueForKey:BOOKMARK_ARRAY];
				break;
			}
		}
	} else {
		obj = [settings valueForKey:BOOKMARK_ARRAY];
	}
	
	//Check type.
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
	//[self presentModalViewController:bmvc animated:YES];
	[self.view addSubview:bmvc.view];
	
	//Set pageNumber after view loaded.
	[bmvc setPageNumberForPrint:currentPageNum];
}
- (void)addBookmarkWithCurrentPageWithName:(NSString*)bookmarkName {
	//LOG_CURRENT_METHOD;
	
	//Read bookmark infomation.
	NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	NSMutableArray* bookmarks = [[NSMutableArray alloc] init];
	NSMutableArray* bookmarkForMultiContent = nil;
	id obj = nil;
	if ([self isMultiContents] == TRUE) {
		bookmarkForMultiContent = [settings valueForKey:BOOKMARK_MULTI_CONTENT];
		for (NSDictionary* tmpDict in bookmarkForMultiContent) {
			ContentId candidateCid = [[tmpDict valueForKey:CONTENT_CID] intValue];
			if (candidateCid == currentContentId) {
				obj = [tmpDict valueForKey:BOOKMARK_ARRAY];
				break;
			}
		}
	} else {
		obj = [settings valueForKey:BOOKMARK_ARRAY];
	}
	if (obj && [obj isKindOfClass:[NSArray class]]) {
		[bookmarks addObjectsFromArray:obj];
	}
	NSLog(@"bookmarks has %d items for cid=%d.", [bookmarks count], currentContentId);
	
	//Generate bookmark item from current pageNum.
	NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
	[tmpDict setObject:[NSNumber numberWithInt:currentPageNum] forKey:BOOKMARK_PAGE_NUMBER];
	[tmpDict setObject:bookmarkName forKey:BOOKMARK_PAGE_MEMO];
	[bookmarks addObject:tmpDict];
	
	//Store bookmark infomation to UserDefault.
	NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
	if ([self isMultiContents] == TRUE) {
		bookmarkForMultiContent = [[NSMutableArray alloc] initWithArray:[settings valueForKey:BOOKMARK_MULTI_CONTENT]];
		NSLog(@"bookmarkForMultiContent(before) = %@", [bookmarkForMultiContent description]);
		
		if (bookmarkForMultiContent == nil) {
			bookmarkForMultiContent = [[NSMutableArray alloc] init];
		}
		
		//Generate bookmark with ContentId.
		NSMutableDictionary* newBookMarkWithContentId = [[NSMutableDictionary alloc] init];
		[newBookMarkWithContentId setValue:[NSNumber numberWithInt:currentContentId] forKey:CONTENT_CID];
		[newBookMarkWithContentId setValue:bookmarks forKey:BOOKMARK_ARRAY];
		//Replace.
		for (NSDictionary* bmEachContent in bookmarkForMultiContent) {
			ContentId candidateCid2 = [[bmEachContent valueForKey:CONTENT_CID] intValue];
			if (candidateCid2 == currentContentId) {
				[bookmarkForMultiContent removeObject:bmEachContent];
				LOG_CURRENT_LINE;
				NSLog(@"bookmarkForMultiContent(remove before add)=%@", [bookmarkForMultiContent description]);
				break;
			}
		}
		[bookmarkForMultiContent addObject:newBookMarkWithContentId];
		[userDefault setObject:bookmarkForMultiContent forKey:BOOKMARK_MULTI_CONTENT];
		LOG_CURRENT_LINE;
		NSLog(@"bookmarkForMultiContent(after add)=%@", [bookmarkForMultiContent description]);
	} else {
		[userDefault setObject:bookmarks forKey:BOOKMARK_ARRAY];
		LOG_CURRENT_LINE;
		NSLog(@"bookmark=%@", bookmarks);
	}
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
	//LOG_CURRENT_METHOD;
	
	//if ([self isChangeOrientationKind:self.interfaceOrientation newOrientation:toInterfaceOrientation] == YES) {
	if(0==0){
		//Rotate MyPdfScrollView.
		CGSize newSize;
		CGFloat statusBarHeight = 0.0f;	//20.0f;	//status bar is hidden.
		/*
		if (toInterfaceOrientation == UIInterfaceOrientationPortrait
			||
			toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			newSize = CGSizeMake(self.view.frame.size.width + statusBarHeight, self.view.frame.size.height);
		} else {
			newSize = CGSizeMake(self.view.frame.size.height + statusBarHeight, self.view.frame.size.width);
		}
		*/
		newSize = CGSizeMake(self.view.frame.size.height + statusBarHeight, self.view.frame.size.width);
		
		//NSLog(@"newSize=%@", NSStringFromCGSize(newSize));
		//NSLog(@"self.view.frame=%@", NSStringFromCGRect(self.view.frame));
		[self hideThumbnailScrollView];
		if (1 < currentPageNum) {
			[prevPdfScrollView setupCurrentPageWithSize:newSize];
		}
		[currentPdfScrollView setupCurrentPageWithSize:newSize];
		if (currentPageNum < maxPageNum) {
			[nextPdfScrollView setupCurrentPageWithSize:newSize];
		}
	} else {
		LOG_CURRENT_LINE;
		NSLog(@"orientation not changed.");
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	//LOG_CURRENT_METHOD;
	
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	if (mplayer != nil) {
		[mplayer stop];
	}
	[self renderAllLinks];
	//Do not stop sound.
	
	[thumbnailScrollViewController setupViewFrame:self.view.frame];
	[thumbnailScrollViewController setupScrollViewFrame:self.view.frame];
	[bookmarkViewController setupViewFrame:self.view.frame];
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
