//
//  ServerContentListDS.m
//  JPPBook
//
//  Created by okano on 11/08/17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerContentListDS.h"


@implementation ServerContentListDS
@synthesize delegate;

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
	
	//[self storeContentListToPlist:contentList];
	
	//[self loadContentList:10 delegate:nil];
	/*
	NSString* urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE_OPDS, URL_SUFFIX_OPDS];
	NSURL *url = [NSURL URLWithString:urlStr];

	OpdsParser* parser = [[OpdsParser alloc] init];
	[parser getOpdsRoot:url];
	 */
}


#pragma mark - Load ContentList
//Set content list to var.
- (void)loadContentList:(NSUInteger)maxCount
{
	//Clear all.
	[contentList removeAllObjects];
	NSLog(@"contentList count=%d", [contentList count]);
	
	//Get from plist.
	[contentList addObjectsFromArray:[self loadContentListFromFile]];
	if ([contentList count] <= 0) {
		NSLog(@"not found contents from plist. load from network.");
		[self loadContentListFromNetworkByOpds];
		
		/*
		//Get from Network.
		[contentList addObjectsFromArray:[self loadContentListFromNetworkByOpds]];
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
		*/
	}
	if (delegate != nil) {
		[delegate reloadData];
	}
	NSLog(@"contentList count=%d", [contentList count]);
}

- (NSArray*)loadContentListFromFile
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
			return nil;
		} else {
			NSLog(@"file not found. file name=%@", pFile);
			[error release];
			return nil;
		}
	} else {
		NSLog(@"load success. file=%@", pFile);
		NSLog(@"class=%@", [plist class]);
	}
	
	return [self getContentListFromPlist:plist];
}


- (NSArray*)loadContentListFromNetwork
{
	NSString* pListUrl;
	pListUrl = [[[NSString stringWithString:URL_BASE_CONTENT]
				 stringByAppendingPathComponent:SUMMARY_DIR]
				stringByAppendingPathComponent:CONTENT_LIST_FAVORITE];
	pListUrl =  @"http://kounago.jp/test4/ContentList.plist";
	
	
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
	NSDate* lastUpdate = [self getLastupdateFromPlist:pList];
	NSLog(@"lastUpdate=%@", [lastUpdate description]);
	
	//
	NSArray* contentListTmp = [self getContentListFromPlist:pList];

	return contentListTmp;
}

- (void)loadContentListFromNetworkByOpds
{
	LOG_CURRENT_METHOD;
	
	OpdsParser* parser = [[OpdsParser alloc] init];
	parser.targetTableVC = self;
	
	NSString* urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE_OPDS, URL_SUFFIX_OPDS];
	NSURL* url = [[NSURL alloc] initWithString:urlStr];
	[parser getOpds:url];
}



#pragma mark - parse
- (NSDate*)getLastupdateFromPlist:(id)pList
{
	//
	NSMutableDictionary* tmpDict;
	tmpDict = [NSMutableDictionary dictionaryWithDictionary:pList];
	NSLog(@"Dictionary from plist = %@", [tmpDict description]);
	//
	NSDate* lastUpdate;
	lastUpdate = [tmpDict objectForKey:PFILE_LAST_UPDATE];
	return lastUpdate;
}

- (NSArray*)getContentListFromPlist:(id)pList
{
	//
	NSMutableDictionary* tmpDict;
	tmpDict = [NSMutableDictionary dictionaryWithDictionary:pList];
	NSLog(@"Dictionary from plist = %@", [tmpDict description]);
	//
	NSArray *anArray = [tmpDict objectForKey:PFILE_CONTENT_SUMMARY_ARRAY];
	NSLog(@"result count=%d, array=%@", [anArray count], [anArray description]);
	
	return anArray;
}


#pragma mark - store
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


#pragma mark - Utility for filename.
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