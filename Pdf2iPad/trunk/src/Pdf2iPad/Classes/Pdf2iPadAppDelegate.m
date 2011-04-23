//
//  Pdf2iPadAppDelegate.m
//  Pdf2iPad
//
//  Created by okano on 10/12/04.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "Pdf2iPadAppDelegate.h"
#import "Pdf2iPadViewController.h"

@implementation Pdf2iPadAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize tocDefine;
@synthesize bookmarkDefine;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch. 
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	
    [self.window addSubview:viewController.view];
    [self.window makeKeyAndVisible];

	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark -
- (void)switchToPage:(int)newPageNum {
	[viewController switchToPage:newPageNum];
}
#pragma mark -
#pragma mark Utility Method.
- (NSString*)getThumbnailFilenameFull:(int)pageNum {
	return [viewController getThumbnailFilenameFull:pageNum];
}
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum {
	return [viewController getPdfPageImageWithPageNum:pageNum];
}
- (void)showMenuBar {
	[viewController showMenuBar];
}
- (void)hideMenuBar {
	[viewController hideMenuBar];
}
/*
- (void)showTocView {
	[viewController showTocView];
}
*/
- (void)hideTocView {
	[viewController hideTocView];
}
- (bool)isShownTocView {
	return viewController.isShownTocView;
}
- (void)setIsShownTocView:(bool)status {
	viewController.isShownTocView = status;
}
- (void)showBookmarkView {
	[viewController showBookmarkView];
}
- (void)hideBookmarkView {
	[viewController hideBookmarkView];
}
- (void)showBookmarkModifyView {
	[viewController showBookmarkModifyView];
}
- (void)addBookmarkWithCurrentPageWithName:(NSString*)bookmarkName {
	[viewController addBookmarkWithCurrentPageWithName:bookmarkName];
}
- (void)showThumbnailScrollView {
	[viewController showThumbnailScrollView];
}
- (void)hideThumbnailScrollView {
	[viewController hideThumbnailScrollView];
}
- (bool)iShownImageTocView {
	return viewController.isShownTocView;
}
- (NSMutableArray*)getTocDefine {
	return tocDefine;
}
- (void)showInfoView {
	[viewController showInfoView];
}
- (void)gotoTopPage {
	[viewController gotoTopPage];
}
- (void)gotoCoverPage {
	[viewController gotoCoverPage];
}
- (void)showHelpView {
	[viewController showHelpView];
}
- (void)enterMarkerMode {
	[viewController enterMarkerMode];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
