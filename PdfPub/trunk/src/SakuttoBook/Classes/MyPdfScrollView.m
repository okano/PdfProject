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
@synthesize originalPageSize, originalPageWidth, originalPageHeight;
@synthesize currentContentId;

#pragma mark -
- (void)setupUiScrollView {
	// Set up the UIScrollView
	self.showsVerticalScrollIndicator = YES;
	self.showsHorizontalScrollIndicator = YES;
	self.bouncesZoom = YES;
	self.decelerationRate = UIScrollViewDecelerationRateFast;
	self.delegate = self;
	[self setBackgroundColor:[UIColor colorWithRed:PAGE_BACKGROUND_COLOR_R
											 green:PAGE_BACKGROUND_COLOR_G
											  blue:PAGE_BACKGROUND_COLOR_B
											 alpha:1]];
	self.maximumZoomScale = 1.5f;	//5.0;
	self.minimumZoomScale = 1.0f;	//0.01f;//.25;
	
	//Get size for touch.
	//pageRectOriginal = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
	originalPageWidth = originalPageSize.width;
	originalPageHeight = originalPageSize.height;
	
	//
	pageImageView = nil;
	pdfImageTmp = nil;
}


- (void)setupWithPageNum:(NSUInteger)newPageNum
{
	LOG_CURRENT_METHOD;
	[self setupWithPageNum:newPageNum ContentId:currentContentId];
}
- (void)setupWithPageNum:(NSUInteger)newPageNum ContentId:(ContentId)cid
{
	//release before use.
	if (pdfImageTmp) {
		[pdfImageTmp release];
		pdfImageTmp = nil;
	}
	
	//Get Page.
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
#if defined(IS_MULTI_CONTENTS) && IS_MULTI_CONTENTS != 0
	//LOG_CURRENT_METHOD;
	//NSLog(@"newPageNum=%d, contentId=%d", newPageNum, cid);
	pdfImageTmp = [appDelegate getPdfPageImageWithPageNum:newPageNum WithContentId:cid];
#else
	pdfImageTmp = [appDelegate getPdfPageImageWithPageNum:newPageNum WithContentId:HaveNotContentId];
#endif
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
	originalPageWidth = originalPageSize.width;
	originalPageHeight = originalPageSize.height;
	
	scaleWithAspectFitWidth  = newSize.width  / originalPageWidth;
	scaleWithAspectFitHeight = newSize.height / originalPageHeight;
	//NSLog(@"original width=%f, height=%f", originalPageWidth, originalPageHeight);
	//NSLog(@"newSize width=%f, height=%f", newSize.width, newSize.height);
	//NSLog(@"scaleWithAspectFitWidth=%f", scaleWithAspectFitWidth);
	//NSLog(@"scaleWithAspectFitHeight=%f", scaleWithAspectFitHeight);
	
	//Determin Tatenaga / Yokonaga than screen.
	bool isTatenagaThanScreen;
	if (scaleWithAspectFitWidth < scaleWithAspectFitHeight) {
		isTatenagaThanScreen = NO;		// Yokonaga PDF.
	} else {
		isTatenagaThanScreen = YES;		// Tatenaga PDF.
	}

	//Set scale and rect for Draw.
	if (isTatenagaThanScreen == YES) {
		// Tatenaga PDF.
		//LOG_CURRENT_LINE;
		scaleForDraw = scaleWithAspectFitHeight;
	} else {
		// Yokonaga PDF.
		//LOG_CURRENT_LINE;
		scaleForDraw = scaleWithAspectFitWidth;
	}
	
	pageRectForDraw = pageRectOriginal;
	pageRectForDraw.size = CGSizeMake(originalPageWidth  * scaleForDraw,
									  originalPageHeight * scaleForDraw);
	
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
	if (isTatenagaThanScreen == YES) {
		if (pdfImageTmp.size.height <= self.frame.size.height) {
			//PDF < Screen. tatenaga.
			//LOG_CURRENT_LINE;
			self.minimumZoomScale = self.frame.size.height / pdfImageTmp.size.height;
			self.maximumZoomScale = self.frame.size.height / pdfImageTmp.size.height;
		} else {
			//Screen < PDF. tatenaga.
			//LOG_CURRENT_LINE;
			self.minimumZoomScale = self.frame.size.height / pdfImageTmp.size.height;
			self.maximumZoomScale = 1.0f;
		}
	} else {
		if (pdfImageTmp.size.width <= self.frame.size.width) {
			//PDF < Screen. yokonaga.
			//LOG_CURRENT_LINE;
			self.minimumZoomScale = self.frame.size.width / pdfImageTmp.size.width;
			self.maximumZoomScale = self.frame.size.width / pdfImageTmp.size.width;
		} else {
			//Screen < PDF. yokonaga.
			//LOG_CURRENT_LINE;
			self.minimumZoomScale = self.frame.size.width / pdfImageTmp.size.width;
			self.maximumZoomScale = 1.0f;
		}
	}
	//NSLog(@"self.frame.size=%@", NSStringFromCGSize(self.frame.size));
	//NSLog(@"minimumZoomScale=%f, maximumZoomScale=%f",self.minimumZoomScale, self.maximumZoomScale);
	
	//Zoom to full-size.
	[self resetScrollView];
	
}

/**
 *returns scaled image from pdfImage var.
 */
/*
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
*/


#pragma mark -
- (void)resetScrollView
{
	//LOG_CURRENT_METHOD;
	
	//Zoom to full-size.
	[self setZoomScale:self.minimumZoomScale animated:YES];
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
- (void)addScalableSubview:(UIView *)view withPdfBasedFrame:(CGRect)pdfBasedFrame {
	//LOG_CURRENT_METHOD;
	//NSLog(@"pdfBasedFrame=%@", NSStringFromCGRect(pdfBasedFrame));
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
		//NSLog(@"pdfImageTmp.size=%@", NSStringFromCGSize(pdfImageTmp.size));
		//NSLog(@"self.frame.size=%@", NSStringFromCGSize(self.frame.size));
		
		/*
		//
		CGFloat myscale;
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			myscale = [[UIScreen mainScreen] scale];
		} else {
			myscale = 2.0f;
		}
		*/
		
		CGFloat scaleToFitWidthByImage;
		if (self.originalPageWidth < CACHE_IMAGE_WIDTH_MIN) {
			scaleToFitWidthByImage = CACHE_IMAGE_WIDTH_MIN / originalPageWidth;
		} else {
			scaleToFitWidthByImage = 1.0f;
		}
		
		rect = CGRectMake(pdfBasedFrame.origin.x * scaleToFitWidthByImage,
						  pdfBasedFrame.origin.y * scaleToFitWidthByImage,
						  pdfBasedFrame.size.width * scaleToFitWidthByImage,
						  pdfBasedFrame.size.height * scaleToFitWidthByImage);
		
		/*
		if (1.0f < scaleForDraw) {
			//Original PDF size < Screen.
			rect.origin.x = pdfBasedFrame.origin.x * scaleForDraw * myscale;
			rect.origin.y = pdfBasedFrame.origin.y * scaleForDraw * myscale;
			rect.size.width = pdfBasedFrame.size.width * scaleForDraw * myscale;
			rect.size.height = pdfBasedFrame.size.height * scaleForDraw * myscale;
		} else {
			//Screen < Original PDF size.
			//rect = pdfBasedFrame;
			//rect = CGRectMake(pdfBasedFrame.origin.x * scaleForDraw * myscale,
			//				  pdfBasedFrame.origin.y * scaleForDraw * myscale,
			//				  pdfBasedFrame.size.width * scaleForDraw * myscale,
			//				  pdfBasedFrame.size.height * scaleForDraw * myscale);
			rect = pdfBasedFrame;
		}
		 */
	}
	
	//debug area for Large PDF.
	//rect = CGRectMake(10.0f, 10.0f, 360.0f, 288.0f);
	//debug area for Small PDF.
	//rect = CGRectMake( 5.0f,  5.0f,  70.0f, 106.0f);
	
	view.frame = rect;
	//NSLog(@"draw %@ view. frame=%@", [view class], NSStringFromCGRect(rect));

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

//locate imageView to center always.
//@see: http://stackoverflow.com/questions/1316451/center-content-of-uiscrollview-when-smaller
- (void)scrollViewDidZoom:(UIScrollView *)aScrollView
{
	//LOG_CURRENT_METHOD;
    CGFloat offsetX = (self.bounds.size.width > self.contentSize.width)? 
    (self.bounds.size.width - self.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (self.bounds.size.height > self.contentSize.height)? 
    (self.bounds.size.height - self.contentSize.height) * 0.5 : 0.0;
    pageImageView.center = CGPointMake(self.contentSize.width * 0.5 + offsetX, 
                                   self.contentSize.height * 0.5 + offsetY);
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
