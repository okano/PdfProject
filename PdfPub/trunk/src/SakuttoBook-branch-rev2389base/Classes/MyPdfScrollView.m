//
//  MyPdfScrollView.m
//  Pdf2iPad
//
//  Created by okano on 10/12/20.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "MyPdfScrollView.h"


@implementation MyPdfScrollView
@synthesize pageImageView;
@synthesize pdfImageTmp;
@synthesize scaleForDraw;
@synthesize originalPageWidth, originalPageHeight;

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
}


- (void)setupWithPageNum:(NSUInteger)newPageNum
{
	//Get Page.
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	pdfImageTmp = [appDelegate getPdfPageImageWithPageNum:newPageNum];
	if (!pdfImageTmp) {
		LOG_CURRENT_METHOD;
		LOG_CURRENT_LINE;
		NSLog(@"cannot open page, newPageNum=%d", newPageNum);
		return;
	}
	[self setupCurrentPageWithSize:self.frame.size];
}

/**
 *(re)create pdfImageView in this pdfScrollView.
 *
 */
- (void)setupCurrentPageWithSize:(CGSize)newSize
{
	//LOG_CURRENT_METHOD;
	
	//Get size for touch.
	//pageRectOriginal = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
	originalPageWidth  = pdfImageTmp.size.width;
	originalPageHeight = pdfImageTmp.size.height;
	scaleWithAspectFitWidth  = newSize.width  / originalPageWidth;
	scaleWithAspectFitHeight = newSize.height / originalPageHeight;
	//NSLog(@"original width=%f, height=%f", originalPageWidth, originalPageHeight);
	//NSLog(@"newSize width=%f, height=%f", newSize.width, newSize.height);
	
	//Set scale and rect for Draw.
	scaleForDraw = scaleWithAspectFitWidth;
	
	pageRectForDraw = pageRectOriginal;
	pageRectForDraw.size = CGSizeMake(originalPageWidth  * scaleForDraw,
									  originalPageHeight * scaleForDraw);
	
	//UIImage* image = [self getPdfImageWithRect:pageRectForDraw scale:scaleForDraw];
	UIImage* image = pdfImageTmp;
	
	//Remove old pageImageView before generate new.
	if (pageImageView) {
		[pageImageView removeFromSuperview];
		[pageImageView release];
		pageImageView = nil;
	}
	
	//Generate new pageImageView.
	pageImageView = [[UIImageView alloc] initWithImage:image];
	pageImageView.userInteractionEnabled = YES;	//for inPageScrollView.
	//pageImageView.image = image;
	[self addSubview:pageImageView];
	
	//Set contentSize.
	self.contentSize = image.size;
	//NSLog(@"contentSize=%f,%f", self.contentSize.width, self.contentSize.height);
	//[image release];
	
	//Set zoomScale range.
	CGFloat minZoomCandidate = 0.0f;
	CGFloat maxZoomCandidate = 0.0f;
	if (image.size.width <= self.frame.size.width) {
		//PDF < Screen.
		minZoomCandidate = self.frame.size.width / image.size.width;
		maxZoomCandidate = self.frame.size.width / image.size.width;
		self.minimumZoomScale = minZoomCandidate;
		self.maximumZoomScale = maxZoomCandidate;
	} else {
		minZoomCandidate = self.frame.size.width / image.size.width;
		if (1.0f < minZoomCandidate) {
			self.minimumZoomScale = 1.0f;
		} else {
			self.minimumZoomScale = minZoomCandidate;
		}
		maxZoomCandidate = image.size.width / self.frame.size.width;
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
	//NSLog(@"minimumZoomScale = %f (candidate = %f), maximumZoomScale = %f (candidate = %f)", self.minimumZoomScale, minZoomCandidate, self.maximumZoomScale, maxZoomCandidate);
	
	//Zoom to full-size.
	[self resetScrollView];
	
}

/**
 *returns scaled image from pdfImage var.
 */
- (UIImage*)getPdfImageWithRect:(CGRect)pageRect scale:(CGFloat)pdfScale {
	//Create Context for image.
	UIGraphicsBeginImageContext(pageRect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	if (! context) {
		NSLog(@"no context.");
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
	[self setZoomScale:self.minimumZoomScale animated:YES];
	[self setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
	//[self zoomToRect:pageImageView.frame animated:YES];
	
	//NSLog(@"zoomScale = %f", self.zoomScale);
}

#pragma mark -
#pragma mark Treat subview.
// Add subview.(movieLink, UrlLink, inPageScrollView, ...)
- (void)addScalableSubview:(UIView *)view withPdfBasedFrame:(CGRect)pdfBasedFrame {
	//LOG_CURRENT_METHOD;
	//NSLog(@"self.zoomScale=%f", self.zoomScale);
	//NSLog(@"scaleForDraw=%f", scaleForDraw);
	
	CGRect rect;
	if ([view isKindOfClass:[UIScrollView class]] == YES) {
		rect.origin.x = pdfBasedFrame.origin.x * scaleForDraw;
		rect.origin.y = pdfBasedFrame.origin.y * scaleForDraw;
		//do not change width, height.
		rect.size = pdfBasedFrame.size;
		//do not change contentSize in UIScrollView.
		
		//UIScrollView* sv = (UIScrollView*)view;
		//CGSize size = CGSizeMake(sv.contentSize.width * scaleForDraw,
		//						 sv.contentSize.height * scaleForDraw);
		//sv.contentSize = size;
		//NSLog(@"contentSize = %f,%f", sv.contentSize.width, sv.contentSize.height);
		//NSLog(@"has %d subviews", [sv.subviews count]);
	} else {
		rect.origin.x = pdfBasedFrame.origin.x * scaleForDraw;
		rect.origin.y = pdfBasedFrame.origin.y * scaleForDraw;
		rect.size.width = pdfBasedFrame.size.width * scaleForDraw;
		rect.size.height = pdfBasedFrame.size.height * scaleForDraw;	
	}
	view.frame = rect;
	//NSLog(@"rect=%f,%f,%f,%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

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
	if (scale <= self.minimumZoomScale) {
		self.scrollEnabled = FALSE;
	} else {
		self.scrollEnabled = TRUE;

	}

	return;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
	return;
}

#pragma mark -
#pragma mark other methods.
- (void)dealloc {
	//CGPDFPageRelease(page);
	//CGPDFDocumentRelease(pdf);
    [super dealloc];
}

@end
