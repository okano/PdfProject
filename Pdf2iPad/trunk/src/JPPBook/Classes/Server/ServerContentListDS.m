//
//  ServerContentListDS.m
//  JPPBook
//
//  Created by okano on 11/08/17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerContentListDS.h"


@implementation ServerContentListDS


#pragma mark - setup data.
- (void)setupData
{
	[self setupTestData];
}

#pragma mark - TestData.
- (void)setupTestData
{
	NSMutableDictionary* tmpDict;
	
	tmpDict = [[NSMutableDictionary alloc] init];
	[tmpDict setValue:[NSNumber numberWithInteger:1] forKey:CONTENT_CID];
	[tmpDict setValue:@"storeProductId-01" forKey:CONTENT_STORE_PRODUCT_ID];
	[tmpDict setValue:@"title1-server" forKey:CONTENT_TITLE];
	[tmpDict setValue:@"author1-server" forKey:CONTENT_AUTHOR];
	[tmpDict setValue:@"desc1-server" forKey:CONTENT_DESCRIPTION];
	[contentList addObject:tmpDict];
	
	tmpDict = [[NSMutableDictionary alloc] init];
	[tmpDict setValue:[NSNumber numberWithInteger:2] forKey:CONTENT_CID];
	[tmpDict setValue:@"storeProductId-02" forKey:CONTENT_STORE_PRODUCT_ID];
	[tmpDict setValue:@"title2-server" forKey:CONTENT_TITLE];
	[tmpDict setValue:@"author2-server" forKey:CONTENT_AUTHOR];
	[tmpDict setValue:@"desc2-server" forKey:CONTENT_DESCRIPTION];
	[contentList addObject:tmpDict];
	
	tmpDict = [[NSMutableDictionary alloc] init];
	[tmpDict setValue:[NSNumber numberWithInteger:3] forKey:CONTENT_CID];
	[tmpDict setValue:@"storeProductId-03" forKey:CONTENT_STORE_PRODUCT_ID];
	[tmpDict setValue:@"title3-server" forKey:CONTENT_TITLE];
	[tmpDict setValue:@"author3-server" forKey:CONTENT_AUTHOR];
	[tmpDict setValue:@"desc3-server" forKey:CONTENT_DESCRIPTION];
	[contentList addObject:tmpDict];
	
	tmpDict = [[NSMutableDictionary alloc] init];
	[tmpDict setValue:[NSNumber numberWithInteger:4] forKey:CONTENT_CID];
	[tmpDict setValue:@"storeProductId-04" forKey:CONTENT_STORE_PRODUCT_ID];
	[tmpDict setValue:@"title4-server" forKey:CONTENT_TITLE];
	[tmpDict setValue:@"author4-server" forKey:CONTENT_AUTHOR];
	[tmpDict setValue:@"desc4-server" forKey:CONTENT_DESCRIPTION];
	[contentList addObject:tmpDict];
	
	//[self loadContentList:10 delegate:nil];
	[self storeContentListToPlist:contentList];
}


#pragma mark - Load ContentList
//Set content list to var.
- (void)loadContentList:(NSUInteger)maxCount delegate:(id)delegate
{
	//Clear all.
	[contentList removeAllObjects];
	NSLog(@"contentList count=%d", [contentList count]);
	
	//Get from plist.
	[contentList addObjectsFromArray:[self loadContentListFromPlist]];
	if ([contentList count] <= 0) {
		//Get from Network.
		[contentList addObjectsFromArray:[self loadContentListFromNetwork]];
		if ([contentList count] <= 0) {
			//List cannot get.
			NSLog(@"content list cannot get from network");
			//Show alert.
			UIAlertView* errorAleart;
			errorAleart = [[UIAlertView alloc] initWithTitle:@"network error"
													 message:nil	//NSStringFromSelector(_cmd)
													delegate:self
										   cancelButtonTitle:nil
										   otherButtonTitles:@"OK", nil];
			[errorAleart show];
		} else {
			//Save it to plist.
			[self storeContentListToPlist:contentList];
		}
	}
	if (delegate != nil) {
		//[delegate refreshTableData];
	}
}
- (NSArray*)loadContentListFromPlist
{
	return nil;
}
- (void)getContentListFromFile
{
	// generate file name.
	NSString* pFile = [self getContentListFilename];
	
	// load from file via NSData
	NSData* pData = [NSData dataWithContentsOfFile:pFile];
	
	// de-serialize.
	id plist;
	NSString* error;
	plist = [NSPropertyListSerialization propertyListFromData:pData
											 mutabilityOption:NSPropertyListMutableContainersAndLeaves
													   format:NULL
											 errorDescription:&error];
	if (!plist) {
		if ([[NSFileManager defaultManager] fileExistsAtPath:pFile] == YES) {
			NSLog(@"load error:%@", error);
			NSLog(@"(but file is exist. filename=%@", pFile);
			[error release];
			return;
		} else {
			NSLog(@"file not found.");
			[error release];
		}
	} else {
		//NSLog(@"load success. file=%@", pFile);
	}
}


- (NSArray*)loadContentListFromNetwork
{
	NSString* pListUrl;
	pListUrl = [[[NSString stringWithString:URL_BASE_CONTENT]
				 stringByAppendingPathComponent:SUMMARY_DIR]
				stringByAppendingPathComponent:CONTENT_LIST_FAVORITE];
	pListUrl =  @"http://kounago.jp/test2/contentNewest.xml";
	
	
	//Load content List from Network.
	NSData* pData;
	NSError* err;
	pData = [NSData dataWithContentsOfURL:[NSURL URLWithString:pListUrl]
								  options:0
									error:&err];	//XML(on network) to NSData.
	if (!pData)
	{
		LOG_CURRENT_METHOD;
		LOG_CURRENT_LINE;
		NSLog(@"error=%@", [err localizedDescription]);
		NSLog(@"pListUrl=%@", pListUrl);
		NSAssert(YES, @"test1yes");
		//NSAssert(NO, @"test1no");
		
		UIAlertView* errorAleart;
		errorAleart = [[UIAlertView alloc] initWithTitle:@"network error"
												 message:nil	//NSStringFromSelector(_cmd)
												delegate:self
									   cancelButtonTitle:nil
									   otherButtonTitles:@"OK", nil];
		[errorAleart show];
		
		return FALSE;	
	}

	//Convert pData(NSData) to PropertyList.
	id pList;
	NSPropertyListFormat format;
	NSString* errStr;
	pList = [NSPropertyListSerialization propertyListFromData:pData
											 mutabilityOption:NSPropertyListImmutable
													   format:&format
											 errorDescription:&errStr];
	if (!pList)
	{
		LOG_CURRENT_METHOD;
		LOG_CURRENT_LINE;
		NSLog(@"error=%@", errStr);				
		UIAlertView* errorAleart;
		errorAleart = [[UIAlertView alloc] initWithTitle:@"serialize error"
												 message:errStr 
												delegate:self
									   cancelButtonTitle:nil
									   otherButtonTitles:@"OK", nil];
		[errorAleart show];
		return FALSE;
	} 
	
	//
	NSMutableDictionary* tmpDict;
	tmpDict = [NSMutableDictionary dictionaryWithDictionary:pList];
	NSLog(@"Dictionary from plist = ", [tmpDict description]);
	//
	NSDate* lastUpdate;
	lastUpdate = [tmpDict objectForKey:PFILE_LAST_UPDATE];
	
	//
	NSArray *anArray = [tmpDict objectForKey:PFILE_CONTENT_SUMMARY_ARRAY];
	NSLog(@"result array=%@", [anArray description]);
	NSLog(@"result count=%d", [anArray count]);
	
	/*
	//Convert
	NSEnumerator *enumerator = [anArray objectEnumerator];
	NSMutableArray* resultArray = [[NSMutableArray alloc] init];
	while ((NSDictionary* singleContent = [enumerator nextObject]))
	{
		NSString* title = [singleContent objectForKey:ITEM_TITLE];
		NSString* author = [singleContent objectForKey:ITEM_ARTIST];
		ContentId cid = [singleContent objectForKey:ITEM_CONTENT_ID];
		NSURL* url = [NSURL URLWithString:[singleContent objectForKey:ITEM_THUMBNAIL_URL]];
		
		NSMutableDictionary* tmpDict;
		[tmpDict setValue:title forKey:CONTENT_TITLE];
		[tmpDict setValue:author forKey:CONTENT_AUTHOR];
		
		[resultArray addObject:tmpDict];
	}
	 */

	
	return anArray;
}

- (void)storeContentListToPlist:(NSMutableArray*)pListArray
{
	NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
	
	//LastUpdate
	NSDate* lastUpdate;
	lastUpdate = [NSDate dateWithTimeIntervalSinceNow:0];
	[tmpDict setValue:lastUpdate forKey:PFILE_LAST_UPDATE];
	//ContentList
	[tmpDict setValue:pListArray forKey:PFILE_CONTENT_SUMMARY_ARRAY];
	NSLog(@"tmpDict=%@", [tmpDict description]);
	
	
	//Create directory if not exists.
	NSFileManager* fMgr = [NSFileManager defaultManager];
	BOOL isDir;
	NSError* err = nil;
	NSString* contentDetailDirectory = [self getContentListDirectoryname];
	if ( !([fMgr fileExistsAtPath:contentDetailDirectory isDirectory:&isDir] && isDir))
	{
		[fMgr createDirectoryAtPath:contentDetailDirectory withIntermediateDirectories:TRUE attributes:nil error:&err];
		if (err)
		{
			NSLog(@"content detail directory cannot create. path=%@", contentDetailDirectory);
			NSLog(@"err=%@", [err localizedDescription]);
			NSLog(@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
			return;
		}
	}
	
	
	//Save
	NSString* filename = [self getContentListFilename];
	[tmpDict writeToFile:filename atomically:YES];
}


#pragma mark -
- (NSString*)getContentListDirectoryname
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:SUMMARY_DIR];
	return documentsDirectory;
}

- (NSString*)getContentListFilename
{
	// generate file name.
	NSString* documentsDirectory = [self getContentListDirectoryname];
	NSString* fname=@"ContentList.plist";
	NSString* pFile = [documentsDirectory stringByAppendingPathComponent:fname];
	return pFile;
}


@end