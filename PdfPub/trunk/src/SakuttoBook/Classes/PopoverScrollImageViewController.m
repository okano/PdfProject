    //
//  PopoverScrollImageViewController.m
//  SakuttoBook
//
//  Created by okano on 11/03/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PopoverScrollImageViewController.h"


@implementation PopoverScrollImageViewController


- (id)initWithImageFilename:(NSString*)filename frame:(CGRect)frame
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
		scrollView = [[UIScrollView alloc] initWithFrame:frame];
		[scrollView addSubview:imageView];
		scrollView.delegate = self;
		scrollView.contentSize = imageView.frame.size;
		scrollView.backgroundColor = [UIColor whiteColor];
		scrollView.backgroundColor = [[UIColor alloc] initWithRed:0.5f
															green:0.5f
															 blue:0.5f
															alpha:0.8f];
		
		//Set Zoom Scale.
		if (self.view.frame.size.width < image.size.width) {
			// image is larger than screen.
			scrollView.minimumZoomScale = self.view.frame.size.width / image.size.width * 0.75f;
			scrollView.maximumZoomScale = 1.0f;
		} else {
			// image is smaller than screen.
			scrollView.minimumZoomScale = 1.0f;
			scrollView.maximumZoomScale = self.view.frame.size.width / image.size.width;
		}
		
		//Set zoom.
		[scrollView zoomToRect:imageView.frame animated:YES];
		//NSLog(@"zoomScale=%f", scrollView.zoomScale);
		CGFloat scale = scrollView.zoomScale * 0.75f;
		scrollView.zoomScale =  scale;	//(to inner with 0.75)
		//NSLog(@"zoomScale=%f", scrollView.zoomScale);
		
		
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


@end
