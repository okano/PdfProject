//
//  Pdf2iPadAppDelegate.m
//  Pdf2iPad
//
//  Created by okano on 10/12/04.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "Pdf2iPadAppDelegate.h"
#import "Pdf2iPadViewController.h"
#import "InAppPurchaseDefine.h"

@implementation Pdf2iPadAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize tocDefine;
@synthesize bookmarkDefine;
//InAppPurchase
@synthesize paymentConductor;
@synthesize contentListDS;
@synthesize serverContentListDS;
@synthesize paymentHistoryDS;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    //Hides status bar.
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	
	//Setup Content List.
	contentListDS = [[ContentListDS alloc] init];
	//Setup Content List on Server.
	serverContentListDS = nil;
	
	//Copy PDF file in MainBundle resource to local file.
	if ([self isFirstLaunchUp] == YES) {
		[self copyPdfFromResourceToFile];
		[self copyOtherfileFromResourceToFile];
		[self setDefaultUsernameAndPassword];
	}
	
	//Setup for InAppPurchase.
	paymentConductor = [[PaymentConductor alloc] init];
	
	//Setup for InAppPurchase.
	paymentHistoryDS = [[PaymentHistoryDS alloc] init];
	[[SKPaymentQueue defaultQueue] addTransactionObserver:paymentConductor];
	paymentConductor.paymentHistoryDS = paymentHistoryDS;
	
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
- (BOOL)isFirstLaunchUp
{
	NSString* tmpDirectory = [ContentFileUtility getContentTmpDirectory];
	NSArray* fileList = [FileUtility fileList:tmpDirectory]; 
	//LOG_CURRENT_METHOD;
	//NSLog(@"path=%@, list=%@", tmpDirectory, [fileList description]);
	if ([fileList count] <= 0) {
		return YES;
	}
	return NO;
}
- (void)copyPdfFromResourceToFile
{
	LOG_CURRENT_METHOD;
	//Create directory.
	NSString* contentBodyDirectory = [ContentFileUtility getContentBodyDirectory];
	[FileUtility makeDir:contentBodyDirectory];
	
	//Copy each contents in Bundle Resource to local directory.
	int maxCount = [contentListDS count];
	for (int i = 0; i < maxCount; i = i + 1) {
		ContentId cid = [contentListDS contentIdAtIndex:i];
		NSString* resourceName = [FileUtility getPdfFilename:cid];
		/*
		NSString* newFilename = [NSString stringWithFormat:@"%d.%@", cid, @"pdf"];
		NSString* filenameFull = [[ContentFileUtility getContentBodyDirectory]
								  stringByAppendingPathComponent:newFilename];
		 */
		NSString* cidStr = [NSString stringWithFormat:@"%d", cid];
		NSString* filenameFull = [ContentFileUtility getContentBodyFilenamePdf:cidStr];
		//NSLog(@"resourceName=%@, filenameFull=%@", resourceName, filenameFull);
		
		//Make directory.
		[FileUtility makeDir:[ContentFileUtility getContentBodyPdfDirectoryWithContentId:cidStr]];
		
		//Copy.
		[FileUtility res2file:resourceName fileNameFull:filenameFull];
	}
}

- (void)copyOtherfileFromResourceToFile
{
	NSString* resourceName;
	NSString* toFilenameFull;
	NSString* toDir;
	NSArray* lines;
	
	/*
	 * Copy CSV files, other resource files.
	 */
	
	//Copy each contents in Bundle Resource to local directory.
	int maxCount = [contentListDS count];
	for (int i = 0; i < maxCount; i = i + 1) {
		ContentId cid = [contentListDS contentIdAtIndex:i];
		NSString* cidStr = [NSString stringWithFormat:@"%d", cid];
		
		/**
		 * Create directory.
		 */
		NSString* csvDirectory = [[ContentFileUtility getContentBodyDirectoryWithContentId:cidStr]
								  stringByAppendingPathComponent:@"csv"];
		[FileUtility makeDir:csvDirectory];
		
		/**
		 * Movie define.
		 */
		//Create Folder.
		toDir = [[ContentFileUtility getContentBodyDirectoryWithContentId:cidStr]
						   stringByAppendingPathComponent:@"movie"];
		[FileUtility makeDir:toDir];
		//Copy CSV file for movie define.
		resourceName = [[FileUtility getCsvFilenameInMainBundle:CSVFILE_MOVIE contentId:cid]
						stringByAppendingPathExtension:@"csv"];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_MOVIE contentId:cid];
		[FileUtility res2file:resourceName fileNameFull:toFilenameFull];
		//Copy movie file.
		lines = [FileUtility parseDefineCsv:CSVFILE_MOVIE contentId:cid];
		for (NSString* line in lines) {
			NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
			if ([tmpCsvArray count] < 6) {
				continue;	//skip error line.
			}
			NSString* tmpStr = [tmpCsvArray objectAtIndex:5];
			NSString* filename = [FileUtility cleanString:tmpStr];
			[FileUtility res2file:filename
					 fileNameFull:[toDir stringByAppendingPathComponent:filename]];
		}
		
		
		/**
		 * URL Link define.
		 */
		//Copy CSV file for URL Link define.
		resourceName = [[FileUtility getCsvFilenameInMainBundle:CSVFILE_URLLINK contentId:cid]
						stringByAppendingPathExtension:@"csv"];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_URLLINK contentId:cid];
		NSLog(@"resourceName=%@, toFilenameFull=%@", resourceName, toFilenameFull);
		[FileUtility res2file:resourceName fileNameFull:toFilenameFull];
		
		
		/**
		 * Sound define.
		 */
		//Copy CSV file.
		resourceName = [[FileUtility getCsvFilenameInMainBundle:CSVFILE_SOUND contentId:cid]
						stringByAppendingPathExtension:@"csv"];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_SOUND contentId:cid];
		NSLog(@"resourceName=%@, toFilenameFull=%@", resourceName, toFilenameFull);
		[FileUtility res2file:resourceName fileNameFull:toFilenameFull];
		
		//Create Folder.
		toDir = [[ContentFileUtility getContentBodyDirectoryWithContentId:cidStr]
				 stringByAppendingPathComponent:@"sound"];
		[FileUtility makeDir:toDir];
		//Copy movie file.
		lines = [FileUtility parseDefineCsv:CSVFILE_SOUND contentId:cid];
		for (NSString* line in lines) {
			NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
			if ([tmpCsvArray count] < 2) {
				continue;	//skip error line.
			}
			NSString* tmpStr = [tmpCsvArray objectAtIndex:1];
			NSString* filename = [FileUtility cleanString:tmpStr];
			[FileUtility res2file:filename
					 fileNameFull:[toDir stringByAppendingPathComponent:filename]];
		}
		
		
		/**
		 * PageJumpLink define.
		 */
		//Copy CSV file.
		resourceName = [[FileUtility getCsvFilenameInMainBundle:CSVFILE_PAGEJUMPLINK contentId:cid]
						stringByAppendingPathExtension:@"csv"];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_PAGEJUMPLINK contentId:cid];
		NSLog(@"resourceName=%@, toFilenameFull=%@", resourceName, toFilenameFull);
		[FileUtility res2file:resourceName fileNameFull:toFilenameFull];
		
		
		/**
		 * InPageScrollView define.
		 */
		//Copy CSV file.
		resourceName = [[FileUtility getCsvFilenameInMainBundle:CSVFILE_INPAGE_SCROLLVIEW contentId:cid]
						stringByAppendingPathExtension:@"csv"];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_INPAGE_SCROLLVIEW contentId:cid];
		NSLog(@"resourceName=%@, toFilenameFull=%@", resourceName, toFilenameFull);
		[FileUtility res2file:resourceName fileNameFull:toFilenameFull];

		//Create Folder.
		toDir = [[ContentFileUtility getContentBodyDirectoryWithContentId:cidStr]
				 stringByAppendingPathComponent:@"image"];
		[FileUtility makeDir:toDir];
		//Copy image file.
		lines = [FileUtility parseDefineCsv:CSVFILE_INPAGE_SCROLLVIEW contentId:cid];
		for (NSString* line in lines) {
			NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
			if ([tmpCsvArray count] < 6) {
				continue;	//skip error line.
			}
			NSString* tmpStr = [tmpCsvArray objectAtIndex:5];
			NSString* filename = [FileUtility cleanString:tmpStr];
			[FileUtility res2file:filename
					 fileNameFull:[toDir stringByAppendingPathComponent:filename]];
		}
		
		
		/**
		 * InPagePdf define.
		 */
		//Copy CSV file.
		resourceName = [[FileUtility getCsvFilenameInMainBundle:CSVFILE_INPAGE_PDF contentId:cid]
						stringByAppendingPathExtension:@"csv"];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_INPAGE_PDF contentId:cid];
		NSLog(@"resourceName=%@, toFilenameFull=%@", resourceName, toFilenameFull);
		[FileUtility res2file:resourceName fileNameFull:toFilenameFull];
		
		//Copy png file for inpage.
		lines = [FileUtility parseDefineCsv:CSVFILE_INPAGE_PDF contentId:cid];
		for (NSString* line in lines) {
			NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
			if ([tmpCsvArray count] < 6) {
				continue;	//skip error line.
			}
			NSString* tmpStr = [tmpCsvArray objectAtIndex:5];
			NSString* filename = [FileUtility cleanString:tmpStr];
			[FileUtility res2file:filename
					 fileNameFull:[toDir stringByAppendingPathComponent:filename]];
		}
		
		
		/**
		 * InPagePng define.
		 */
		//Copy CSV file.
		resourceName = [[FileUtility getCsvFilenameInMainBundle:CSVFILE_INPAGE_PNG contentId:cid]
						stringByAppendingPathExtension:@"csv"];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_INPAGE_PNG contentId:cid];
		NSLog(@"resourceName=%@, toFilenameFull=%@", resourceName, toFilenameFull);
		[FileUtility res2file:resourceName fileNameFull:toFilenameFull];
		
		//Copy png file for inpage.
		lines = [FileUtility parseDefineCsv:CSVFILE_INPAGE_PNG contentId:cid];
		for (NSString* line in lines) {
			NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
			if ([tmpCsvArray count] < 6) {
				continue;	//skip error line.
			}
			NSString* tmpStr = [tmpCsvArray objectAtIndex:5];
			NSString* filename = [FileUtility cleanString:tmpStr];
			[FileUtility res2file:filename
					 fileNameFull:[toDir stringByAppendingPathComponent:filename]];
		}
		
		
		/**
		 * PopoverImage define.
		 */
		//Copy CSV file.
		resourceName = [[FileUtility getCsvFilenameInMainBundle:CSVFILE_POPOVER_IMAGE contentId:cid]
						stringByAppendingPathExtension:@"csv"];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_POPOVER_IMAGE contentId:cid];
		NSLog(@"resourceName=%@, toFilenameFull=%@", resourceName, toFilenameFull);
		[FileUtility res2file:resourceName fileNameFull:toFilenameFull];
		
		//Copy png file for inpage.
		lines = [FileUtility parseDefineCsv:CSVFILE_POPOVER_IMAGE contentId:cid];
		for (NSString* line in lines) {
			NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
			if ([tmpCsvArray count] < 6) {
				continue;	//skip error line.
			}
			NSString* tmpStr = [tmpCsvArray objectAtIndex:5];
			NSString* filename = [FileUtility cleanString:tmpStr];
			[FileUtility res2file:filename
					 fileNameFull:[toDir stringByAppendingPathComponent:filename]];
		}
		
		/**
		 * TOC define.
		 */
		//Copy CSV file.
		resourceName = [[FileUtility getCsvFilenameInMainBundle:CSVFILE_TOC contentId:cid]
						stringByAppendingPathExtension:@"csv"];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_TOC contentId:cid];
		NSLog(@"resourceName=%@, toFilenameFull=%@", resourceName, toFilenameFull);
		[FileUtility res2file:resourceName fileNameFull:toFilenameFull];
		
		
		/**
		 * PDF define.(csv)
		 */
		//Copy CSV file.
		resourceName = [[FileUtility getCsvFilenameInMainBundle:CSVFILE_PDFDEFINE contentId:cid]
						stringByAppendingPathExtension:@"csv"];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_TOC contentId:cid];
		NSLog(@"resourceName=%@, toFilenameFull=%@", resourceName, toFilenameFull);
		[FileUtility res2file:resourceName fileNameFull:toFilenameFull];
	}
}

- (void)setDefaultUsernameAndPassword
{
	ConfigViewController* cfgvc = [[ConfigViewController alloc] initWithNibName:@"ConfigView" bundle:[NSBundle mainBundle]];
	[cfgvc saveUsernameAndPasswordToUserDefault:USERNAME_DEFAULT withPassword:PASSWORD_DEFAULT];
	[cfgvc release];
}


/*
#pragma mark - ContentId for download.
- (ContentId)nextContentId
{
    //load from UserDefault.
    NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	id obj = [settings valueForKey:LAST_CONTENT_ID];
	if (!obj) {		//not exists.
        NSLog(@"no contentId assigned. nextContentId=%d", [self nextContentId]);
		return (ContentId)FIRST_CONTENT_ID;
	}
	return [obj intValue];
}

- (void)stepupContentIdToUserDefault:(ContentId)lastAssignedContentId;
{
	//Step +1 last assigned ContentId to UserDefault.
	NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
	[userDefault setInteger:lastAssignedContentId+1 forKey:LAST_CONTENT_ID];
	[userDefault synchronize];
}
*/

#pragma mark -
- (void)switchToPage:(int)newPageNum {
	[viewController.contentPlayerViewController switchToPage:newPageNum];
}
#pragma mark -
#pragma mark Utility Method.
- (NSString*)getThumbnailFilenameFull:(int)pageNum {
	return [viewController.contentPlayerViewController getThumbnailFilenameFull:pageNum];
}
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum {
	return [viewController.contentPlayerViewController getPdfPageImageWithPageNum:pageNum];
}
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum WithContentId:(ContentId)cid {
	return [viewController.contentPlayerViewController getPdfPageImageWithPageNum:pageNum WithContentId:cid];
}
- (void)showMenuBar {
	[viewController.contentPlayerViewController showMenuBar];
}
- (void)hideMenuBar {
	[viewController.contentPlayerViewController hideMenuBar];
}
/*
- (void)showTocView {
	[viewController showTocView];
}
*/
- (void)hideTocView {
	[viewController.contentPlayerViewController hideTocView];
}
- (bool)isShownTocView {
	return viewController.contentPlayerViewController.isShownTocView;
}
- (void)setIsShownTocView:(bool)status {
	viewController.contentPlayerViewController.isShownTocView = status;
}
- (void)showBookmarkView {
	[viewController.contentPlayerViewController showBookmarkView];
}
- (void)hideBookmarkView {
	[viewController.contentPlayerViewController hideBookmarkView];
}
- (void)showBookmarkModifyView {
	[viewController.contentPlayerViewController showBookmarkModifyView];
}
- (void)addBookmarkWithCurrentPageWithName:(NSString*)bookmarkName {
	[viewController.contentPlayerViewController addBookmarkWithCurrentPageWithName:bookmarkName];
}
- (void)showThumbnailScrollView {
	[viewController.contentPlayerViewController showThumbnailScrollView];
}
- (void)hideThumbnailScrollView {
	[viewController.contentPlayerViewController hideThumbnailScrollView];
}
- (bool)iShownImageTocView {
	return viewController.contentPlayerViewController.isShownTocView;
}
- (NSMutableArray*)getTocDefine {
	return tocDefine;
}
- (void)showInfoView {
	[viewController.contentPlayerViewController showInfoView];
}
- (void)gotoTopPage {
	[viewController.contentPlayerViewController gotoTopPage];
}
- (void)gotoCoverPage {
	[viewController.contentPlayerViewController gotoCoverPage];
}
- (void)showHelpView {
	[viewController.contentPlayerViewController showHelpView];
}
- (void)enterMarkerMode {
	[viewController.contentPlayerViewController enterMarkerMode];
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


#pragma mark - InAppPurchase
@implementation Pdf2iPadAppDelegate (InAppPurchase)
#pragma mark -
- (void)showContentListView {
	[self.viewController showContentListView];
}
- (void)hideContentListView {
	[self.viewController hideContentListView];
}
- (void)showContentPlayerView:(ContentId)cid {
	[self.viewController showContentPlayerView:cid];
}
- (void)hideContentPlayerView {
	[self.viewController hideContentPlayerView];
}
- (void)showContentDetailView:(ContentId)cid {
	[self.viewController showContentDetailView:cid];
}
- (void)hideContentDetailView {
	[self.viewController hideContentDetailView];
}

@end

@implementation Pdf2iPadAppDelegate (ServerContent)
#pragma mark -
- (void)showServerContentListView{
	[self.viewController showServerContentListView];
}
- (void)hideServerContentListView{
	[self.viewController hideServerContentListView];
}
- (void)showServerContentDetailView:(NSString*)uuid{
	[self.viewController showServerContentDetailView:uuid];
}
- (void)hideServerContentDetailView{
	[self.viewController hideServerContentListView];
}
- (void)showDownloadView:(NSString*)productId{
	[self.viewController showDownloadView:productId];
}
@end
