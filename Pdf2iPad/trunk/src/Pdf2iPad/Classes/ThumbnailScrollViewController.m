//
//  ThumbnailScrollViewController.m
//  PdfPub
//
//  Created by okano on 10/12/25.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "ThumbnailScrollViewController.h"


@implementation ThumbnailScrollViewController
@synthesize scrollView;

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


#pragma mark -
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Setup View Size & Position.
	[self setupViewFrame];
	[self.view setBackgroundColor:[UIColor grayColor]];
	
	//Alocate ScrollView.
	scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
	scrollView.backgroundColor = [UIColor grayColor];
	scrollView.scrollEnabled = YES;
	
	//Set bounce.
	scrollView.bounces = NO;
	//scrollView.alwaysBounceVertical = NO;
	//scrollView.alwaysBounceHorizontal = YES;	//YES;
	
	//Setup
	[self setupScrollViewFrame];
	[self.view addSubview:scrollView];
	
	//NSLog(@"view frame=%@", NSStringFromCGRect(self.view.frame));
	//NSLog(@"scrollView frame=%@", NSStringFromCGRect(scrollView.frame));
}

- (void)setupViewFrame
{
	//Setup View Size & Position.
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	Pdf2iPadViewController* vc = (Pdf2iPadViewController*)appDelegate.viewController;
	CGRect tmpRect;
	tmpRect = self.view.frame;
	tmpRect.size.height = 160.0f;
	CGFloat bottomToolBarHeight = 40.0f;
	UIView* v = [vc view];

	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			tmpRect.origin.y = v.frame.size.height - tmpRect.size.height - bottomToolBarHeight;
			tmpRect.size.width = v.frame.size.width;
			break;
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			tmpRect.origin.y = v.frame.size.width - tmpRect.size.height - bottomToolBarHeight;
			tmpRect.size.width = v.frame.size.height;
			break;
		default://Unknown
			tmpRect.origin.y = v.frame.size.height - tmpRect.size.height - bottomToolBarHeight;
			tmpRect.size.width = v.frame.size.width;
			break;
	}
	
	self.view.frame = tmpRect;
	//NSLog(@"thumbnailView.view frame = %@", NSStringFromCGRect(self.view.frame));
}

- (void)setupScrollViewFrame
{
	CGRect rect = scrollView.frame;
	rect.origin.y = 0.0f;

	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			rect.size.width = self.view.frame.size.width;
			break;
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			rect.size.width = self.view.frame.size.width;
			break;
		default://Unknown
			rect.size.width = self.view.frame.size.width;
			break;
	}
	
	scrollView.frame = rect;
}

#pragma mark -
- (IBAction)closeThisView:(id)sender
{
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	Pdf2iPadViewController* vc = (Pdf2iPadViewController*)appDelegate.viewController;
	[(Pdf2iPadViewController*)vc hideThumbnailScrollView];
	//[self.view removeFromSuperview];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
- (void)setupImages
{
	//LOG_CURRENT_METHOD;
	
	CGFloat maxWidth = self.view.frame.size.width;
	
	CGFloat currentOriginX = 0.0f, currentOriginY = 0.0f;
	CGFloat maxHeightInLine;
	//
	CGFloat spacerX = 12.0f, spacerY = 4.0f;
	
	currentOriginX += spacerX;
	currentOriginY += spacerY;
	
	
	
	//Setup with imageArray from tocDefine.
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	for (NSDictionary* tmpDict in appDelegate.tocDefine) {
		NSUInteger pageNum = [[tmpDict objectForKey:TOC_PAGE] intValue];
		NSString* filename = [tmpDict objectForKey:TOC_FILENAME];
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
		} else {
			// Open image from thumbnail file.
			NSString* filenameFull = [appDelegate getThumbnailFilenameFull:pageNum];
			image = [UIImage imageWithContentsOfFile:filenameFull];
			if (! image) {
				LOG_CURRENT_METHOD;
				LOG_CURRENT_LINE;
				NSLog(@"file not found in thumbnail file, filenameFull=%@", filenameFull);
				continue;	//skip to next object.
			}
		}
		
		// Check width.
		if (maxWidth < image.size.width) {
			LOG_CURRENT_METHOD;
			LOG_CURRENT_LINE;
			NSLog(@"image is too huge width. filename=%@, width=%f", filename, image.size.width);
			continue;	//skip to next object.
		}
		
		// Locate.
		CGRect rect = CGRectZero;
		rect.origin.x = currentOriginX;
		rect.origin.y = currentOriginY;
		rect.size = image.size;
		if (maxHeightInLine < rect.size.height) {
			maxHeightInLine = rect.size.height;
		}
		
		//(does not feed line.)
		//NSLog(@"image size width=%f", image.size.width);
		currentOriginX += rect.size.width;
		currentOriginX += spacerX;
		
		// Add to subview.
		UIButton* button = [[UIButton alloc] init];
		[button setImage:image forState:UIControlStateNormal];
		button.frame = rect;
		button.tag = pageNum;
		[button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
		[scrollView addSubview:button];
		
		// Set contentSize to scrollView.
		scrollView.contentSize = CGSizeMake(currentOriginX, currentOriginY + maxHeightInLine);
	}
	
	
	//Check contentSize and frame.width.
	int frameWidth;
	Pdf2iPadViewController* vc = (Pdf2iPadViewController*)appDelegate.viewController;
	UIView* v = [vc view];

	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (interfaceOrientation == UIInterfaceOrientationPortrait
		||
		interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		frameWidth = v.frame.size.width;
	} else {
		frameWidth = v.frame.size.height;
	}
	
	if (scrollView.contentSize.width < frameWidth) {
		//NSLog(@"contentSize before fix=%@", NSStringFromCGSize(scrollView.contentSize));
		scrollView.contentSize = CGSizeMake(frameWidth, scrollView.contentSize.height);
		//NSLog(@"contentSize after  fix=%@", NSStringFromCGSize(scrollView.contentSize));
	}
	//NSLog(@"scrollView.contentSize=%@", NSStringFromCGSize(scrollView.contentSize));
}

-(void)buttonEvent:(UIButton*)button {
	//LOG_CURRENT_METHOD;
	//UIButton* button = (UIButton*)sender;
	NSUInteger pageNum = button.tag;
	//NSLog(@"touch thumbnail. page = %d", pageNum);
	
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate hideThumbnailScrollView];
	[appDelegate switchToPage:pageNum];
}


#pragma mark -
#pragma mark other methods.
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
    [super dealloc];
}


@end
