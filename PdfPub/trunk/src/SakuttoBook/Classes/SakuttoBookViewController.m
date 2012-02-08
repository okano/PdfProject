//
//  SakuttoBookViewController.m
//  SakuttoBook
//
//  Created by okano on 10/12/13.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "SakuttoBookViewController.h"

@implementation SakuttoBookViewController

@synthesize contentPlayerViewController;
@synthesize contentListVC;
@synthesize contentDetailVC;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		contentPlayerViewController = nil;
		
		
		[self showContentPlayerView];
    }
    return self;
}
*/

- (void)viewDidLoad
{
	//Initialize var.
	contentPlayerViewController = nil;
	
#if defined(IS_MULTI_CONTENTS) && IS_MULTI_CONTENTS != 0
	//Mulit Contents.
	[self showContentListView];
#else
	//Single Content.
	[self showContentPlayerView];
#endif
}



- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark - Handle Rotate.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
	//Rotate contentPlayer.
	if (contentPlayerViewController != nil) {
		if ([self isChangeOrientationKind:fromInterfaceOrientation newOrientation:self.interfaceOrientation] == YES) {
			//Rotate.
			ContentId currentContentId = contentPlayerViewController.currentContentId;
			[self hideContentPlayerView];
			[self showContentPlayerView:currentContentId];
			//Resize.
			CGRect newFrame;
			if (fromInterfaceOrientation == UIInterfaceOrientationPortrait
				||
				fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
				newFrame = CGRectMake(self.view.frame.origin.x, 
									  self.view.frame.origin.y, 
									  self.view.frame.size.height,
									  self.view.frame.size.width);
			} else {
				newFrame = CGRectMake(self.view.frame.origin.x, 
									  self.view.frame.origin.y, 
				self.view.frame.size.width,
				self.view.frame.size.height);
			}
			
			LOG_CURRENT_METHOD;
			NSLog(@"newFrame=%@", NSStringFromCGRect(newFrame));
			[contentPlayerViewController setupCurrentPageWithSize:newFrame];
			//
			if(0==1){
				LOG_CURRENT_METHOD;
				for (id v in self.view.superview.subviews) {
					NSLog(@"view class=%@", [v class]);
					if ([v isKindOfClass:[UIView class]] != TRUE) { continue; }
					UIView* vi = (UIView*)v;
					for (id v2 in vi.subviews) {
						NSLog(@"  subview class=%@", [v2 class]);
						if ([v2 isKindOfClass:[UIView class]] != TRUE) { continue; }
						UIView* vi2 = (UIView*)v2;
						for (id v3 in vi2.subviews) {
							NSLog(@"    subsubview class=%@", [v3 class]);
							if ([v3 isKindOfClass:[UIView class]] != TRUE) { continue; }
							UIView* vi3 = (UIView*)v3;
							for (id v4 in vi3.subviews) {
								NSLog(@"      subsubsubview class=%@", [v4 class]);
								if ([v4 isKindOfClass:[UIView class]] != TRUE) { continue; }
								UIView* vi4 = (UIView*)v4;
								for (id v5 in vi4.subviews) {
									NSLog(@"        subsubsubsubview class=%@", [v5 class]);
								}
							}
						}
					}
				}
			}
		}
	}
}

- (bool)isChangeOrientationKind:(UIInterfaceOrientation)oldOrientation newOrientation:(UIInterfaceOrientation)newOrientation {
	if (oldOrientation == UIDeviceOrientationUnknown) { return NO; }
	if (newOrientation == UIDeviceOrientationUnknown) { return NO; }
	
	if (oldOrientation == UIDeviceOrientationPortrait
		||
		oldOrientation == UIDeviceOrientationPortraitUpsideDown) {
		if (newOrientation == UIDeviceOrientationLandscapeLeft
			||
			newOrientation == UIDeviceOrientationLandscapeRight) {
			return YES;
		} else {
			return NO;
		}
	} else {
		if (newOrientation == UIDeviceOrientationPortrait
			||
			newOrientation == UIDeviceOrientationPortraitUpsideDown) {
			return YES;
		} else {
			return NO;
		}
	}
}

@end

#pragma mark - InAppPurchase
@implementation SakuttoBookViewController (InAppPurchase)
#pragma mark - show/hide view.
- (void)showContentListView
{
	if (contentListVC == nil) {
		contentListVC = [[ContentListViewController alloc] init];
	}
	[self.view addSubview:contentListVC.view];
	[contentListVC reloadData];
}
- (void)hideContentListView
{
	if (contentListVC != nil) {
		[contentListVC.view removeFromSuperview];
		[contentListVC release];
		contentListVC = nil;
	}
}
#pragma mark -
- (void)showContentPlayerView
{
	if (contentPlayerViewController == nil) {
		contentPlayerViewController = [[ContentPlayerViewController alloc] initWithNibName:@"ContentPlayerView" bundle:[NSBundle mainBundle]];
	}
	[self.view addSubview:contentPlayerViewController.view];
}

- (void)showContentPlayerView:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	if (contentPlayerViewController == nil) {
		contentPlayerViewController = [[ContentPlayerViewController alloc] initWithNibName:@"ContentPlayerView" bundle:[NSBundle mainBundle] contentId:cid];
	}
	[self.view addSubview:contentPlayerViewController.view];
}
- (void)hideContentPlayerView
{
	if (contentPlayerViewController != nil) {
		[contentPlayerViewController.view removeFromSuperview];
		[contentPlayerViewController release];
		contentPlayerViewController = nil;
	}
}
#pragma mark -
- (void)showContentDetailView:(ContentId)cid
{
	if (contentDetailVC == nil) {
		contentDetailVC = [[ContentDetailViewController alloc] initWithNibName:@"ContentDetailView" bundle:[NSBundle mainBundle]];
	}
	[self.view addSubview:contentDetailVC.view];
	[contentDetailVC setLabelsWithContentId:cid];
}
- (void)hideContentDetailView
{
	if (contentDetailVC != nil) {
		[contentDetailVC.view removeFromSuperview];
	}
}
@end
