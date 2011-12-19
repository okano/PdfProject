//
//  PopoverImageViewController.m
//  Pdf2iPad
//
//  Created by okano on 11/02/07.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "PopoverImageViewController.h"

@implementation PopoverImageViewController

#pragma mark -
#pragma mark handle rotate.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	//All orientation is OK.(default is only UIInterfaceOrientationPortrait)
    return YES;
}


/**
 *Open with contentBody directory.
 *other is based on SKBEngine.
 */
- (id)initWithImageFilename:(NSString*)filename frame:(CGRect)frame withContentIdStr:(NSString*)cidStr;
{
	[super init];
	
	/*
	NSString* path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
	if (!path) {
		NSLog(@"illigal filename. filename=%@, bundle_resourceURL=%@", filename, [[NSBundle mainBundle] resourceURL]);
		NSLog(@"f = %@ %@", [filename stringByDeletingPathExtension], [filename pathExtension]);
		return self;
	}
	*/
	
	NSString* path = [[ContentFileUtility getContentBodyImageDirectoryWithContentId:cidStr]
					  stringByAppendingPathComponent:filename];
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



@end
