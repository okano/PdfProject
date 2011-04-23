//
//  PopoverScrollImageViewController.h
//  SakuttoBook
//
//  Created by okano on 11/03/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"

@interface PopoverScrollImageViewController : UIViewController <UIScrollViewDelegate> {
	UIImageView* imageView;
	UIScrollView* scrollView;
	//Save position, zoomScale for parent view.
	UIScrollView* parentScrollView;
	CGPoint parentOffset;
	CGFloat parentZoomScale;
}
- (id)initWithImageFilename:(NSString*)filename;
- (void)setParentScrollView:(UIScrollView*)targetParentScrollView fromPosition:(CGPoint)pos fromZoomScale:(CGFloat)scale;
- (void)repositionParentScrollView;
- (void)toggleZoom:(UITapGestureRecognizer*)gesture;
//
@property (nonatomic, retain) UIScrollView* parentScrollView;

@end
