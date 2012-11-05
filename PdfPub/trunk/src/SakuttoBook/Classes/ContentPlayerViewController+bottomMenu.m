//
//  ContentPlayerViewController+bottomMenu.m
//  SakuttoBook
//
//  Created by okano on 12/10/24.
//
//

#import "ContentPlayerViewController.h"

@implementation ContentPlayerViewController (bottomMenu)
- (void)showBottomMenu
{
	//LOG_CURRENT_METHOD;
	if ([self isContainSountAtIndex:currentPageNum] == YES)
	{
		[self.view bringSubviewToFront:bottomToolBar];
		[UIView beginAnimations:@"bottomMenuBarShow" context:nil];
		bottomToolBar.alpha = 1.0f;
		[UIView commitAnimations];
	}
}

- (void)hideBottomMenu
{
	//LOG_CURRENT_METHOD;
	[UIView beginAnimations:@"bottomMenuBarHide" context:nil];
	bottomToolBar.alpha = 0.0f;
	[UIView commitAnimations];
}

@end
