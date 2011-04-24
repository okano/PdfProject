//
//  SKBEngine_PopoverScrollImageViewController.h
//  SKBEngine
//
//  Created by okano on 11/04/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SKBEngine_PopoverScrollImageViewController : UIViewController {
	//Save position, zoomScale for parent view.
	UIScrollView* parentScrollView;
	CGPoint parentOffset;
	CGFloat parentZoomScale;
}
- (void)setParentScrollView:(UIScrollView*)targetParentScrollView fromPosition:(CGPoint)pos fromZoomScale:(CGFloat)scale;
- (void)repositionParentScrollView;
//
@property (nonatomic, retain) UIScrollView* parentScrollView;

@end
