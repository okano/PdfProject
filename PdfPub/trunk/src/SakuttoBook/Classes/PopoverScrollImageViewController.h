//
//  PopoverScrollImageViewController.h
//  SakuttoBook
//
//  Created by okano on 11/03/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopoverScrollImageViewController : UIViewController <UIScrollViewDelegate> {
	UIScrollView* scrollView;
	UIImageView* imageView;
	
	//Save position, zoomScale for parent view.
	UIScrollView* parentScrollView;
	CGPoint parentOffset;
	CGFloat parentZoomScale;
}
//
@property (nonatomic, retain) UIScrollView* scrollView;
@property (nonatomic, retain) UIImageView* imageView;
@property (nonatomic, retain) UIScrollView* parentScrollView;
- (id)initWithImageFilename:(NSString*)filename frame:(CGRect)frame;
- (void)setParentScrollView:(UIScrollView*)targetParentScrollView fromPosition:(CGPoint)pos fromZoomScale:(CGFloat)scale;
- (void)repositionParentScrollView;
- (void)toggleZoom:(UITapGestureRecognizer*)gesture;

@end
