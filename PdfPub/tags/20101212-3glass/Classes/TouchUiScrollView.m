//
//  TouchUiScrollView.m
//  MagTest04
//
//  Created by okano on 10/09/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TouchUiScrollView.h"


@implementation TouchUiScrollView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"customTouchesBegan");
	[self.nextResponder touchesBegan:touches withEvent:event];
	//[[self nextResponder] touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"customTouchesEnded");
	[self.nextResponder touchesEnded:touches withEvent:event];
	//[[self nextResponder] touchesEnded:touches withEvent:event];
}


- (BOOL)touchesShouldBegin:(NSSet*)touches withEvent:(UIEvent*)event inContentView:(UIView*)view
{
	NSLog(@"touchesShouldBegin");
	
	[super touchesBegan:touches withEvent:event];
	CGPoint p = [[touches anyObject] locationInView:view];
	NSLog(@"x=%4.0f, y=%4.0f, scale=%4.3f, (%4.1f,%4.1f)", p.x, p.y, self.zoomScale, p.x / self.zoomScale, p.y / self.zoomScale);
	
	CGPoint scaledP;
	scaledP.x = p.x / self.zoomScale;
	scaledP.y = p.y / self.zoomScale;
	
	UITouch	*touch;
	NSEnumerator	*enumerator = [[event allTouches] objectEnumerator];
	while (touch = [enumerator nextObject]) {
		switch (touch.phase) {
			case UITouchPhaseBegan:
				startP = [touch locationInView:view];
				break;
			case UITouchPhaseEnded:
				endP = [touch locationInView:view];
				CGFloat dx = startP.x - endP.x;
				CGFloat dy = startP.y - endP.y;
				CGFloat distance = sqrt(dx*dx + dy*dy );
				if (distance <= 50.0f || (startP.x == 0 && startP.y == 0)) {
					PdfPubAppDelegate* appDelegate = (PdfPubAppDelegate*)[[UIApplication sharedApplication] delegate];
					PdfPubViewController* vc = appDelegate.viewController;
					[vc toggleNavigationBar];
				}
				break;
			case UITouchPhaseMoved:
				NSLog(@"UITouchPhaseMoved");
				break;
			case UITouchPhaseStationary:
				NSLog(@"UITouchPhaseStationary");
				break;
			case UITouchPhaseCancelled:
				NSLog(@"UITouchPhaseCancelled");
				break;
			default:
				break;
		}
	}
	
	/*
	PdfPubAppDelegate* appDelegate = (PdfPubAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSLog(@"current page =%d", appDelegate.currentPageNum);

	
	CGRect areaCoupon = CGRectMake(750, 1500, 700, 500);	//(x,y,w,h)
	CGRect areaMap = CGRectMake(30, 1700, 350, 300);	//(x,y,w,h)
	//CGRect areaChangeToMapView = CGRectMake(923, 0, 100, 50);
	NSLog(@"touches count = %d", [touches count]);
	if ([touches count] == 1) {
		if (appDelegate.currentPageNum >= 6) {
			//area1
			if (CGRectContainsPoint(areaCoupon, scaledP)) {
				//[self invertAreaRight];
				NSLog(@"areaCoupon");
				//[self showCouponView];
				//[self showEnqueteView];
				return NO;
			}

			//area2
			if (CGRectContainsPoint(areaMap, scaledP)) {
				//[self invertAreaRight];
				NSLog(@"areaMap");
				//[self showMapView];
				return NO;
			}
		}
	}
	*/
	
	return YES;
}


@end
