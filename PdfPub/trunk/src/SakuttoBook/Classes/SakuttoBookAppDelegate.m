//
//  SakuttoBookAppDelegate.m
//  SakuttoBook
//
//  Created by okano on 10/12/13.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "SakuttoBookAppDelegate.h"
#import "SakuttoBookViewController.h"
#import "InAppPurchaseDefine.h"

@implementation SakuttoBookAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize license;
@synthesize tocDefine;
@synthesize bookmarkDefine;
//
@synthesize paymentConductor;
@synthesize contentListDS;
@synthesize serverContentListDS;
@synthesize paymentHistoryDS;
//@synthesize productIdList;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	
	//Clear all setting and content if change device on simulator.
	if ([self isChangeDeviceOnSimulator] == YES) {
		[self setLastLaunchedDeviceOnSimulator];
		[self alertWithDeviceChangedOnSimulator];
		[self deleteAllSettings];
	}
	
	license = [[License alloc] init];
	//Hides status bar.
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	
	//Setup Content List.
	contentListDS = [[ContentListDS alloc] init];
	
	//Setup Content List on Server.
	serverContentListDS = nil;
	
	//Setup productIdList.
	//productIdList = [ProductIdList alloc] init];
	//contentListDS.productIdListPointer = productIdList;
	
	//Put version hash in Git for debug.
	NSLog(@"version hash=%@", RELEASE_HASH);
	
	//Copy PDF file in MainBundle resource to local file.
	if ([self isFirstLaunchUp] == YES) {
		[self copyPdfFromResourceToFile];
		[self copyOtherfileFromResourceToFile];
		[self setDefaultUsernameAndPassword];
		[[ProductIdList sharedManager] loadProductIdListFromMainBundle];
		if ([[ProductIdList sharedManager] count] > 0) {
			[[ProductIdList sharedManager] saveProductIdList];
			//
			[contentListDS mergeProductIdIntoContentList];
		}
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
#pragma mark Setting at first launch.
- (BOOL)isFirstLaunchUp
{
	NSString* tmpDirectory = [ContentFileUtility getContentTmpDirectory];
	NSArray* fileList = [FileUtility fileList:tmpDirectory]; 
	//LOG_CURRENT_METHOD;
	//NSLog(@"tmp path=%@, fileList=%@", tmpDirectory, [fileList description]);
	
	if ([fileList count] <= 0) {
		//No file found in tmp directory.
		NSLog(@"this is first launchup.");
		return YES;
	}
	
	//Ignore stack-logs.* (debug file. ex:"stack-logs.5565.SakuttoBook.index","stack-logs.5565.SakuttoBook.tx2Lke.link")
	for (NSString* filename in fileList) {
		if ([filename hasPrefix:@"stack-logs"] == NO) {
			//Some file found. it will be page cache file, downloaded file, ...
			return NO;
		}
	}
	//only debug file ("stack-logs.*" file) found.
	NSLog(@"this is first launchup.");
	return YES;
}
- (void)copyPdfFromResourceToFile
{
	//LOG_CURRENT_METHOD;
	
	//Create directory.
	NSString* contentBodyDirectory = [ContentFileUtility getContentBodyDirectory];
	[FileUtility makeDir:contentBodyDirectory];
	
	//Copy each contents in Bundle Resource to local directory.
	int maxCount = [contentListDS count];
	for (int i = 0; i < maxCount; i = i + 1) {
		ContentId cid = [contentListDS contentIdAtIndex:i];
#if defined(IS_MULTI_CONTENTS) && IS_MULTI_CONTENTS != 0
		//Multi contents.
		NSString* resourceName = [FileUtility getPdfFilename:cid];
#else
		//Single content.
		NSString* resourceName = [FileUtility getPdfFilename];
#endif
		/*
		 NSString* newFilename = [NSString stringWithFormat:@"%d.%@", cid, @"pdf"];
		 NSString* filenameFull = [[ContentFileUtility getContentBodyDirectory]
		 stringByAppendingPathComponent:newFilename];
		 */
		NSString* cidStr = [NSString stringWithFormat:@"%d", cid];
		NSString* filenameFull = [ContentFileUtility getContentBodyFilenamePdf:cidStr];
		//NSLog(@"resourceName=%@, filenameFull=%@", resourceName, filenameFull);
		
		//Make directory.
		if ( [FileUtility makeDir:[ContentFileUtility getContentBodyPdfDirectoryWithContentId:cidStr]] == NO) {
			LOG_CURRENT_METHOD;
			NSLog(@"cannot make directory for PDF. cidStr=%@", cidStr);
		};
		
		//Copy.
		if ( [FileUtility res2file:resourceName fileNameFull:filenameFull] == NO) {
			LOG_CURRENT_METHOD;
			NSLog(@"cannot copy PDF file from mainBundle. cidStr=%@, from_resourceName=%@, copy_to_filenameFull=%@",
				  cidStr, resourceName, filenameFull);
		}
		
		//Set Ignore Backup.
		[FileUtility addSkipBackupAttributeToItemWithString:filenameFull];
	}
}

- (void)copyOtherfileFromResourceToFile
{
	NSString* resourceName;
	NSString* toFilenameFull;
	NSString* toDir;
	NSArray* lines;
	BOOL copyResult;
	
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
		resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_MOVIE contentId:cid withDeviceSuffix:YES];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_MOVIE contentId:cid withDeviceSuffix:YES];
		if ([FileUtility existsFile:[[NSBundle mainBundle] pathForResource:resourceName ofType:@""]] == NO) {
			resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_MOVIE contentId:cid withDeviceSuffix:NO];
			toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_MOVIE contentId:cid withDeviceSuffix:NO];
		}
		[FileUtility res2file:resourceName fileNameFull:toFilenameFull];
		//Set Ignore Backup.
		[FileUtility addSkipBackupAttributeToItemWithString:toFilenameFull];

		//Copy movie file.
		lines = [FileUtility parseDefineCsv:CSVFILE_MOVIE contentId:cid];
		for (NSString* line in lines) {
			NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
			if ([tmpCsvArray count] < 6) {
				continue;	//skip error line.
			}
			NSString* tmpStr = [tmpCsvArray objectAtIndex:5];
			NSString* filename = [FileUtility cleanString:tmpStr];
			NSString* filenameFull = [toDir stringByAppendingPathComponent:filename];
			[FileUtility res2file:filename
					 fileNameFull:filenameFull];
			//Set Ignore Backup.
			[FileUtility addSkipBackupAttributeToItemWithString:filenameFull];
			
		}
		
		
		/**
		 * Mail define.
		 */
		//Create Folder.
		toDir = [[ContentFileUtility getContentBodyDirectoryWithContentId:cidStr]
				 stringByAppendingPathComponent:@"mail"];
		[FileUtility makeDir:toDir];
		//Copy CSV file for mail define.
		resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_MAIL contentId:cid withDeviceSuffix:YES];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_MAIL contentId:cid withDeviceSuffix:YES];
		if ([FileUtility existsFile:[[NSBundle mainBundle] pathForResource:resourceName ofType:@""]] == NO) {
			resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_MAIL contentId:cid withDeviceSuffix:NO];
			toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_MAIL contentId:cid withDeviceSuffix:NO];
		}
		[FileUtility res2file:resourceName fileNameFull:toFilenameFull];
		//Set Ignore Backup.
		[FileUtility addSkipBackupAttributeToItemWithString:toFilenameFull];
		
		
		/**
		 * URL Link define.
		 */
		//Copy CSV file for URL Link define.
		resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_URLLINK contentId:cid withDeviceSuffix:YES];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_URLLINK contentId:cid withDeviceSuffix:YES];
		if ([FileUtility existsFile:[[NSBundle mainBundle] pathForResource:resourceName ofType:@""]] == NO) {
			resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_URLLINK contentId:cid withDeviceSuffix:NO];
			toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_URLLINK contentId:cid withDeviceSuffix:NO];
		}
		//NSLog(@"resourceName=%@, toFilenameFull=%@", resourceName, toFilenameFull);
		[FileUtility res2file:resourceName fileNameFull:toFilenameFull];
		//Set Ignore Backup.
		[FileUtility addSkipBackupAttributeToItemWithString:toFilenameFull];

		
		/**
		 * Sound define.
		 */
		//Copy CSV file.
		resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_SOUND contentId:cid withDeviceSuffix:YES];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_SOUND contentId:cid withDeviceSuffix:YES];
		if ([FileUtility existsFile:[[NSBundle mainBundle] pathForResource:resourceName ofType:@""]] == NO) {
			resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_SOUND contentId:cid withDeviceSuffix:NO];
			toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_SOUND contentId:cid withDeviceSuffix:NO];
		}
		//NSLog(@"resourceName=%@, toFilenameFull=%@", resourceName, toFilenameFull);
		[FileUtility res2file:resourceName fileNameFull:toFilenameFull];
		//Set Ignore Backup.
		[FileUtility addSkipBackupAttributeToItemWithString:toFilenameFull];

		//Create Folder.
		toDir = [[ContentFileUtility getContentBodyDirectoryWithContentId:cidStr]
				 stringByAppendingPathComponent:@"sound"];
		[FileUtility makeDir:toDir];
		//Set Ignore Backup.
		[FileUtility addSkipBackupAttributeToItemWithString:toDir];
		
		//Copy sound file.
		lines = [FileUtility parseDefineCsv:CSVFILE_SOUND contentId:cid];
		for (NSString* line in lines) {
			NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
			if ([tmpCsvArray count] < 2) {
				continue;	//skip error line.
			}
			NSString* tmpStr = [tmpCsvArray objectAtIndex:1];
			NSString* filename = [FileUtility cleanString:tmpStr];
			NSString* filenameFull = [toDir stringByAppendingPathComponent:filename];
			[FileUtility res2file:filename
					 fileNameFull:filenameFull];
			//Set Ignore Backup.
			[FileUtility addSkipBackupAttributeToItemWithString:filenameFull];
		}
		
		
		/**
		 * PageJumpLink define.
		 */
		//Copy CSV file.
		resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_PAGEJUMPLINK contentId:cid withDeviceSuffix:YES];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_PAGEJUMPLINK contentId:cid withDeviceSuffix:YES];
		if ([FileUtility existsFile:[[NSBundle mainBundle] pathForResource:resourceName ofType:@""]] == NO) {
			resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_PAGEJUMPLINK contentId:cid withDeviceSuffix:NO];
			toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_PAGEJUMPLINK contentId:cid withDeviceSuffix:NO];
		}
		//NSLog(@"resourceName=%@, toFilenameFull=%@", resourceName, toFilenameFull);
		[FileUtility res2file:resourceName fileNameFull:toFilenameFull];
		//Set Ignore Backup.
		[FileUtility addSkipBackupAttributeToItemWithString:toFilenameFull];

		
		/**
		 * InPageScrollView define.
		 */
		//Copy CSV file.
		resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_INPAGE_SCROLLVIEW contentId:cid withDeviceSuffix:YES];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_INPAGE_SCROLLVIEW contentId:cid withDeviceSuffix:YES];
		if ([FileUtility existsFile:[[NSBundle mainBundle] pathForResource:resourceName ofType:@""]] == NO) {
			resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_INPAGE_SCROLLVIEW contentId:cid withDeviceSuffix:NO];
			toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_INPAGE_SCROLLVIEW contentId:cid withDeviceSuffix:NO];
		}
		//NSLog(@"resourceName=%@, toFilenameFull=%@", resourceName, toFilenameFull);
		[FileUtility res2file:resourceName fileNameFull:toFilenameFull];
		//Set Ignore Backup.
		[FileUtility addSkipBackupAttributeToItemWithString:toFilenameFull];
		
		//Create Folder.
		toDir = [[ContentFileUtility getContentBodyDirectoryWithContentId:cidStr]
				 stringByAppendingPathComponent:@"image"];
		[FileUtility makeDir:toDir];
		//Set Ignore Backup.
		[FileUtility addSkipBackupAttributeToItemWithString:toDir];
		//Copy image file.
		lines = [FileUtility parseDefineCsv:CSVFILE_INPAGE_SCROLLVIEW contentId:cid];
		for (NSString* line in lines) {
			NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
			if ([tmpCsvArray count] < 6) {
				continue;	//skip error line.
			}
			for (int i = 5; i < [tmpCsvArray count]; i = i + 1) {
				NSString* tmpStr = [tmpCsvArray objectAtIndex:i];
				NSString* filename = [FileUtility cleanString:tmpStr];
				NSString* filenameFull = [toDir stringByAppendingPathComponent:filename];
				[FileUtility res2file:filename
						 fileNameFull:filenameFull];
				//Set Ignore Backup.
				[FileUtility addSkipBackupAttributeToItemWithString:filenameFull];
			}
		}
		
		
		/**
		 * InPagePdf define.
		 */
		//Copy CSV file.
		resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_INPAGE_PDF contentId:cid withDeviceSuffix:YES];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_INPAGE_PDF contentId:cid withDeviceSuffix:YES];
		if ([FileUtility existsFile:[[NSBundle mainBundle] pathForResource:resourceName ofType:@""]] == NO) {
			resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_INPAGE_PDF contentId:cid withDeviceSuffix:NO];
			toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_INPAGE_PDF contentId:cid withDeviceSuffix:NO];
		}
		//NSLog(@"resourceName=%@, toFilenameFull=%@", resourceName, toFilenameFull);
		[FileUtility res2file:resourceName fileNameFull:toFilenameFull];
		//Set Ignore Backup.
		[FileUtility addSkipBackupAttributeToItemWithString:toFilenameFull];
		
		//Copy png file for inpage.
		lines = [FileUtility parseDefineCsv:CSVFILE_INPAGE_PDF contentId:cid];
		for (NSString* line in lines) {
			NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
			if ([tmpCsvArray count] < 6) {
				continue;	//skip error line.
			}
			NSString* tmpStr = [tmpCsvArray objectAtIndex:5];
			NSString* filename = [FileUtility cleanString:tmpStr];
			NSString* filenameFull = [toDir stringByAppendingPathComponent:filename];
			[FileUtility res2file:filename
					 fileNameFull:toDir];
			//Set Ignore Backup.
			[FileUtility addSkipBackupAttributeToItemWithString:filenameFull];
		}
		
		
		/**
		 * InPagePng define.
		 */
		//Copy CSV file.
		resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_INPAGE_PNG contentId:cid withDeviceSuffix:YES];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_INPAGE_PNG contentId:cid withDeviceSuffix:YES];
		if ([FileUtility existsFile:[[NSBundle mainBundle] pathForResource:resourceName ofType:@""]] == NO) {
			resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_INPAGE_PNG contentId:cid withDeviceSuffix:NO];
			toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_INPAGE_PNG contentId:cid withDeviceSuffix:NO];
		}
		//NSLog(@"resourceName=%@, toFilenameFull=%@", resourceName, toFilenameFull);
		[FileUtility res2file:resourceName fileNameFull:toFilenameFull];
		//Set Ignore Backup.
		[FileUtility addSkipBackupAttributeToItemWithString:toFilenameFull];
		
		//Copy png file for inpage.
		lines = [FileUtility parseDefineCsv:CSVFILE_INPAGE_PNG contentId:cid];
		for (NSString* line in lines) {
			NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
			if ([tmpCsvArray count] < 6) {
				continue;	//skip error line.
			}
			NSString* tmpStr = [tmpCsvArray objectAtIndex:5];
			NSString* filename = [FileUtility cleanString:tmpStr];
			NSString* filenameFull = [toDir stringByAppendingPathComponent:filename];
			[FileUtility res2file:filename
					 fileNameFull:filenameFull];
			//Set Ignore Backup.
			[FileUtility addSkipBackupAttributeToItemWithString:filenameFull];
		}
		
		
		/**
		 * PopoverImage define.
		 */
		//Copy CSV file.
		resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_POPOVER_IMAGE contentId:cid withDeviceSuffix:YES];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_POPOVER_IMAGE contentId:cid withDeviceSuffix:YES];
		if ([FileUtility existsFile:[[NSBundle mainBundle] pathForResource:resourceName ofType:@""]] == NO) {
			resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_POPOVER_IMAGE contentId:cid withDeviceSuffix:NO];
			toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_POPOVER_IMAGE contentId:cid withDeviceSuffix:NO];
		}
		//NSLog(@"resourceName=%@, toFilenameFull=%@", resourceName, toFilenameFull);
		[FileUtility res2file:resourceName fileNameFull:toFilenameFull];
		//Set Ignore Backup.
		[FileUtility addSkipBackupAttributeToItemWithString:toFilenameFull];
		
		//Copy png file for inpage.
		lines = [FileUtility parseDefineCsv:CSVFILE_POPOVER_IMAGE contentId:cid];
		for (NSString* line in lines) {
			NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
			if ([tmpCsvArray count] < 6) {
				continue;	//skip error line.
			}
			NSString* tmpStr = [tmpCsvArray objectAtIndex:5];
			NSString* filename = [FileUtility cleanString:tmpStr];
			NSString* filenameFull = [toDir stringByAppendingPathComponent:filename];
			[FileUtility res2file:filename
					 fileNameFull:filenameFull];
			//Set Ignore Backup.
			[FileUtility addSkipBackupAttributeToItemWithString:filenameFull];
		}
		
		/**
		 * TOC define.
		 */
		//Copy CSV file.
		resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_TOC contentId:cid withDeviceSuffix:YES];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_TOC contentId:cid withDeviceSuffix:YES];
		if ([FileUtility existsFile:[[NSBundle mainBundle] pathForResource:resourceName ofType:@""]] == NO) {
			resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_TOC contentId:cid withDeviceSuffix:NO];
			toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_TOC contentId:cid withDeviceSuffix:NO];
		}
		//NSLog(@"resourceName=%@, toFilenameFull=%@", resourceName, toFilenameFull);
		copyResult = [FileUtility res2file:resourceName fileNameFull:toFilenameFull];
		if (copyResult != YES) {
			NSLog(@"cannot copy TOC define csv file. cid=%d", cid);
		}
		//Set Ignore Backup.
		[FileUtility addSkipBackupAttributeToItemWithString:toFilenameFull];
		
		
		/**
		 * PDF define.(csv)
		 */
		//Copy CSV file.
		resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_PDFDEFINE contentId:cid withDeviceSuffix:YES];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_PDFDEFINE contentId:cid withDeviceSuffix:YES];
		if ([FileUtility existsFile:[[NSBundle mainBundle] pathForResource:resourceName ofType:@""]] == NO) {
			resourceName = [FileUtility getCsvFilenameInMainBundle:CSVFILE_PDFDEFINE contentId:cid withDeviceSuffix:NO];
			toFilenameFull = [FileUtility getCsvFilenameInFolder:CSVFILE_PDFDEFINE contentId:cid withDeviceSuffix:NO];
		}
		//NSLog(@"resourceName=%@, toFilenameFull=%@", resourceName, toFilenameFull);
		copyResult = [FileUtility res2file:resourceName fileNameFull:toFilenameFull];
		if (copyResult != YES) {
			NSLog(@"cannot copy PDF define csv file. cid=%d", cid);
		}
		//Set Ignore Backup.
		[FileUtility addSkipBackupAttributeToItemWithString:toFilenameFull];
	}
}

- (void)setDefaultUsernameAndPassword
{
	ConfigViewController* cfgvc = [[ConfigViewController alloc] initWithNibName:@"ConfigView" bundle:[NSBundle mainBundle]];
	[cfgvc saveUsernameAndPasswordToUserDefault:USERNAME_DEFAULT withPassword:PASSWORD_DEFAULT];
	[cfgvc release];
}

#pragma mark -
#pragma mark Handle device change on simulator. (reset all setting for DEBUG.)
- (BOOL)isChangeDeviceOnSimulator
{
#if ! TARGET_IPHONE_SIMULATOR
	return NO;
#endif
	
	NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	id obj = [settings valueForKey:LAST_LAUNCHED_DEVICE_ON_SIMULATOR];
	if (!obj) {		//no exists.
		[self setLastLaunchedDeviceOnSimulator];
		return NO;
	}
	if (![obj isKindOfClass:[NSNumber class]]) {
		NSLog(@"illigal device infomation on simulator. class=%@", [obj class]);
		return NO;
	}
	
	int currentDeviceKind;
	currentDeviceKind = UI_USER_INTERFACE_IDIOM();	// sdk upper 3.2
	
	if (currentDeviceKind == [obj intValue]) {
		return NO;
	} else {
		return YES;
	}
}
- (void)setLastLaunchedDeviceOnSimulator
{
#if ! TARGET_IPHONE_SIMULATOR
	return;
#endif
	
	//Get current device kind.
	int currentDeviceKind;
	currentDeviceKind = UI_USER_INTERFACE_IDIOM();	// sdk upper 3.2
	
	//Set to UserDefault.
	[[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)currentDeviceKind
											   forKey:LAST_LAUNCHED_DEVICE_ON_SIMULATOR];
	[[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)alertWithDeviceChangedOnSimulator;
{
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"DEBUG"
													 message:@"シミュレータ上で機種が変更されました。全ての設定をリセットしました。"
													delegate:nil
										   cancelButtonTitle:nil
										   otherButtonTitles:@"OK",nil]
						  autorelease];
	[alert show];
}
- (void)deleteAllSettings
{
	//Reset UserDefault.
	NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
	[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];	
	
	
	
	//Remove/re-Create folder for tmp.
	NSString* contentTmpDir = [ContentFileUtility getContentTmpDirectory];
	[FileUtility removeFile:contentTmpDir];
	[FileUtility makeDir:contentTmpDir];
	
	//Remove/re-Create folder for content detail.
	NSString* contentDetailDir = [ContentFileUtility getContentDetailDirectory];
	[FileUtility removeFile:contentDetailDir];
	[FileUtility makeDir:contentDetailDir];
	//Set Ignore Backup.
	[FileUtility addSkipBackupAttributeToItemWithString:contentDetailDir];
	
	/*
	NSArray* fileList = [FileUtility fileList:contentDetailDir];
	for (NSString* filename in fileList) {
		[FileUtility removeFile:filename];
	}
	*/
	
	/*
	//Remove folder for contentBody.
	NSString* contentBodyDirectory = [ContentFileUtility getContentBodyDirectory];
	[FileUtility removeFile:contentBodyDirectory];
	 
	//Remove folder for contentCoverCache.
	NSString* contentCoverCacheDirectory = [ContentFileUtility getCoverIconDirectory];
	[FileUtility removeFile:contentCoverCacheDirectory];
	
	//Remove folder for download.
	NSString* contentDownloadDirectory = [ContentFileUtility getContentDownloadDirectory];
	[FileUtility removeFile:contentDownloadDirectory];
	*/
}


#pragma mark -
#pragma mark Functions in SakuttoBookViewController.
- (NSString*)getPageSmallFilenameFull:(int)pageNum {
	return [viewController.contentPlayerViewController getPageSmallFilenameFull:pageNum];
}
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum {
	return [viewController.contentPlayerViewController getPdfPageImageWithPageNum:pageNum];
}
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum WithContentId:(ContentId)cid {
	return [viewController.contentPlayerViewController getPdfPageImageWithPageNum:pageNum WithContentId:cid];
}
- (void)switchToPage:(int)newPageNum {
	[viewController.contentPlayerViewController switchToPage:newPageNum];
}
- (void)showMenuBar {
	[viewController.contentPlayerViewController showMenuBar];
}
- (void)hideMenuBar {
	[viewController.contentPlayerViewController hideMenuBar];
}
- (void)showTocView {
	[viewController.contentPlayerViewController showTocView];
}
- (void)hideTocView {
	[viewController.contentPlayerViewController hideTocView];
}
- (bool)isShownTocView {
	return viewController.contentPlayerViewController.isShownTocView;
}
- (void)setIsShownTocView:(bool)status {
	viewController.contentPlayerViewController.isShownTocView = status;
}
- (void)saveBookmark {
	[viewController.contentPlayerViewController saveBookmark];
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
- (void)showPageSmallView {
	[viewController.contentPlayerViewController showPageSmallView];
}
- (void)hidePageSmallView {
	[viewController.contentPlayerViewController hidePageSmallView];
}
- (bool)isShownPageSmallView {
	return viewController.contentPlayerViewController.isShownPageSmallView;
}
- (NSMutableArray*)getTocDefine {
	return tocDefine;
}
- (void)showWebView:(NSString*)urlString {
	[viewController.contentPlayerViewController showWebView:urlString];
}
- (void)showInfoView {
	[viewController.contentPlayerViewController showInfoView];
}
- (void)enterMarkerMode {
	[viewController.contentPlayerViewController enterMarkerMode];
}
#pragma mark -
- (ContentId)getCurrentContentIdInContentPlayer
{
	return viewController.contentPlayerViewController.currentContentId;
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
@implementation SakuttoBookAppDelegate (InAppPurchase)
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


#pragma mark - ServerContent
@implementation SakuttoBookAppDelegate (ServerContent)
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
