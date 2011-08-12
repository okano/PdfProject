//
//  CosmeLessonView.m
//  CosmeLesson01
//
//  Created by okano on 11/06/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CosmeLessonViewController.h"


@implementation CosmeLessonViewController

@synthesize scrollView;
@synthesize colorWidthInfoDS;

#pragma mark - show / hide view.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		menuBarForMakerPen = nil;
		//
		colorSelectorTVC = nil;
		colorSelectorView = nil;
		colorSelectorToolbar = nil;
		isShownImagePicker = NO;
    }
    return self;
}

- (void)setupThisView
{
	currentPageNum = 1;	//only page 1.
	
	
	//Setup frame of this view.
	CGRect viewFrame = CGRectZero;
#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 30200)
	// sdk upper 3.2
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// iPad
		viewFrame = CGRectMake(0, 0, 768, 1024);
	}
	else {
		// other
		viewFrame = CGRectMake(0, 0, 320, 480);
	}
#else
	// sdk under 3.2
#endif
	self.view.frame = viewFrame;
	
	
	//load image.
	[self loadDefaultImage];
	
	//
	CGRect imageRect = CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height);
	[self setupMarkerPenView:imageRect];
	[self setupMarkerPenMenu];

	//
	originalPageWidth  = image.size.width;
	originalPageHeight = image.size.height;
	scaleWithAspectFitWidth  = image.size.width  / originalPageWidth;
	scaleWithAspectFitHeight = image.size.height / originalPageHeight;
	//NSLog(@"original width=%f, height=%f", originalPageWidth, originalPageHeight);
	//NSLog(@"newSize width=%f, height=%f", newSize.width, newSize.height);
	
	//Set scale and rect for Draw.
	scaleForDraw = scaleWithAspectFitWidth;
	//NSLog(@"scaleForDraw=%f", scaleForDraw);
	
	
	
	//
	markerPenView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
	
	//Gesture for MarkerPen.
	panRecognizer1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	[self.view addGestureRecognizer:panRecognizer1];
	
	//Exit marker mode when start.
	[self exitMarkerMode];
	
	//Set first color and width.
	[self setLineColorAndWidthWithIndex:0];
}

- (void)loadDefaultImage
{
	NSString* targetFilename =  [[NSBundle mainBundle] pathForResource:@"IMG_6267" ofType:@"JPG"];
	image = [UIImage imageWithContentsOfFile:targetFilename];
	if (image == nil) {
		NSLog(@"image not found.");
		return;
	}
	[self setupImage:image];
}
- (void)setupImage:(UIImage*)newImage
{
	imageView.image = newImage;
	imageView.frame = CGRectMake(0.0f, 0.0f, newImage.size.width, newImage.size.height);

	scrollView.contentSize = CGSizeMake(newImage.size.width, newImage.size.height);  
	
	scrollView.delegate = self;
	
	
	//Setup scale.
	CGFloat widthRatio = self.view.frame.size.width / newImage.size.width;
	CGFloat heightRatio = self.view.frame.size.height / newImage.size.height;
	CGFloat ratio;
	if (widthRatio < heightRatio) {
		ratio = widthRatio;
	} else {
		ratio = heightRatio;
	}
	scrollView.minimumZoomScale = ratio;
	scrollView.maximumZoomScale = 1.0f;
	
	[scrollView setZoomScale:scrollView.minimumZoomScale];
}

- (IBAction)hideCosmeLessonView
{
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate hideCosmeLessonView];
}
- (IBAction)switchToContentPlayerView
{
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate switchToContentPlayerView];
}
- (IBAction)showImageSelector
{
	//show picture selector.
	//LOG_CURRENT_METHOD;
	[self openImagePickerFromBarButtonItem:[[toolbar items] objectAtIndex:2]];
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
	
	[imageView addSubview:view];
}

//Clean up subview. remove subviews except pageImageView.
- (void)cleanupSubviews
{
	for (UIView* v in imageView.subviews) {
		[v removeFromSuperview];
	}
	//LOG_CURRENT_METHOD;
	//NSLog(@"MyPdfScrollView has %d subviews, pageImageView has %d subviews", [self.subviews count], [self.pageImageView.subviews count]);
}




#pragma mark - UIScrollView delegate methods.
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return imageView;
}
//locate imageView to center always.
//@see: http://stackoverflow.com/questions/1316451/center-content-of-uiscrollview-when-smaller
- (void)scrollViewDidZoom:(UIScrollView *)aScrollView
{
	//LOG_CURRENT_METHOD;
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)? 
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)? 
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, 
									   scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - dealloc.
- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	//
	colorWidthInfoDS = [[ColorWidthInfoDS alloc] init];
	[self setupThisView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
