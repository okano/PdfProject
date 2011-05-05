//    File: PDFScrollView.m
//Abstract: UIScrollView subclass that handles the user input to zoom the PDF page.  This class handles swapping the TiledPDFViews when the zoom level changes.
#import "PDFScrollView.h"
#import "TiledPDFView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PDFScrollView


#pragma mark -
//- (id)initWithFrame:(CGRect)frame

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super initWithCoder:decoder])) {
		
		// Set up the UIScrollView
        self.showsVerticalScrollIndicator = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
		[self setBackgroundColor:[UIColor grayColor]];
		self.maximumZoomScale = 5.0;
		self.minimumZoomScale = 0.01f;//.25;
		
    }
    return self;
}


#pragma mark -
- (void)initPdfWithFilename:(NSString*)filename {
	// Open the PDF document
	NSURL *pdfURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
	if (!pdfURL) {
		NSLog(@"file not found. filename=%@", filename);
		//
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"file not found"
							  message:[NSString stringWithFormat:@"%@ not found.", filename]
							  delegate:nil
							  cancelButtonTitle:nil
							  otherButtonTitles:@"OK", nil
							  ];
		[alert show];
		return;
	}
	pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
	
	/*
	// Get the PDF Page that we will be drawing
	page = CGPDFDocumentGetPage(pdf, 1);
	CGPDFPageRetain(page);
	
	// determine the size of the PDF page
	pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
	pdfScale = self.frame.size.width/pageRect.size.width;
	originalPdfScale = pdfScale;
	pageRect.size = CGSizeMake(pageRect.size.width*pdfScale, pageRect.size.height*pdfScale);
	
	
	// Create a low res image representation of the PDF page to display before the TiledPDFView
	// renders its content.
	UIGraphicsBeginImageContext(pageRect.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// First fill the background with white.
	CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
	CGContextFillRect(context,pageRect);
	
	CGContextSaveGState(context);
	// Flip the context so that the PDF page is rendered
	// right side up.
	CGContextTranslateCTM(context, 0.0, pageRect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	// Scale the context so that the PDF page is rendered 
	// at the correct size for the zoom level.
	CGContextScaleCTM(context, pdfScale,pdfScale);	
	CGContextDrawPDFPage(context, page);
	CGContextRestoreGState(context);
	
	UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
	backgroundImageView.frame = pageRect;
	backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
	[self addSubview:backgroundImageView];
	[self sendSubviewToBack:backgroundImageView];
	
	
	// Create the TiledPDFView based on the size of the PDF page and scale it to fit the view.
	pdfView = [[TiledPDFView alloc] initWithFrame:pageRect andScale:pdfScale];
	[pdfView setPage:page];
	
	[self addSubview:pdfView];
	*/
}


#pragma mark -
- (void)setupWithPageNum:(NSUInteger)newPageNum {
	
	//
	//LOG_CURRENT_LINE;
	//NSLog(@"have %d views", [self.subviews count]);
	
	//remove all subviews.
	for (UIView* v in self.subviews) {
		[v removeFromSuperview];
	}
	//
	//LOG_CURRENT_LINE;
	//NSLog(@"have %d views", [self.subviews count]);
	
	[pdfView removeFromSuperview];
	//[backgroundImageView removeFromSuperview];
	
	//remove all subviews.
	//for (UIView* subView in self.subviews) {
	//	[subView removeFromSuperview];
	//}
	
	
	// Get the PDF Page that we will be drawing
	page = CGPDFDocumentGetPage(pdf, newPageNum);
	CGPDFPageRetain(page);
	
	
	
	// determine the size of the PDF page
	pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
	pdfScale = self.frame.size.width/pageRect.size.width;
	originalPdfScale = pdfScale;
	pageRect.size = CGSizeMake(pageRect.size.width*pdfScale, pageRect.size.height*pdfScale);
	//NSLog(@"pageRect=(%f, %f), size %f * %f", pageRect.origin.x, pageRect.origin.y, pageRect.size.width, pageRect.size.height);
	
	// Create a low res image representation of the PDF page to display before the TiledPDFView
	// renders its content.
	UIGraphicsBeginImageContext(pageRect.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// First fill the background with white.
	CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
	CGContextFillRect(context,pageRect);
	
	CGContextSaveGState(context);
	// Flip the context so that the PDF page is rendered
	// right side up.
	CGContextTranslateCTM(context, 0.0, pageRect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	// Scale the context so that the PDF page is rendered 
	// at the correct size for the zoom level.
	CGContextScaleCTM(context, pdfScale,pdfScale);	
	CGContextDrawPDFPage(context, page);
	CGContextRestoreGState(context);
	
	UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
	backgroundImageView.frame = pageRect;
	backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
	[self addSubview:backgroundImageView];
	[self sendSubviewToBack:backgroundImageView];
	[backgroundImageView retain];
	
	// Create the TiledPDFView based on the size of the PDF page and scale it to fit the view.
	pdfView = [[TiledPDFView alloc] initWithFrame:pageRect andScale:pdfScale];
	[pdfView setPage:page];
	
	[self addSubview:pdfView];
	[pdfView retain];
	
	
	//LOG_CURRENT_LINE;
	//NSLog(@"have %d views", [self.subviews count]);
}

#pragma mark -
- (void)dealloc
{
	// Clean up
    [pdfView release];
	[backgroundImageView release];
	CGPDFPageRelease(page);
	CGPDFDocumentRelease(pdf);
    [super dealloc];
}

#pragma mark -
#pragma mark Override layoutSubviews to center content

// We use layoutSubviews to center the PDF page in the view
- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    // center the image as it becomes smaller than the size of the screen
	
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = pdfView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    pdfView.frame = frameToCenter;
	backgroundImageView.frame = frameToCenter;
    
	// to handle the interaction between CATiledLayer and high resolution screens, we need to manually set the
	// tiling view's contentScaleFactor to 1.0. (If we omitted this, it would be 2.0 on high resolution screens,
	// which would cause the CATiledLayer to ask us for tiles of the wrong scales.)
	pdfView.contentScaleFactor = 1.0;
}

#pragma mark -
#pragma mark UIScrollView delegate methods

// A UIScrollView delegate callback, called when the user starts zooming. 
// We return our current TiledPDFView.
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return pdfView;
}

// A UIScrollView delegate callback, called when the user stops zooming.  When the user stops zooming
// we create a new TiledPDFView based on the new zoom level and draw it on top of the old TiledPDFView.
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	// set the new scale factor for the TiledPDFView
	pdfScale *=scale;		NSLog(@"scale=%4.2f, pdfScale=%4.2f", scale, pdfScale);
	//
	if (pdfScale < originalPdfScale) {
		pdfScale = originalPdfScale;
	}
	
	
	// Calculate the new frame for the new TiledPDFView
	CGRect newPageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
	newPageRect.size = CGSizeMake(newPageRect.size.width*pdfScale, newPageRect.size.height*pdfScale);
	
	// Create a new TiledPDFView based on new frame and scaling.
	pdfView = [[TiledPDFView alloc] initWithFrame:newPageRect andScale:pdfScale];
	[pdfView setPage:page];
	
	// Add the new TiledPDFView to the PDFScrollView.
	[self addSubview:pdfView];
}

// A UIScrollView delegate callback, called when the user begins zooming.  When the user begins zooming
// we remove the old TiledPDFView and set the current TiledPDFView to be the old view so we can create a
// a new TiledPDFView when the zooming ends.
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
	// Remove back tiled view.
	[oldPDFView removeFromSuperview];
	[oldPDFView release];
	
	// Set the current TiledPDFView to be the old view.
	oldPDFView = pdfView;
	[self addSubview:oldPDFView];
}

@end
