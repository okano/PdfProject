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
		[menuBottomViewController showStopSoundButton];
	} else {
		[menuBottomViewController hideStopSoundButton];
	}
		
	[self.view bringSubviewToFront:menuBottomViewController.view];
	[UIView beginAnimations:@"bottomMenuBarShow" context:nil];
	menuBottomViewController.view.alpha = 1.0f;
	[UIView commitAnimations];
}

- (void)hideBottomMenu
{
	//LOG_CURRENT_METHOD;
	[UIView beginAnimations:@"bottomMenuBarHide" context:nil];
	menuBottomViewController.view.alpha = 0.0f;
	[UIView commitAnimations];
}

@end
