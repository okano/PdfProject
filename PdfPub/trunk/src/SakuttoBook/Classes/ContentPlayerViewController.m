//
//  ContentPlayerView.m
//  SakuttoBook
//
//  Created by okano on 11/05/31.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "ContentPlayerViewController.h"


@implementation ContentPlayerViewController


@synthesize pdfScrollView1, pdfScrollView2, pdfScrollView3;
@synthesize pdfURL, isVerticalWriting;
//@synthesize imageView1, imageView2, imageView3;
//@synthesize image1, image2, image3;
@synthesize currentContentId;
@synthesize menuViewController, menuBottomViewController, /* bottomToolBar,*/ webViewController, tocViewController, pageSmallViewController, bookmarkViewController;
@synthesize isShownMenuBar, isShownTocView, isShownPageSmallView, isShownBookmarkView;
//@synthesize currentImageView;
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//LOG_CURRENT_METHOD;
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
	
	//Fit view size with screen. (iPhone-3.5inch/iPhone-4inch/iPad/iPad-Retina)
	self.view.frame = [[UIScreen mainScreen] bounds];
	
	
	//Setup subviews.
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
	
	//Gesture for MarkerPen.
	panRecognizer1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan2:)];
	panRecognizer2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan2:)];
	panRecognizer3 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan2:)];
	[pdfScrollView1 addGestureRecognizer:panRecognizer1];
	[pdfScrollView2 addGestureRecognizer:panRecognizer2];
	[pdfScrollView3 addGestureRecognizer:panRecognizer3];
	
	//Setup Maker Pen.
	menuBarForMakerPen = nil;
	[self loadMarkerPenFromUserDefault];
	[self setupMarkerPenView];
	[self setupMarkerPenMenu];
	[self exitMarkerMode];
	
	//Set current content id.
	//currentContentId = [self getCurrentContentIdFromUserDefault];
	if ([self isMultiContents] == TRUE) {
		//Mulit Contents.
		//Do-nothing.
	} else {
		//Single Content.
		currentContentId = 1;
	}
	
	//Setup maxPageNum.
	if ([self setupPdfBasicInfo:currentContentId] == FALSE) {
		NSLog(@"cannot get pdf infomation.");
		return;
	}
	
	
	//Generate Page Samll image.
	//generate when need.(for launch speed up.)
	
	//Remove all image cache when debug.
#ifdef TARGET_IPHONE_SIMULATOR
	if (0==1) {
		[self removeAllImageCache];
	}
#endif
	
	//Show top page.
	//LOG_CURRENT_LINE;
	//NSLog(@"currentContentId=%d", currentContentId);
	////NSLog(@"pdf scroll view currentContentId=%d, %d, %d",
	////	  pdfScrollView1.currentContentId,
	////	  pdfScrollView2.currentContentId,
	////	  pdfScrollView3.currentContentId);
	[self drawPageWithNumber:currentPageNum];
	[self.view setNeedsDisplay];
	
#pragma mark (MenuBar and other)
	//Setup MenuBar.
	menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuView" bundle:[NSBundle mainBundle]];
	CGRect menuBarFrame = menuViewController.view.frame;	//Fit with self.view.
	menuBarFrame.size.width = self.view.frame.size.width;//Fit size only width.
	menuViewController.view.frame = menuBarFrame;
	[self.view addSubview:menuViewController.view];
	
	//Setup Bottom menu bar.
	//bottomMenuViewController = [[UIViewController alloc] init];
	menuBottomViewController = [[MenuViewController alloc] initWithNibName:@"MenuBottomView" bundle:[NSBundle mainBundle]];
	CGRect menuBottomBarFrame = menuBottomViewController.view.frame;	//Fit with self.view.
	menuBottomBarFrame.size.width = self.view.frame.size.width;//Fit size only width.
	menuBottomBarFrame.origin.y = self.view.frame.size.height - menuBottomBarFrame.size.height;
	menuBottomViewController.view.frame = menuBottomBarFrame;
	[self.view addSubview:menuBottomViewController.view];

	[self hideMenuBar];
	
	//Setup WebView.
	//generate when need.
	webViewController = nil;
	urlForWeb = [[NSMutableString alloc] init];
	
	//Setup Url Links.
	linksInCurrentPage = [[NSMutableArray alloc] init];
	[self renderPageLinkAtIndex:currentPageNum];
	
	// Setup for Url Links With CSV.
	[self parseUrlLinkWithCsvDefine];
	[self renderUrlLinkWithCsvAtIndex:currentPageNum];
	
	// Setup for Movie play.
	[self parseMovieDefine];
	[self renderMovieLinkAtIndex:currentPageNum];
	
	// Setup for Mail send.
	[self parseMailDefine];
	[self renderMailLinkAtIndex:currentPageNum];
	
	// Setup for Sound play.
	[self parseSoundOnPageDefine];
	audioPlayer = nil;	//init when use.
	soundDelayTimer = nil;
	
	// Setup for PageJumpLink.
	[self parsePageJumpLinkDefine];
	[self renderPageJumpLinkAtIndex:currentPageNum];
	
	// Setup for InPage ScrollView.
	[self parseInPageScrollViewDefine];
	[self renderInPageScrollViewAtIndex:currentPageNum];
	
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
	
	// Setup Page Small Image Toc View.
	pageSmallViewController = [[PageSmallViewController alloc] init];
	isShownPageSmallView = FALSE;
	
	// Setup Bookmark View.
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	appDelegate.bookmarkDefine = nil;
	[self loadBookmark];
	bookmarkViewController = [[BookmarkViewController alloc] initWithNibName:@"BookmarkView" bundle:[NSBundle mainBundle]];
	CGRect bookmarkViewFrame = bookmarkViewController.view.frame;	//Fit with self.view.
	bookmarkViewFrame.size.width = self.view.frame.size.width;
	bookmarkViewFrame.size.height = self.view.frame.size.height;
	bookmarkViewController.view.frame = bookmarkViewFrame;
	isShownBookmarkView = FALSE;
	
#pragma mark (Read LastReadPage from UserDefault)
	int lastReadPage = [self getLatestReadPage];
	if (0 < lastReadPage) {
		[self switchToPage:lastReadPage];
	}
	
	
	[self playSoundAtIndex:currentPageNum];
}


#pragma mark -
#pragma mark setup pdf infomation.
- (ContentId)getCurrentContentIdFromUserDefault
{
	return (ContentId)currentContentId;
}
/*
- (void)setCurrentContentId:(ContentId)cid
{
	currentContentId = cid;
	pdfScrollView1.currentContentId = cid;
	pdfScrollView2.currentContentId = cid;
	pdfScrollView3.currentContentId = cid;
}
*/
- (BOOL)setupPdfBasicInfo:(ContentId)cid
{
	/*
	//Setup PDF filename.(chached in this class)
	//parse csv file.
	NSString* targetFilename = @"pdfDefine";
	NSArray* lines;
	lines = [FileUtility parseDefineCsv:targetFilename];
	//NSLog(@"lines count=%d, lines=%@.", [lines count], [lines description]);

	NSString* pdfFilename;
	if ([lines count] < 1) {
		NSLog(@"no PDF file specified.");
		pdfFilename = [NSString stringWithFormat:@"document.pdf"];
	} else {
		if ([self isMultiContents] == TRUE) {
			//Multi Contents
			if (cid <= [lines count]) {
				//
				//(1)内蔵のpdfDefine.csv内にあれば、それを使用する。
				//   行番号＝コンテンツID
				pdfFilename = [lines objectAtIndex:(cid - 1)];
			} else {
				//
				//(2)なければ、ダウンロードしたcsvファイル内のpdfDefine.csvを使用する。
				//   フォルダ名＝コンテンツID。
				//NSLog(@"ContentId not found in NAIZOU pdfDefine.csv. maxnumber=%d, passedContentId=%d.", [lines count], cid);
				pdfFilename = [NSString stringWithFormat:@"%d.pdf", cid];
			}
		} else {
			//Single Content.
			pdfFilename = [lines objectAtIndex:0];
		}
		
		//Check line with comma. ex:"document.pdf,document-ipad.pdf"
		NSArray* tmpCsvArray = [pdfFilename componentsSeparatedByString:@","];
		if (2 <= [tmpCsvArray count]) {		//line with comma.
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				// iPad
				pdfFilename = [tmpCsvArray objectAtIndex:1];
			} else {
				// iPhone
				pdfFilename = [tmpCsvArray objectAtIndex:0];
			}
		}
	}
	//NSString* pdfFilenameFormatted = [self formatStringWithAlphaNumeric:pdfFilename];
	*/
	
	
	
	//内蔵ファイルでもダウンロードしたファイルでも、~/Documents/contentBody/{cid}/pdf/ フォルダにコピーされるので、
	//ファイル名は {cid}.pdf に固定となる。
	NSString* pdfFilename = [NSString stringWithFormat:@"%d.pdf", cid];
	
	
	
	
	//Open PDF file from (1)ContentBody Directory (2)mainBundle
	NSString* pdfFilenameFull = [ContentFileUtility getContentBodyFilenamePdf:[NSString stringWithFormat:@"%d", cid]];
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
		
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"error"
														 message:@"このコンテンツにはPDFファイルが存在しません。"
														delegate:nil
											   cancelButtonTitle:nil
											   otherButtonTitles:@"OK",nil]
							  autorelease];
		[alert show];
		
		//does not close(release) this view before method terminate.
		
		//SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
		//[appDelegate hideContentPlayerView];
		//[appDelegate showContentListView];

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
	
	
	//parse pdfDefine.csv for determine vertical/horizontal MEKURI direction.
	//(note: pdf filename is determin in first launchup.)
	bool isVerticalWritingInDefault;
#if defined(IS_VERTICAL_PDF) && IS_VERTICAL_PDF != 0
	isVerticalWritingInDefault = TRUE;	//tategaki.
#else
	isVerticalWritingInDefault = FALSE;	//yokogaki.
#endif
	
	NSString* targetFilename = CSVFILE_PDFDEFINE;
	NSArray* lines;
	if ([self isMultiContents] == TRUE) {
		lines = [FileUtility parseDefineCsv:targetFilename contentId:currentContentId];
	} else {
		lines = [FileUtility parseDefineCsv:targetFilename];
	}
	
	
	//parse each line.
	//
	//page-progression-direction:rtl	//yokogaki
	//or
	//page-progression-direction:ltr	//tategaki
	//
	isVerticalWriting = isVerticalWritingInDefault;
	NSCharacterSet* skippedCharacters = [NSCharacterSet characterSetWithCharactersInString:@":,=;"];
	if (2 <= [lines count]) {
		for (int i = 1; i < [lines count]; i++)
		{
			NSString* lineOrg = [lines objectAtIndex:i];
			NSString* line = [lineOrg stringByReplacingOccurrencesOfString:@" " withString:@""];
			NSArray* tmpCsvArray = [line componentsSeparatedByCharactersInSet:skippedCharacters];
			NSString* keyStr = [tmpCsvArray objectAtIndex:0];
			if ([[keyStr lowercaseString] compare:PAGE_PROGRESSION_DIRECTION] == NSOrderedSame)
			{
				NSString* valueStrOrg = [tmpCsvArray objectAtIndex:1];
				NSString* valueStr = [valueStrOrg stringByReplacingOccurrencesOfString:@"\"" withString:@""];
				if ([[valueStr lowercaseString] compare:PAGE_PROGRESSION_DIRECTION_LTR] == NSOrderedSame)
				{
					isVerticalWriting = YES;	//overwrite with csv.
				} else if ([[valueStr lowercaseString] compare:PAGE_PROGRESSION_DIRECTION_RTL] == NSOrderedSame)
				{
					isVerticalWriting = NO;		//overwrite with csv.
				}
			}
		}
	}
	
	
	return TRUE;
}

#pragma mark handle PDF infomation.
/*
//IS_VERTICAL_PDF: 0=horizon(yokogaki), 1=vertical(tategaki).
- (BOOL)isVerticalWriting
{
#if defined(IS_VERTICAL_PDF) && IS_VERTICAL_PDF != 0
	return YES;	//tategaki.
#else
	return NO;	//yokogaki.
#endif
}
*/

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
- (NSString*)getPageFilenameFull:(int)pageNum WithContentId:(ContentId)cid{
	return [FileUtility getPageFilenameFull:pageNum WithContentId:cid];
}

- (NSString*)getPageSmallFilenameFull:(int)pageNum {
	if ([self isMultiContents] == TRUE) {
		return [FileUtility getPageSmallFilenameFull:pageNum WithContentId:currentContentId];
	} else {
		return [FileUtility getPageSmallFilenameFull:pageNum];
	}
	/*
	NSString* filename = [NSString stringWithFormat:@"%@%d", PAGE_FILE_SMALL_PREFIX, pageNum];
	NSString* targetFilenameFull = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:PAGE_FILE_SMALL_EXTENSION];
	return targetFilenameFull;
	*/
}
- (NSString*)getPageSmallFilenameFull:(int)pageNum WithContentId:(ContentId)cid{
	return [FileUtility getPageSmallFilenameFull:pageNum WithContentId:cid];
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
	//Get image from file if exists.
	NSString* targetFilenameFull;
#if defined(IS_MULTI_CONTENTS) && IS_MULTI_CONTENTS != 0
	targetFilenameFull = [FileUtility getPageFilenameFull:pageNum WithContentId:currentContentId];
#else
	targetFilenameFull = [FileUtility getPageFilenameFull:pageNum];
#endif
	
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
		[ig generateImageWithPageNum:pageNum fromUrl:pdfURL minWidth:CACHE_IMAGE_WIDTH_MIN maxWidth:CACHE_IMAGE_WIDTH_MAX];
		[ig release];
		
		UIImage* pdfImage = [[UIImage alloc] initWithContentsOfFile:targetFilenameFull];
		if (pdfImage) {
			//Page Small image is generated ondemand.
			//[self generatePageSmallImageFromImage:pdfImage width:CACHE_IMAGE_SMALL_WIDTH pageNumForSave:pageNum];
			
			return pdfImage;
		} else {
			NSLog(@"page generate but can not open image from file. for page %d filename=%@", pageNum, targetFilenameFull);
#if defined(IS_MULTI_CONTENTS) && IS_MULTI_CONTENTS != 0
			NSLog(@"currentContentId=%d", currentContentId);
#endif
			return nil;
		}
	}
	
	[targetFilenameFull release];
	return nil;
}



/*
- (void)generatePageSmallImageFromImage:(UIImage*)baseImage width:(CGFloat)newWidth pageNumForSave:(NSUInteger)pageNum
{
	//LOG_CURRENT_METHOD;
	
	//Calicurate new size.
	CGFloat scale = baseImage.size.width / newWidth;
	CGSize newSize = CGSizeMake(baseImage.size.width / scale,
								baseImage.size.height / scale);
	//NSLog(@"newSize for page small=%f,%f", newSize.width, newSize.height);
	
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
	NSString* targetFilenameFull = [self getPageSmallFilenameFull:pageNum];
	[FileUtility makeDir:targetFilenameFull];
	NSError* error = nil;
	[data writeToFile:targetFilenameFull options:NSDataWritingAtomic error:&error];
	if (error) {
		LOG_CURRENT_METHOD;
		NSLog(@"page small cache file write error. path=%@", targetFilenameFull);
		NSLog(@"error=%@, error code=%d", [error localizedDescription], [error code]);
		
	} else {
		//NSLog(@"wrote page small cache file to %@", targetFilenameFull);
	}
	
	//Set Ignore Backup.
	[FileUtility addSkipBackupAttributeToItemWithString:targetFilenameFull];
}
*/

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
		targetFilenameFull = [self getPageSmallFilenameFull:i];
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
	[currentPdfScrollView setupWithPageNum:newPageNum ContentId:currentContentId];
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
	
	//
	//[self getPdfDictionaryWithPageNum:currentPageNum];
	[self renderPageLinkAtIndex:currentPageNum];
	[self renderUrlLinkWithCsvAtIndex:currentPageNum];
	[self renderMovieLinkAtIndex:currentPageNum];
	[self renderMailLinkAtIndex:currentPageNum];
	[self renderPageJumpLinkAtIndex:currentPageNum];
	[self renderInPageScrollViewAtIndex:currentPageNum];
	[self renderPopoverScrollImageLinkAtIndex:currentPageNum];
	[self playSoundAtIndex:currentPageNum];	//play sound for new page.
	//Marker Pen
	[self setupMarkerPenMenu];
	//[self setupMarkerPenViewAtPage:currentPageNum];
	[self renderMarkerPenFromUserDefaultAtPage:currentPageNum];
	[self.view bringSubviewToFront:markerPenView2];
	
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
	
	//NSLog(@"(new)currentPdfScrollView subviews = %d", [currentPdfScrollView.subviews count]);
	//
	[self renderPageLinkAtIndex:currentPageNum];
	[self renderUrlLinkWithCsvAtIndex:currentPageNum];
	[self renderMovieLinkAtIndex:currentPageNum];
	[self renderMailLinkAtIndex:currentPageNum];
	[self renderPageJumpLinkAtIndex:currentPageNum];
	[self renderInPageScrollViewAtIndex:currentPageNum];
	[self renderPopoverScrollImageLinkAtIndex:currentPageNum];
	[self playSoundAtIndex:currentPageNum];	//play sound for new page.
	//Marker Pen
	[self setupMarkerPenMenu];
	//[self setupMarkerPenViewAtPage:currentPageNum];
	[self renderMarkerPenFromUserDefaultAtPage:currentPageNum];
	[self.view bringSubviewToFront:markerPenView2];
	
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
	[currentPdfScrollView setupWithPageNum:currentPageNum ContentId:currentContentId];
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
	[self.tocViewController.view removeFromSuperview];
	
	//Draw link to URL, Movie, etc.
	[self renderPageLinkAtIndex:currentPageNum];
	[self renderUrlLinkWithCsvAtIndex:currentPageNum];
	[self renderMovieLinkAtIndex:currentPageNum];
	[self renderMailLinkAtIndex:currentPageNum];
	[self renderPageJumpLinkAtIndex:currentPageNum];
	[self renderInPageScrollViewAtIndex:currentPageNum];
	[self renderPopoverScrollImageLinkAtIndex:currentPageNum];
	[self playSoundAtIndex:currentPageNum];	//play sound for new page.
	//Marker Pen
	[self setupMarkerPenMenu];
	//[self setupMarkerPenViewAtPage:currentPageNum];
	[self renderMarkerPenFromUserDefaultAtPage:currentPageNum];
	[self.view bringSubviewToFront:markerPenView2];
	
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
	
	
	// Check if TocView, PageSmallView, BookmarkVew shown, then hide it.
	if (isShownTocView) {
		[self hideTocView];
		return;
	}
	if (isShownPageSmallView) {
		[self hidePageSmallView];
		return;
	}
	if (isShownBookmarkView) {
		[self hideBookmarkView];
	}
	if (isMarkerPenMode == YES) {
		// do nothing in MarkerMode.
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
			//[self showWebViewSelector:urlStr];
			[self showWebView:urlStr];
			
			//no-continue.
			return;
		}
	}
	
	// Compare with Url Define with CSV in page.
	for (NSMutableDictionary* urlLinkInfo in urlDefineWithCsv) {
		int targetPageNum = [[urlLinkInfo valueForKey:MD_PAGE_NUMBER] intValue];
		if (targetPageNum == currentPageNum) {
			CGRect rect;
			rect.origin.x	= [[urlLinkInfo valueForKey:MD_AREA_X] floatValue];
			rect.origin.y	= [[urlLinkInfo valueForKey:MD_AREA_Y] floatValue];
			rect.size.width	= [[urlLinkInfo valueForKey:MD_AREA_WIDTH] floatValue];
			rect.size.height= [[urlLinkInfo valueForKey:MD_AREA_HEIGHT] floatValue];
			//NSLog(@"frame with popover Scroll Image Info info=%@", NSStringFromCGRect(rect));
			//NSLog(@"touchedPoint=%@", NSStringFromCGPoint(touchedPoint));
			//NSLog(@"touchedPointInOriginalPdf=%@", NSStringFromCGPoint(touchedPointInOriginalPdf));
			
			if (CGRectContainsPoint(rect, touchedPointInOriginalPdf)) {
				NSString* urlStr = [urlLinkInfo valueForKey:ULWC_URL];
				//open with anotherView/Safari(show selecter).
				[self showWebView:urlStr];
				
				//no-continue.
				return;
			}
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
	
	// Compare with Mail Link in page.
	for (NSMutableDictionary* mailInfo in mailDefine) {
		int targetPageNum = [[mailInfo valueForKey:MD_PAGE_NUMBER] intValue];
		if (targetPageNum == currentPageNum) {
			CGRect rect;
			rect.origin.x	= [[mailInfo valueForKey:MD_AREA_X] floatValue];
			rect.origin.y	= [[mailInfo valueForKey:MD_AREA_Y] floatValue];
			rect.size.width	= [[mailInfo valueForKey:MD_AREA_WIDTH] floatValue];
			rect.size.height= [[mailInfo valueForKey:MD_AREA_HEIGHT] floatValue];
			//NSLog(@"frame with movie info=%@", NSStringFromCGRect(rect));
			//NSLog(@"touchedPoint=%@", NSStringFromCGPoint(touchedPoint));
			//NSLog(@"touchedPointInOriginalPdf=%@", NSStringFromCGPoint(touchedPointInOriginalPdf));
			
			if (CGRectContainsPoint(rect, touchedPointInOriginalPdf)) {
				//NSLog(@"mail link touched.");
				
				//open with another view.
				NSString* subject = nil;
				NSString* messageBody = nil;
				NSArray* toRecipient  = nil;
				NSArray* ccRecipient  = nil;
				NSArray* bccRecipient = nil;
				if ([mailInfo valueForKey:MS_SUBJECT] != nil) {
					subject = [mailInfo valueForKey:MS_SUBJECT];
				}
				if ([mailInfo valueForKey:MS_BODY] != nil) {
					messageBody = [mailInfo valueForKey:MS_BODY];
				}
				if ([mailInfo valueForKey:MS_TO_ADDESSES] != nil) {
					toRecipient  = [mailInfo valueForKey:MS_TO_ADDESSES];
				}
				if ([mailInfo valueForKey:MS_CC_ADDESSES] != nil) {
					ccRecipient  = [mailInfo valueForKey:MS_CC_ADDESSES];
				}
				if ([mailInfo valueForKey:MS_BCC_ADDESSES] != nil) {
					bccRecipient = [mailInfo valueForKey:MS_BCC_ADDESSES];
				}
				[self showMailComposerWithSubject:subject
									  toRecipient:toRecipient
									  ccRecipient:ccRecipient
									 bccRecipient:bccRecipient
									  messageBody:messageBody];
				
				//no-continue.
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
			
			if (CGRectContainsPoint(rect, touchedPointInOriginalPdf)) {
				int jumpToPage = [[pageJumpLinkInfo valueForKey:PJ_PAGE_JUMPTO] intValue];
				//NSLog(@"PageJumpLink touched. jumpToPage=%d", jumpToPage);
				
				//no-continue.
				[self switchToPage:jumpToPage];
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
	
	leftTapArea = CGRectMake(baseWidthForParentView   * TAP_AREA_LEFT_X,
							 baseHeightForParentView  * TAP_AREA_LEFT_Y,
							 baseWidthForParentView   * TAP_AREA_LEFT_WIDTH,
							 baseHeightForParentView  * TAP_AREA_LEFT_HEIGHT);
	rightTapArea = CGRectMake(baseWidthForParentView  * TAP_AREA_RIGHT_X,
							  baseHeightForParentView * TAP_AREA_RIGHT_Y,
							  baseWidthForParentView  * TAP_AREA_RIGHT_WIDTH,
							  baseHeightForParentView * TAP_AREA_RIGHT_HEIGHT);
	topTapArea = CGRectMake(baseWidthForParentView    * TAP_AREA_TOP_X,
							baseHeightForParentView   * TAP_AREA_TOP_Y,
							baseWidthForParentView    * TAP_AREA_TOP_WIDTH,
							baseHeightForParentView   * TAP_AREA_TOP_HEIGHT);
	bottomTapArea = CGRectMake(baseWidthForParentView * TAP_AREA_BOTTOM_X,
							   baseHeightForParentView* TAP_AREA_BOTTOM_Y,
							   baseWidthForParentView * TAP_AREA_BOTTOM_WIDTH,
							   baseHeightForParentView* TAP_AREA_BOTTOM_HEIGHT);
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
#if defined(ENABLED_TRANSITION) && ENABLED_TRANSITION == 0
	return;
#endif
	
	[self hideMenuBar];
	if ([self isVerticalWriting]) {
		[self gotoNextPage];
	} else {
		[self gotoPrevPage];
	}
	
}
- (void)handleTapInRightArea:(UIGestureRecognizer*)gestureRecognizer
{
#if defined(ENABLED_TRANSITION) && ENABLED_TRANSITION == 0
	return;
#endif
	
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
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self toggleMenuBar];
	}
}

- (void)handleTapInScrollView:(UIGestureRecognizer*)sender
{
	LOG_CURRENT_METHOD;
}

- (void)handleSwipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
#if defined(ENABLED_TRANSITION) && ENABLED_TRANSITION == 0
	return;
#endif
	
	//do nothing if in marker pen mode.
	if (isMarkerPenMode == YES) {
		return;
	}
	
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
	NSString* targetFilename = CSVFILE_MOVIE;
	NSArray* lines;
	if ([self isMultiContents] == TRUE) {
		lines = [FileUtility parseDefineCsv:targetFilename contentId:currentContentId];
	} else {
		lines = [FileUtility parseDefineCsv:targetFilename];
	}
	
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
	
	//Play movie. file from local file.
	NSString* cidStr = [NSString stringWithFormat:@"%d", currentContentId];
	NSString *moviePath = [[ContentFileUtility getContentBodyMovieDirectoryWithContentId:cidStr]
						   stringByAppendingPathComponent:filename];
	if (! moviePath) {
		//LOG_CURRENT_METHOD;
		NSLog(@"no movie file found. filename=%@, moviePath=%@", filename, moviePath);
		
		//Play movie. file from Main Bundle.
		moviePath = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
		if (!moviePath) {
			NSLog(@"illigal filename. filename=%@, bundle_resourceURL=%@", filename, [[NSBundle mainBundle] resourceURL]);
			NSLog(@"f = %@ %@", [filename stringByDeletingPathExtension], [filename pathExtension]);
			return;
		}
	}
	NSURL* url;
	
	if ((url = [NSURL fileURLWithPath:moviePath]) != nil) {
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
			
			/*
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
			 */
			
			//Show pageJumpLink link area with half-opaque.
			//UIView* areaView = [[UIView alloc] initWithFrame:rect];
			//UIView* areaView = [[UIView alloc] initWithFrame:touchableArea];
			UIView* areaView = [[UIView alloc] initWithFrame:CGRectZero];
			
#if TARGET_IPHONE_SIMULATOR
			//Only show on Simulator.
			[areaView setBackgroundColor:[UIColor purpleColor]];
			[areaView setAlpha:0.2f];
#else
			[areaView setAlpha:0.0f];
#endif
			
			//[currentPdfScrollView addSubview:areaView];
			//[currentPdfScrollView addScalableSubview:areaView withNormalizedFrame:rect];
			
			//[currentPdfScrollView addScalableSubview:areaView withPdfBasedFrame:touchableArea];
			
			[currentPdfScrollView addScalableSubview:areaView withPdfBasedFrame:rect];
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
			NSString* tmpStrFormatted = [self formatStringWithAlphaNumeric:tmpStr];
			[filenamesArray addObject:tmpStrFormatted];
		}
		
		[tmpDict setValue:filenamesArray forKey:IPSD_FILENAMES];
		
		
		//Check page range.
		if (maxPageNum < [[tmpDict objectForKey:IPSD_PAGE_NUMBER] intValue]) {
			continue;	//skip to next object. not add to define.
		}
		
		//Add to ipsd define.
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
#pragma mark Treat popover scroll image view.
//Parse Popover Scroll Image Define.
- (void)parsePopoverScrollImageDefine
{
	popoverScrollImageDefine = [[NSMutableArray alloc] init];
	
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
		
		//Add to popover Scroll Image define.
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
			
			//NSString* filename = [popoverScrollImageInfo valueForKey:MD_MOVIE_FILENAME];
			
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
			//NSLog(@"render popoverScrollImage link. rect=%f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
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
	
	NSString* cidStr = [NSString stringWithFormat:@"%d", currentContentId];
	NSString* filenameFull = [[ContentFileUtility getContentBodyImageDirectoryWithContentId:cidStr]
							  stringByAppendingPathComponent:filename];
	
	PopoverScrollImageViewController* psivc;
	psivc = [[PopoverScrollImageViewController alloc] initWithImageFilename:filenameFull frame:rect];
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
- (void)parseTocDefine
{
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	if ([appDelegate.tocDefine isKindOfClass:[NSMutableArray class]]) {
		[appDelegate.tocDefine removeAllObjects];
	} else {
		appDelegate.tocDefine = [[NSMutableArray alloc] init];
	}
	
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
			NSLog(@"toc specify out of page range. maxPageNum=%d, page in toc=%d", maxPageNum, [[tmpDict objectForKey:TOC_PAGE] intValue]);
			continue;	//skip to next object. not add to define.
		}
		
		//Add to toc define.
		[appDelegate.tocDefine addObject:tmpDict];
	}
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

#pragma mark Treat PageSmallView(ImageTOC).
- (void)showPageSmallView {
	[self hideMenuBar];
	
	//Setup with tocDefine.
	[pageSmallViewController setupImages];
	
	//Show by addSubview.
	//Add to superview. think with toolbar.
	[self.view.superview addSubview:pageSmallViewController.view];
	
	//Set flag.
	isShownPageSmallView = TRUE;
}
- (void)hidePageSmallView {
	//Hide by removeSuperView.
	[pageSmallViewController.view removeFromSuperview];
	isShownPageSmallView = FALSE;
}

#pragma mark Treat Bookmark.
- (BOOL)loadBookmark
{
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	if (appDelegate.bookmarkDefine == nil) {
		[appDelegate.bookmarkDefine release];
		appDelegate.bookmarkDefine = nil;
	}
	appDelegate.bookmarkDefine = [[[NSMutableArray alloc] init] autorelease];	//use default autoreleasepool.
	
	//
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
	
	//NSLog(@"bookmark(for cid=%d)=%@", currentContentId, [obj description]);
	return YES;
}
- (void)saveBookmark
{
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	if (appDelegate.bookmarkDefine == nil) {
		return;
	}
	
	//Store bookmark infomation to UserDefault.
	NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
	if ([self isMultiContents] == YES) {
		//Load from UserDefault.
		NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
		NSMutableArray* bookmarkForMultiContent = nil;
		bookmarkForMultiContent = [[NSMutableArray alloc] initWithArray:[settings valueForKey:BOOKMARK_MULTI_CONTENT]];
		//NSLog(@"all bookmark before save=%@", [bookmarkForMultiContent description]);
		
		//Remove before marge.
		if (bookmarkForMultiContent != nil) {
			for (NSDictionary* tmpDict in bookmarkForMultiContent) {
				ContentId candidateCid = [[tmpDict valueForKey:CONTENT_CID] intValue];
				if (candidateCid == currentContentId) {
					[bookmarkForMultiContent removeObject:tmpDict];
					break;
				}
			}
		} else {
			bookmarkForMultiContent = [[NSMutableArray alloc] init];
		}
		//Merge bookmark infomation with another ContentId.
		NSMutableDictionary* bookmarkWithContentId = [[NSMutableDictionary alloc] init];
		[bookmarkWithContentId setValue:[NSNumber numberWithInt:currentContentId ] forKey:CONTENT_CID];
		[bookmarkWithContentId setObject:appDelegate.bookmarkDefine forKey:BOOKMARK_ARRAY];
		[bookmarkForMultiContent addObject:bookmarkWithContentId];
		//NSLog(@"all bookmark after marge=%@", [bookmarkForMultiContent description]);
		//Add to UserDefault.
		[userDefault setObject:bookmarkForMultiContent forKey:BOOKMARK_MULTI_CONTENT];
	} else {
		[userDefault setObject:appDelegate.bookmarkDefine forKey:BOOKMARK_ARRAY];
	}
	[userDefault synchronize];
}

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
	CGRect bookmarkModifyViewFrame = bmvc.view.frame;	//Fit with self.view.
	bookmarkModifyViewFrame.size.width = self.view.frame.size.width;
	bookmarkModifyViewFrame.size.height = self.view.frame.size.height;
	bmvc.view.frame = bookmarkModifyViewFrame;
	bmvc.modalPresentationStyle = UIModalPresentationCurrentContext;
	[self presentViewController:bmvc animated:YES completion:nil];
	
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
	NSLog(@"bookmarks has %d items after add for cid=%d.", [bookmarks count], currentContentId);
	
	
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
	[self loadBookmark];
	[bookmarkViewController reloadDataForce];
	
	[tmpDict release];
	[bookmarks release];
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
	
	//show bottom menu.
	[self showBottomMenu];
	
	isShownMenuBar = YES;
}
- (void)hideMenuBar
{
	[UIView beginAnimations:@"menuBarHide" context:nil];
	menuViewController.view.alpha = 0.0f;
	[UIView commitAnimations];
	
	//hide bottom menu.
	[self hideBottomMenu];
	
	isShownMenuBar = NO;
}


#pragma mark -
#pragma mark Show other view.
- (IBAction)showInfoView
{
	//LOG_CURRENT_METHOD;
	[self hideMenuBar];
	InfomationViewController* vc = [[InfomationViewController alloc] initWithNibName:@"InfomationView" bundle:[NSBundle mainBundle]];
	vc.contentId = currentContentId;
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
/* 0:ask everytime, 1:open in this application, 2:open with Safari(close this application) */
- (void)showWebView:(NSString*)urlString
{
#if defined(OPEN_URL_WITH) && OPEN_URL_WITH == 1
	[self showWebViewInThisApp:urlString];
#elif defined(OPEN_URL_WITH) && OPEN_URL_WITH == 2
	[self showWebWithSafari:urlString];
#else
	[self showWebViewSelector:urlString];
#endif
}

- (void)showWebViewSelector:(NSString*)urlString
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"urlString=%@", urlString);
	[urlForWeb setString:urlString];
	//NSLog(@"urlForWeb=%@", urlForWeb);
    UIActionSheet *sheet = nil;
	
	//
	//@see: http://iphone-app-developer.seesaa.net/article/292824365.html
	//      4インチのiPhone5（1,136 x 640ピクセル）画面対応
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { // iPad
		// iPadのときの処理
		//No "cancel" button.
		sheet =[[UIActionSheet alloc]
				initWithTitle:@"URLリンクを開く (リンクからAppStoreにアクセスする場合は、Safariを起動してください)"
				delegate:self
				cancelButtonTitle:nil
				destructiveButtonTitle:nil
				otherButtonTitles:@"アプリ内のビューワで開く", @"Safariを起動して開く", nil];
		[sheet showInView:self.view];
	} else { // iPhone
		sheet =[[UIActionSheet alloc]
				initWithTitle:@"URLリンクを開く (リンクからAppStoreにアクセスする場合は、Safariを起動してください)"
				delegate:self
				cancelButtonTitle:@"Cancel"
				destructiveButtonTitle:nil
				otherButtonTitles:@"アプリ内のビューワで開く", @"Safariを起動して開く", nil];
		
		CGRect frame = [[UIScreen mainScreen] applicationFrame];
		NSLog(@"frame size height = %f", frame.size.height);
		if (frame.size.height >= 568.0) { // iPhone 4inch (568 - 20 px)
			// iPhone5 のときの処理
			[sheet showInView:self.pdfScrollView1];
			//[sheet showInView:self.view.window];
			
		} else { // iPhone 3.5inch
			// iPhone5より前のモデル のときの処理
			[sheet showInView:self.view];	//[sheet showInView:self.view.window];
		}
	}
	sheet.tag = ACTIONSHEET_TAG_SHOW_WEBVIEW_SELECTOR;
    [sheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//LOG_CURRENT_METHOD;
	
	//check action sheet kind.
	if (actionSheet.tag != ACTIONSHEET_TAG_SHOW_WEBVIEW_SELECTOR) {
		return;
	}
	
	if (! urlForWeb) {
		LOG_CURRENT_LINE;
		NSLog(@"no URL set");
		return;
	}
	//NSLog(@"urlForWeb=%@", urlForWeb);
	
	if (buttonIndex == 0) {
		[self showWebViewInThisApp:urlForWeb];
	} else if (buttonIndex == 1) {
		[self showWebWithSafari:urlForWeb];
	}
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
	return;
}

- (void)showWebViewInThisApp:(NSString*)urlString
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
	[self renderPageLinkAtIndex:currentPageNum];
	[self renderMovieLinkAtIndex:currentPageNum];
	[self renderMailLinkAtIndex:currentPageNum];
	[self renderPageJumpLinkAtIndex:currentPageNum];
	[self renderInPageScrollViewAtIndex:currentPageNum];
	//Marker Pen
	[self setupMarkerPenMenu];
	//[self setupMarkerPenViewAtPage:currentPageNum];
	[self renderMarkerPenFromUserDefaultAtPage:currentPageNum];
	[self.view bringSubviewToFront:markerPenView2];
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
	if ([self isMultiContents] == TRUE) {
		//Multi Contents.
		NSMutableArray* allLatestReadPageInfo = [[NSMutableArray alloc] initWithArray:[userDefault valueForKey:USERDEFAULT_LATEST_READ_PAGE_MULTICONTENT]];
		if (! allLatestReadPageInfo) {
			//Not exist any read page info. Generate it.
			NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
			[tmpDict setValue:[NSNumber numberWithInt:currentContentId] forKey:CONTENT_CID];
			[tmpDict setValue:[NSNumber numberWithInt:currentPageNum] forKey:USERDEFAULT_LATEST_READ_PAGE];
			NSArray* tmpArray = [[NSArray alloc] initWithObjects:tmpDict, nil];
			[userDefault setValue:tmpArray forKey:USERDEFAULT_LATEST_READ_PAGE_MULTICONTENT];
		} else {
			NSMutableDictionary* newReadPageInfo = [[NSMutableDictionary alloc] init];
			[newReadPageInfo setValue:[NSNumber numberWithInt:currentContentId] forKey:CONTENT_CID];
			[newReadPageInfo setValue:[NSNumber numberWithInt:currentPageNum] forKey:USERDEFAULT_LATEST_READ_PAGE];
			
			for (NSDictionary* readPageInfo in allLatestReadPageInfo) {
				if (currentContentId == [[readPageInfo valueForKey:CONTENT_CID] intValue]) {
					//Exist read page info for current content.
					//remove it before add.
					[allLatestReadPageInfo removeObject:readPageInfo];
					break;
				}
			}
			//add it.
			[allLatestReadPageInfo addObject:newReadPageInfo];
			//Store to UserDefault.
			[userDefault setObject:allLatestReadPageInfo forKey:USERDEFAULT_LATEST_READ_PAGE_MULTICONTENT];
		}
	} else {
		//Single Content.
		[userDefault setInteger:pageNum forKey:USERDEFAULT_LATEST_READ_PAGE];
	}
	[userDefault synchronize];
}
- (int)getLatestReadPage {
	NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	id obj = nil;
	if ([self isMultiContents] == TRUE) {
		//Multi Contents.
		NSArray* tmpArray = [settings valueForKey:USERDEFAULT_LATEST_READ_PAGE_MULTICONTENT];
		if (! tmpArray) {
			return -1;
		}
		//NSLog(@"currentContentId=%d, candidateArray=%@", currentContentId, tmpArray);
		
		for (NSDictionary* latestReadPageInfo in tmpArray) {
			if (currentContentId == [[latestReadPageInfo valueForKey:CONTENT_CID] intValue]) {
				obj = [latestReadPageInfo valueForKey:USERDEFAULT_LATEST_READ_PAGE];
				break;
			}
		}
	} else {
		//Single Content.
		obj = [settings valueForKey:USERDEFAULT_LATEST_READ_PAGE];
	}
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
	/*
	if (soundDelayTimer != nil) {
		if ([soundDelayTimer isValid] == YES) {
			[soundDelayTimer invalidate];
		}
		
		//Do not release NSTimer! (managed in main loop, should onli Invalidated.)
	}
	*/
	
	//release audio player.
	audioPlayer.delegate = nil;
	[audioPlayer dealloc]; audioPlayer = nil;
}

@end
