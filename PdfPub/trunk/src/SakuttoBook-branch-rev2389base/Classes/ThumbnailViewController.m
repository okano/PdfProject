    //
//  ThumbnailViewController.m
//  SakuttoBook
//
//  Created by okano on 10/12/25.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "ThumbnailViewController.h"


@implementation ThumbnailViewController
@synthesize toolBar;
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
	
	//Setup ToolBar.
	toolBar = [[UIToolbar alloc] init];
	toolBar.barStyle = UIBarStyleDefault;
	[toolBar sizeToFit];
	UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc]
									 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
									 target:self
									 action:@selector(closeThisView:)
									 ];
	[toolBar setItems:[NSArray arrayWithObjects:cancelButton, nil]];
	[self.view addSubview:toolBar];
	
	//Alocate ScrollView.
	scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
	scrollView.backgroundColor = [UIColor grayColor];
	CGRect rect = scrollView.frame;
	CGFloat statusBarHeight = 0.0f;	//20.0f;	//status bar is hidden.
	rect.origin.y += statusBarHeight;
	CGFloat toolBarHeight = 40.0f;
	rect.origin.y += toolBarHeight;
	rect.size.height -= toolBarHeight;
	scrollView.frame = rect;
	[self.view addSubview:scrollView];
}

#pragma mark -
- (IBAction)closeThisView:(id)sender
{
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	SakuttoBookViewController* vc = (SakuttoBookViewController*)appDelegate.viewController;
	[(SakuttoBookViewController*)vc hideThumbnailView];
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
	CGFloat spacerX = 4.0f, spacerY = 4.0f;
	
	currentOriginX += spacerX;
	currentOriginY += spacerY;
	
	
	
	//Setup with imageArray from tocDefine.
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	for (NSDictionary* tmpDict in appDelegate.tocDefine) {
		NSUInteger pageNum = [[tmpDict objectForKey:TOC_PAGE] intValue];
		NSString* filename = [tmpDict objectForKey:TOC_FILENAME];
		UIImage* image = nil;
		if (filename) {
			// Open image from mainBundle.
			image = [UIImage imageNamed:filename];
		} else {
			// Open image from thumbnail file.
			NSString* filenameFull = [appDelegate getThumbnailFilenameFull:pageNum];
			image = [UIImage imageWithContentsOfFile:filenameFull];
			if (! image) {
				//Generate thumbnail file from PDF.
				CGFloat newWidth = 100.0f;
				
				//Get original image.
				SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
				UIImage* tmpImage = [appDelegate getPdfPageImageWithPageNum:pageNum];
				if (tmpImage == nil) {
					NSLog(@"cannot generate thumbnail image. pageNum=%d", pageNum);
					continue;	//skip to next image.
				}
				
				//Calicurate new size.
				CGFloat scale = tmpImage.size.width / newWidth;
				CGSize newSize = CGSizeMake(tmpImage.size.width / scale,
											tmpImage.size.height / scale);
				//NSLog(@"newSize=%f,%f", newSize.width, newSize.height);
				
				
				UIImage* resizedImage;
				CGInterpolationQuality quality = kCGInterpolationLow;
				
				UIGraphicsBeginImageContext(newSize);
				CGContextRef context = UIGraphicsGetCurrentContext();
				CGContextSetInterpolationQuality(context, quality);
				[tmpImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
				resizedImage = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();
				
				//Save to file.
				NSData *data = UIImagePNGRepresentation(resizedImage);
				NSError* error = nil;
				[data writeToFile:filenameFull options:NSDataWritingAtomic error:&error];
				if (error) {
					NSLog(@"thumbnail file write error. path=%@", filenameFull);
					NSLog(@"error=%@, error code=%d", [error localizedDescription], [error code]);
					continue; //skip to next file.
				} else {
					//NSLog(@"wrote thumbnail file to %@", filenameFull);
				}
				
				//Re-open image with saved file.
				image = [UIImage imageWithContentsOfFile:filenameFull];
			}
		}
		if (! image) {
			LOG_CURRENT_METHOD;
			LOG_CURRENT_LINE;
			NSLog(@"file not found in mainBundle, filename=%@", filename);
			continue;	//skip to next object.
		}
		//NSLog(@"image size width=%f", image.size.width);

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
		
		// Check locate. feed line.
		if (maxWidth < currentOriginX + image.size.width) {
			//feed line.
			currentOriginX = 0.0f + spacerX;
			currentOriginY += maxHeightInLine;
			currentOriginY += spacerY;
			maxHeightInLine = image.size.height;
			
			rect.origin.x = currentOriginX;
			rect.origin.y = currentOriginY;
		}
		// Positioning to next position.
		currentOriginX += rect.size.width;
		currentOriginX += spacerX;
		//NSLog(@"pageNum=%d, rect for button=%@", pageNum, NSStringFromCGRect(rect));
		
		// Add to subview.
		UIButton* button = [[UIButton alloc] init];
		[button setImage:image forState:UIControlStateNormal];
		button.frame = rect;
		button.tag = pageNum;
		[button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
		[scrollView addSubview:button];
		
		// Set contentSize to scrollView.
		scrollView.contentSize = CGSizeMake(maxWidth, currentOriginY + maxHeightInLine);
	}
}

-(void)buttonEvent:(UIButton*)button {
	//LOG_CURRENT_METHOD;
	//UIButton* button = (UIButton*)sender;
	NSUInteger pageNum = button.tag;
	//NSLog(@"touch thumbnail. page = %d", pageNum);
	
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate hideThumbnailView];
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
