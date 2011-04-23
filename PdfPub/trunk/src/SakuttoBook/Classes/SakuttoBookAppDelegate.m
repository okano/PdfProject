//
//  SakuttoBookAppDelegate.m
//  SakuttoBook
//
//  Created by okano on 10/12/13.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "SakuttoBookAppDelegate.h"
#import "SakuttoBookViewController.h"

@implementation SakuttoBookAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize license;
@synthesize tocDefine;
@synthesize bookmarkDefine;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	license = [[License alloc] init];
	//Hides status bar.
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	
    // Add the view controller's view to the window and display.
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


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
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

/**
 * Functions in SakuttoBookViewController.
 */
#pragma mark -
#pragma mark Functions in SakuttoBookViewController.
- (NSString*)getThumbnailFilenameFull:(int)pageNum {
	return [viewController getThumbnailFilenameFull:pageNum];
}
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum {
	return [viewController getPdfPageImageWithPageNum:pageNum];
}
- (void)switchToPage:(int)newPageNum {
	[viewController switchToPage:newPageNum];
}
- (void)showMenuBar {
	[viewController showMenuBar];
}
- (void)hideMenuBar {
	[viewController hideMenuBar];
}
- (void)showTocView {
	[viewController showTocView];
}
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
- (void)showThumbnailView {
	[viewController showThumbnailView];
}
- (void)hideThumbnailView {
	[viewController hideThumbnailView];
}
- (bool)isShownThumbnailView {
	return viewController.isShownThumbnailView;
}
- (NSMutableArray*)getTocDefine {
	return tocDefine;
}
- (void)showWebView:(NSString*)urlString {
	[viewController showWebView:urlString];
}
- (void)showInfoView {
	[viewController showInfoView];
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
