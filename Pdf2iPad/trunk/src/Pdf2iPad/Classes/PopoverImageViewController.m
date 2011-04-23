//
//  PopoverImageViewController.m
//  Pdf2iPad
//
//  Created by okano on 11/02/07.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "PopoverImageViewController.h"

@implementation PopoverImageViewController
@synthesize scrollView;
@synthesize imageView;

#pragma mark -
- (void)setupWithImage:(UIImage*)image
{
	//NSLog(@"image.size=%@", NSStringFromCGSize(image.size));
	//NSLog(@"view.size=%@", NSStringFromCGSize(self.view.frame.size));
	
	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	
	//Generate UIScrollView with DeviceOrientation.
	CGRect frameForScrollView;
	if (interfaceOrientation == UIInterfaceOrientationPortrait
		||
		interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		frameForScrollView = self.view.frame;
	} else {
		frameForScrollView = CGRectMake(self.view.frame.origin.x,
										self.view.frame.origin.y,
										self.view.frame.size.height,	//change width, height.
										self.view.frame.size.width);
	}
	scrollView = [[UIScrollView alloc] initWithFrame:frameForScrollView];
	scrollView.delegate = self;
	scrollView.backgroundColor = [[UIColor alloc] initWithRed: 0.5f
														green: 0.5f
														 blue: 0.5f
														alpha: 0.8f];
	
	//Generate imageView with image, add to subview.
	imageView = [[UIImageView alloc] initWithImage:image];
	[scrollView addSubview:imageView];
	[self.view addSubview:scrollView];
	
	//Set zoomScale range.
	CGFloat screenWidth ;
	screenWidth = scrollView.frame.size.width;
	if (screenWidth <= image.size.width) {
		//screen < image.
		//fitWidth - original size.
		scrollView.minimumZoomScale = screenWidth / image.size.width;
		scrollView.maximumZoomScale = 1.0f;
		[scrollView setZoomScale:scrollView.minimumZoomScale];
	} else {
		//image < screen.
		//original size - fitWidth.
		scrollView.minimumZoomScale = 1.0f;
		scrollView.maximumZoomScale = screenWidth / image.size.width;
		[scrollView setZoomScale:scrollView.maximumZoomScale];
	}
	//NSLog(@"minimumZoomScale=%f, maximumZoomScale=%f", scrollView.minimumZoomScale, scrollView.maximumZoomScale);
	
	[scrollView setContentOffset:CGPointMake(0.0f, 0.0f)];
	[scrollView scrollsToTop];
	[scrollView flashScrollIndicators];
}


//locate imageView to center always.
//@see: http://stackoverflow.com/questions/1316451/center-content-of-uiscrollview-when-smaller
- (void)scrollViewDidZoom:(UIScrollView *)aScrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)? 
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)? 
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, 
                                   scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark -
#pragma mark handle rotate.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark UIScrollViewDelegate.
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)targetScrollView
{
	return [[targetScrollView subviews] objectAtIndex:0];
}

@end
