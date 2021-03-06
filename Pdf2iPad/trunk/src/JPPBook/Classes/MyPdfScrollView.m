//
//  MyPdfScrollView.m
//  Pdf2iPad
//
//  Created by okano on 10/12/20.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "MyPdfScrollView.h"


@implementation MyPdfScrollView
@synthesize currentContentId;

/*
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}
*/

#pragma mark -
- (void)setupUiScrollView {
	// Set up the UIScrollView
	self.showsVerticalScrollIndicator = YES;
	self.showsHorizontalScrollIndicator = YES;
	self.bouncesZoom = YES;
	self.decelerationRate = UIScrollViewDecelerationRateFast;
	self.delegate = self;
	[self setBackgroundColor:[UIColor whiteColor]];
	self.maximumZoomScale = 1.5f;	//5.0;
	self.minimumZoomScale = 1.0f;	//0.01f;//.25;
	
	pageImageView = nil;
	pdfImageTmp = nil;
	
	//
	/*
	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (interfaceOrientation == UIInterfaceOrientationLandscapeRight
		||
		interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
		CGRect rect = CGRectMake(self.frame.origin.x,
								 self.frame.origin.y,
								 self.frame.size.height,
								 self.frame.size.width);
		self.frame = rect;
	}
	*/
}


- (void)setupWithPageNum:(NSUInteger)newPageNum
{
	LOG_CURRENT_METHOD;
	//NSLog(@"newPageNum=%d, curentContentId=%d", newPageNum, currentContentId);
	[self setupWithPageNum:newPageNum ContentId:currentContentId];
}
- (void)setupWithPageNum:(NSUInteger)newPageNum ContentId:(ContentId)cid
{
	//Release before use.
	if (pdfImageTmp) {
		[pdfImageTmp release];
		pdfImageTmp = nil;
	}
	
	//Get Page.
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
#if defined(IS_MULTI_CONTENTS) && IS_MULTI_CONTENTS != 0
	//LOG_CURRENT_METHOD;
	//NSLog(@"newPageNum=%d, contentId=%d", newPageNum, cid);
	pdfImageTmp = [appDelegate getPdfPageImageWithPageNum:newPageNum WithContentId:cid];
#else
	pdfImageTmp = [appDelegate getPdfPageImageWithPageNum:newPageNum];
#endif
	if (!pdfImageTmp) {
		LOG_CURRENT_METHOD;
		LOG_CURRENT_LINE;
		NSLog(@"cannot openpage, newPageNum=%d", newPageNum);
		return;
	}
	
	[self setupCurrentPageWithSize:self.frame.size];
}

/**
 *(re)create pdfImageView in this pdfScrollView.
 */
- (void)setupCurrentPageWithSize:(CGSize)newSize
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"newSize for MyPdfScrollView=%@", NSStringFromCGSize(newSize));
	//NSLog(@"original size=%@", NSStringFromCGSize(pdfImageTmp.size));
	
	//Get size for touch.
	//originalPageWidth  is not use.
	//originalPageHeight is not use.
	scaleWithAspectFitWidth  = newSize.width  / originalPageSize.width;
	scaleWithAspectFitHeight = newSize.height / originalPageSize.height;
	//NSLog(@"original width=%f, height=%f", originalPageWidth, originalPageHeight);
	//NSLog(@"newSize width=%f, height=%f", newSize.width, newSize.height);
	
	//Set scale and rect for Draw.
	scaleForDraw = scaleWithAspectFitWidth;
	//NSLog(@"scaleForDraw=%f", scaleForDraw);
	
	pageRectForDraw = CGRectMake(0,
								 0,
								 originalPageSize.width  * scaleForDraw,
								 originalPageSize.height * scaleForDraw);
	
	
	
	//Set scale with cache image.(fit width with CACHE_IMAGE_WIDTH)
	scaleForCache = CACHE_IMAGE_WIDTH / originalPageSize.width;
	
	
	//Remove old pageImageView before generate new.
	if (pageImageView) {
		[pageImageView removeFromSuperview];
		[pageImageView release];
		pageImageView = nil;
	}
	
	//Generate new pageImageView.
	pageImageView = [[UIImageView alloc] initWithImage:pdfImageTmp];
	pageImageView.userInteractionEnabled = YES;	//for inPageScrollView.
	//pageImageView.image = image;
	[self addSubview:pageImageView];
	
	//Set contentSize.
	self.contentSize = pdfImageTmp.size;
	//NSLog(@"contentSize=%f,%f", self.contentSize.width, self.contentSize.height);
	//[image release];
	
	//Set zoomScale range.
	[self setupZoomScaleWithSize:newSize];
	
	//Zoom to full-size.
	[self resetScrollView];
}

- (void)setupZoomScaleWithSize:(CGSize)newSize
{
	if (pdfImageTmp == nil) {
		return;
	}
	CGFloat minZoomCandidate = 0.0f;
	CGFloat maxZoomCandidate = 0.0f;
	//NSLog(@"pdfImageTmp.size=%@, newSize=%@", NSStringFromCGSize(pdfImageTmp.size), NSStringFromCGSize(newSize));
	if (pdfImageTmp.size.width <= newSize.width) {
		//PDF < Screen.
		minZoomCandidate = newSize.width / pdfImageTmp.size.width;
		maxZoomCandidate = newSize.width / pdfImageTmp.size.width;
		self.minimumZoomScale = minZoomCandidate;
		self.maximumZoomScale = maxZoomCandidate;
	} else {
		minZoomCandidate = newSize.width / pdfImageTmp.size.width;
		if (1.0f < minZoomCandidate) {
			self.minimumZoomScale = 1.0f;
		} else {
			self.minimumZoomScale = minZoomCandidate;
		}
		maxZoomCandidate = pdfImageTmp.size.width / self.frame.size.width;
		if (maxZoomCandidate < 1.0f) {
			self.maximumZoomScale = maxZoomCandidate;
		} else {
			self.maximumZoomScale = 1.0f;
		}
		if (self.maximumZoomScale < self.minimumZoomScale) {
			CGFloat tmp;
			tmp = self.maximumZoomScale;
			self.maximumZoomScale = self.minimumZoomScale;
			self.minimumZoomScale = tmp;
			tmp = 0.0f;
		}
	}
	[self setZoomScale:self.minimumZoomScale];

	//NSLog(@"minimumZoomScale = %f (candidate = %f), maximumZoomScale = %f (candidate = %f)", self.minimumZoomScale, minZoomCandidate, self.maximumZoomScale, maxZoomCandidate);
}


/**
 *returns scaled image from pdfImage var.
 */
- (UIImage*)getPdfImageWithRect:(CGRect)pageRect scale:(CGFloat)pdfScale {
	//Create Context for iamge.
	UIGraphicsBeginImageContext(pageRect.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	if (! context) {
		//LOG_CURRENT_METHOD;
		//NSLog(@"no context.");
		return nil;
	}
	
	//Scaled.
	UIGraphicsBeginImageContext(pageRect.size);
	[pdfImageTmp drawInRect:pageRect];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}


#pragma mark -
- (void)resetScrollView
{
	//LOG_CURRENT_METHOD;
	
	//Zoom to full-size.
	//NSLog(@"minimumZoomScale=%f", self.minimumZoomScale);
	if (self.minimumZoomScale < INFINITY) {
		//setZoomScale has BUG!. "animated:YES" occurs scroll disabled.
		[self setZoomScale:self.minimumZoomScale animated:NO];
		[self setContentOffset:CGPointMake(0.0f, 0.0f)];
		[self scrollsToTop];
		[self flashScrollIndicators];
	}
	[self setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
	//[self zoomToRect:pageImageView.frame animated:YES];
	
	//NSLog(@"zoomScale = %f", self.zoomScale);
	
	//Remove subviews in pageImageView(added by addScalableSubview)
	for (UIView* view in [pageImageView subviews]) {
		[view removeFromSuperview];
	}
}

#pragma mark -
#pragma mark Treat subview.
// Add subview.(movieLink, UrlLink, inPageScrollView, ...)
- (void)addScalableSubview:(UIView *)view withNormalizedFrame:(CGRect)normalizedFrame {
	//LOG_CURRENT_METHOD;
	//NSLog(@"self.zoomScale=%f", self.zoomScale);
	//NSLog(@"scaleForDraw=%f", scaleForDraw);
	//NSLog(@"normalizedFrame=%@", NSStringFromCGRect(normalizedFrame));
	
	CGRect rect;
	if ([view isKindOfClass:[UIScrollView class]] == YES) {	//For InPagePDF.
		//Setup Position.
		rect.origin.x = normalizedFrame.origin.x * scaleForDraw;
		rect.origin.y = normalizedFrame.origin.y * scaleForDraw;
		
		//Setup Size.
		UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
		if (interfaceOrientation == UIInterfaceOrientationPortrait
			||
			interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			//do not change width, height.
			rect.origin.x = normalizedFrame.origin.x * scaleForDraw;
			rect.origin.y = normalizedFrame.origin.y * scaleForDraw;
			rect.size = normalizedFrame.size;
		} else {
			rect.origin.x = normalizedFrame.origin.x * scaleForDraw / (1024.0f / 768.0f);
			rect.origin.y = normalizedFrame.origin.y * scaleForDraw / (1024.0f / 768.0f);
			//scale with width, height.
			rect.size.width = normalizedFrame.size.width;
			rect.size.height = normalizedFrame.size.height;
			//scale contentSize in UIScrollView.
			UIScrollView* sv = (UIScrollView*)view;
			CGSize newContentSize = CGSizeMake(sv.contentSize.width * scaleForDraw / (1024.0f / 768.0f),
											   sv.contentSize.height * scaleForDraw / (1024.0f / 768.0f));
			sv.contentSize = newContentSize;
		}
		//NSLog(@"contentSize = %f,%f", sv.contentSize.width, sv.contentSize.height);
		//NSLog(@"has %d subviews", [sv.subviews count]);
	} else {
		UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
		if (interfaceOrientation == UIInterfaceOrientationPortrait
			||
			interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			rect.origin.x = normalizedFrame.origin.x * scaleForDraw;
			rect.origin.y = normalizedFrame.origin.y * scaleForDraw;
			rect.size.width = normalizedFrame.size.width * scaleForDraw;
			rect.size.height = normalizedFrame.size.height * scaleForDraw;	
		} else {
			rect.origin.x = normalizedFrame.origin.x * scaleForDraw / (1024.0f / 768.0f);
			rect.origin.y = normalizedFrame.origin.y * scaleForDraw / (1024.0f / 768.0f);
			rect.size.width = normalizedFrame.size.width * scaleForDraw / (1024.0f / 768.0f);
			rect.size.height = normalizedFrame.size.height * scaleForDraw / (1024.0f / 768.0f);	
		}
	}
	view.frame = rect;
	//NSLog(@"scaledFrame=%@", NSStringFromCGRect(rect));

	[pageImageView addSubview:view];
}

//Clean up subview. remove subviews except pageImageView.
- (void)cleanupSubviews
{
	for (UIView* v in self.pageImageView.subviews) {
		[v removeFromSuperview];
	}
	//LOG_CURRENT_METHOD;
	//NSLog(@"MyPdfScrollView has %d subviews, pageImageView has %d subviews", [self.subviews count], [self.pageImageView.subviews count]);
}


#pragma mark -
#pragma mark handle rotate.
/*
- (void)layoutSubviews 
{
    [super layoutSubviews];
}
*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/
#pragma mark -
#pragma mark UIScrollView delegate methods

// A UIScrollView delegate callback, called when the user starts zooming. 
// We return our current TiledPDFView.
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return pageImageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	//NSLog(@"scale at scrollViewDidEndZooming = %f, contentOffset=%@", scale, NSStringFromCGPoint(self.contentOffset));
	//NSLog(@"zoom end. scale=%f", self.zoomScale);
	return;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
	//NSLog(@"zoom began. scale=%f", self.zoomScale);
	return;
}

#pragma mark -
- (void)dealloc {
    [super dealloc];
}

@end
