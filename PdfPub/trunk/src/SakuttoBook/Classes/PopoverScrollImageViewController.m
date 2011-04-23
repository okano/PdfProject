    //
//  PopoverScrollImageViewController.m
//  SakuttoBook
//
//  Created by okano on 11/03/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PopoverScrollImageViewController.h"


@implementation PopoverScrollImageViewController

@synthesize parentScrollView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (id)initWithImageFilename:(NSString*)filename;
{
	[super init];
	
	NSString* path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
	if (!path) {
		NSLog(@"illigal filename. filename=%@, bundle_resourceURL=%@", filename, [[NSBundle mainBundle] resourceURL]);
		NSLog(@"f = %@ %@", [filename stringByDeletingPathExtension], [filename pathExtension]);
		return self;
	}
	
	NSURL* url;
	if ((url = [NSURL fileURLWithPath:path]) != nil) {
		//Open image.
		UIImage* image = [[UIImage alloc] initWithContentsOfFile:path];
		if (!image) {
			NSLog(@"no image found. filename=%@", filename);
			return self;
		}
		imageView = [[UIImageView alloc] initWithImage:image];
		
		//Generate UIScrollView and set image.
		scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
		[scrollView addSubview:imageView];
		scrollView.delegate = self;
		scrollView.contentSize = imageView.frame.size;
		scrollView.backgroundColor = [UIColor whiteColor];
		
		//Set Zoom Scale.
		if (self.view.frame.size.width < image.size.width) {
			// image is larger than screen.
			scrollView.minimumZoomScale = self.view.frame.size.width / image.size.width;
			scrollView.maximumZoomScale = 2.0f;
		} else {
			// image is smaller than screen.
			scrollView.minimumZoomScale = 1.0f;
			scrollView.maximumZoomScale = self.view.frame.size.width / image.size.width;
		}
		[scrollView zoomToRect:imageView.frame animated:YES];

		
		//Add gesture for close.
		UITapGestureRecognizer* tapGestureForPopoverScrollImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopoverScrollImagePlayer)];
		[scrollView addGestureRecognizer:tapGestureForPopoverScrollImage];
		[tapGestureForPopoverScrollImage release];
		//Add gesture for zoom.(double tap)
		UITapGestureRecognizer* doubleTapGestureForPopoverScrollImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleZoom:)];
		doubleTapGestureForPopoverScrollImage.numberOfTapsRequired = 2;
		doubleTapGestureForPopoverScrollImage.numberOfTouchesRequired = 1;
		[scrollView addGestureRecognizer:doubleTapGestureForPopoverScrollImage];
		[doubleTapGestureForPopoverScrollImage release];
		//call single-tap if fail double-tap.
		[tapGestureForPopoverScrollImage requireGestureRecognizerToFail:doubleTapGestureForPopoverScrollImage];
		
		[self.view addSubview:scrollView];
	}
	return self;
}

- (void)setParentScrollView:(UIScrollView*)targetParentScrollView fromPosition:(CGPoint)pos fromZoomScale:(CGFloat)scale
{
	parentScrollView = targetParentScrollView;
	parentOffset = pos;
	parentZoomScale = scale;
}

- (void)closePopoverScrollImagePlayer
{
	LOG_CURRENT_METHOD;
	[self.view removeFromSuperview];
	[self repositionParentScrollView];
}

- (void)repositionParentScrollView
{
	[parentScrollView setZoomScale:parentZoomScale];
	[parentScrollView setContentOffset:parentOffset];
}

//locate imageView to center always.
//@see: http://stackoverflow.com/questions/1316451/center-content-of-uiscrollview-when-smaller
- (void)scrollViewDidZoom:(UIScrollView *)aScrollView
{
    LOG_CURRENT_METHOD;
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)? 
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)? 
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, 
                                   scrollView.contentSize.height * 0.5 + offsetY);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return imageView;
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	//LOG_CURRENT_METHOD;
}
- (void)toggleZoom:(UITapGestureRecognizer*)gesture
{
	LOG_CURRENT_METHOD;
	CGPoint touchedPoint;
	touchedPoint = [gesture locationInView:imageView];
	if (scrollView.zoomScale <= scrollView.minimumZoomScale) {
		if (self.view.frame.size.width < imageView.image.size.width) {
			// image is larger than screen.
			CGRect rect;
			rect = CGRectMake(touchedPoint.x - (self.view.frame.size.width / 2),
							  touchedPoint.y - (self.view.frame.size.height / 2),
							  self.view.frame.size.width,
							  self.view.frame.size.height);
			[scrollView zoomToRect:rect animated:YES];
		} else {
			// image is smaller than screen.
			[scrollView setZoomScale:scrollView.maximumZoomScale animated:YES];
		}

	} else {
		[scrollView setZoomScale:scrollView.minimumZoomScale animated:YES];
	}
}

//MARK: -

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[imageView release];
	imageView = nil;
	[scrollView release];
	scrollView = nil;
	
	//
	parentScrollView = nil;
	parentOffset = CGPointZero;
	parentZoomScale = 0.0f;
	
    [super dealloc];
}


@end
