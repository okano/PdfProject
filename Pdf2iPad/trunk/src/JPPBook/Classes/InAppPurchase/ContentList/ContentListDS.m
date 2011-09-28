//
//  ContentListDS.m
//  PurchaseTest04
//
//  Created by okano on 11/05/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContentListDS.h"


@implementation ContentListDS

@synthesize contentList;
- (id)init
{
	self = [super init];
	if (self) {
		contentList = [[NSMutableArray alloc] init];
		
		[self setupData];
		//[self setupTestData];
    }
    return self;
}

- (uint)count
{
	return [contentList count];
}

- (ContentId)contentIdAtIndex:(int)index
{
	if ([contentList count] < index || index < 0) {
		return 1;
	}
	NSDictionary* tmpDict;
	tmpDict = [contentList objectAtIndex:index];
	
	return [[tmpDict valueForKey:CONTENT_CID] intValue];
	//return @"testContentId";
}
- (ContentId)contentIdFromProductId:(NSString*)productId
{
	NSDictionary* tmpDict;
	for (tmpDict in contentList) {
		NSString* productIdCandidate = [tmpDict valueForKey:CONTENT_STORE_PRODUCT_ID];
		if ([productId compare:productIdCandidate] == FALSE) {
			return [[tmpDict valueForKey:CONTENT_CID] intValue];
		}
	}
	return InvalidContentId;
}
- (ContentId)contentIdFromUuid:(NSString*)uuid
{
	NSDictionary* tmpDict;
	for (tmpDict in contentList) {
		if ([[tmpDict valueForKey:CONTENT_UUID] compare:uuid options:NSCaseInsensitiveSearch] == NSOrderedSame) {
			return (ContentId)[[tmpDict valueForKey:CONTENT_CID] intValue];
		}
	}
	return InvalidContentId;
}

- (NSString*)productIdFromContentId:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	NSLog(@"cid=%d", cid);
	if (cid <= 0) {
		NSLog(@"ContentId is 1-start! (given %d)", cid);
		cid = 1;
	}
	
	//(when loading now, read csv file)
	if ([contentList count] < cid) {
		return [InAppPurchaseUtility getProductIdentifier:cid];
	}
	
	for (NSDictionary* tmpDict in contentList) {
		ContentId candidateCid = [[tmpDict valueForKey:CONTENT_CID] intValue];
		//NSLog(@"candidate cid=%d", candidateCid);
		if (candidateCid == cid) {
			//LOG_CURRENT_LINE;
			//NSLog(@"pid=%@", [tmpDict valueForKey:CONTENT_STORE_PRODUCT_ID]);
			if ([tmpDict valueForKey:CONTENT_STORE_PRODUCT_ID] != nil) {
				return [NSString stringWithString:[tmpDict valueForKey:CONTENT_STORE_PRODUCT_ID]];
			} else {
				NSLog(@"no product id. cid=%d", cid);
				return @"";
			}
		}
	}
	//LOG_CURRENT_LINE;
	return InvalidProductId;
}


- (NSString*)uuidAtIndex:(NSInteger)index
{
	if ([contentList count] < index || index < 0) {
		return @"";
	}
	NSDictionary* tmpDict;
	tmpDict = [contentList objectAtIndex:index];
	
	return [tmpDict valueForKey:CONTENT_UUID];
}
- (NSString*)uuidFromContentId:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	NSLog(@"cid=%d", cid);
	if (cid <= 0) {
		NSLog(@"ContentId is 1-start! (given %d)", cid);
		cid = 1;
	}
	
	//(when loading now, read csv file)
	if ([contentList count] < cid) {
		//return [InAppPurchaseUtility getProductIdentifier:cid];
		return @"";
	}
	
	for (NSDictionary* tmpDict in contentList) {
		ContentId candidateCid = [[tmpDict valueForKey:CONTENT_CID] intValue];
		//NSLog(@"candidate cid=%d", candidateCid);
		if (candidateCid == cid) {
			//LOG_CURRENT_LINE;
			//NSLog(@"pid=%@", [tmpDict valueForKey:CONTENT_STORE_PRODUCT_ID]);
			if ([tmpDict valueForKey:CONTENT_UUID] != nil) {
				return [NSString stringWithString:[tmpDict valueForKey:CONTENT_UUID]];
			} else {
				NSLog(@"no uuid. cid=%d", cid);
				return @"";
			}
		}
	}
	//LOG_CURRENT_LINE;
	return @"";
}

#pragma mark - setup data.
- (void)setupData
{
	
	//Load Metadata from plist
	int resultCount;
	resultCount = [self loadFromPlist];
	
	//Load Metadata from CSV. (when plist not found or First Launch.)
#if defined(IS_MULTI_CONTENTS) && IS_MULTI_CONTENTS != 0
	
	//Foreach contentId.
	int contentIdInt = 1;	//1-Start.
	while (0==0) {
		//Open define file.
		NSString* csvFilename = [InAppPurchaseUtility getBookDefineFilename:contentIdInt];
		if ( ! [[NSBundle mainBundle] pathForResource:csvFilename ofType:@"csv"] ) {
			break;
		}
		//NSLog(@"bookDefine csvFilename=%@", csvFilename);
		//NSLog(@"bookDefine csvFilePath=%@", csvFilePath);
		NSArray* lines = [FileUtility parseDefineCsv:csvFilename];
		if ([lines count] <= 0) {
			continue;	//skip to next file.
		}
		
		//set book infomation to inner var.
		NSMutableDictionary* tmpDict;
		tmpDict = [[NSMutableDictionary alloc] init];
		[tmpDict setValue:[NSNumber numberWithInteger:contentIdInt] forKey:CONTENT_CID];
		[tmpDict setValue:[InAppPurchaseUtility getProductIdentifier:contentIdInt] forKey:CONTENT_STORE_PRODUCT_ID];
		[tmpDict setValue:[lines objectAtIndex:0] forKey:CONTENT_TITLE];
		if (2 <= [lines count]) {
			[tmpDict setValue:[lines objectAtIndex:1] forKey:CONTENT_AUTHOR];
		}
		if (3 <= [lines count]) {
			//[tmpDict setValue:[lines objectAtIndex:2] forKey:CONTENT_COPYRIGHT];
		}
		if (4 <= [lines count]) {
			//[tmpDict setValue:[lines objectAtIndex:3] forKey:CONTENT_SUPPORT_HP];
		}
		if (5 <= [lines count]) {
			NSMutableString* tmpStr = [[NSMutableString alloc] init];
			for (int i = 4; i < [lines count]; i++) {
				[tmpStr appendString:[lines objectAtIndex:i]];
				[tmpStr appendString:@"\n"];
			}
			[tmpDict setValue:tmpStr forKey:CONTENT_DESCRIPTION];
		}
		[contentList addObject:tmpDict];
		
		contentIdInt++;
	}//end-while.
#else
	[self setupTestData];
#endif
	
	
	//Update nextContentId.
	ContentId nextContentIdOld = [self nextContentId];
	ContentId nextContentIdCurrent = resultCount;
	if (resultCount <= 0) {
		nextContentIdCurrent = contentIdInt;
	}
	if (nextContentIdOld < nextContentIdCurrent) {
		[self stepupContentIdToUserDefault:nextContentIdCurrent];
	}
	
}

//Init metadata with plist.
//return: count of metadata. or 0(init fail)
- (int)loadFromPlist
{
	// generate file name.
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	NSString* pFile = [documentsDirectory stringByAppendingPathComponent:METADATA_PLIST_FILENAME];
	
	
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
		return 0;
	}
	
	//Add to contentList array.
	int i;
	for (i=0; i<[plist count]; i++) {
		[contentList addObject:[plist objectAtIndex:i]];
	}
	
	return [contentList count];
}

#pragma mark - basic method.
- (NSString*)description
{
	return [contentList description];
}

//Save metadata to plist.
- (void)syncronize
{
	;
}



#pragma mark - metadata of single content.
- (NSMutableDictionary*)getMetadataByContentId:(ContentId)cid
{
	NSDictionary* tmpDict;
	for (tmpDict in contentList){
		if ([[tmpDict valueForKey:CONTENT_CID] intValue] == cid) {
			return [NSMutableDictionary dictionaryWithDictionary:tmpDict];
		}
	}
	return nil;
}
- (NSMutableDictionary*)getMetadataByUuid:(NSString*)uuid
{
	NSDictionary* tmpDict;
	for (tmpDict in contentList){
		if ([[tmpDict valueForKey:CONTENT_UUID] compare:uuid options:NSCaseInsensitiveSearch] == NSOrderedSame) {
			return [NSMutableDictionary dictionaryWithDictionary:tmpDict];
		}
	}
	return nil;
}
- (void)addMetadata:(NSDictionary*)metaDataDict
{
	[contentList addObject:metaDataDict];
}




#pragma mark - ContentId for download.
- (ContentId)nextContentId
{
    //load from UserDefault.
    NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	id obj = [settings valueForKey:LAST_CONTENT_ID];
	if (!obj) {		//not exists.
        NSLog(@"no contentId assigned.");
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


#pragma mark - (Getter) -
#pragma mark Title
- (NSString*)titleAtIndex:(NSInteger)index
{
	NSDictionary* tmpDict;
	tmpDict = [contentList objectAtIndex:index];
	
	return [tmpDict valueForKey:CONTENT_TITLE];
}
- (NSString*)titleByContentId:(ContentId)cid
{
	NSDictionary* tmpDict;
	for (tmpDict in contentList){
		if ([[tmpDict valueForKey:CONTENT_CID] intValue] == cid) {
			return [tmpDict valueForKey:CONTENT_TITLE];
		}
	}
	return @"";
}
- (NSString*)titleByUuid:(NSString*)uuid
{
	NSDictionary* tmpDict;
	for (tmpDict in contentList){
		if ([[tmpDict valueForKey:CONTENT_UUID] compare:uuid options:NSCaseInsensitiveSearch] == NSOrderedSame) {
			return [tmpDict valueForKey:CONTENT_TITLE];
		}
	}
	return @"";
}
#pragma mark Author
- (NSString*)authorAtIndex:(NSInteger)index
{
	NSDictionary* tmpDict;
	tmpDict = [contentList objectAtIndex:index];
	
	return [tmpDict valueForKey:CONTENT_AUTHOR];
}
- (NSString*)authorByContentId:(ContentId)cid
{
	NSDictionary* tmpDict;
	for (tmpDict in contentList){
		if ([[tmpDict valueForKey:CONTENT_CID] intValue] == cid) {
			return [tmpDict valueForKey:CONTENT_AUTHOR];
		}
	}
	return @"";
}
- (NSString*)authorByUuid:(NSString*)uuid
{
	NSDictionary* tmpDict;
	for (tmpDict in contentList){
		if ([[tmpDict valueForKey:CONTENT_UUID] compare:uuid options:NSCaseInsensitiveSearch] == NSOrderedSame) {
			return [tmpDict valueForKey:CONTENT_AUTHOR];
		}
	}
	return @"";
}

#pragma mark Thumbnail Image
- (UIImage*)contentIconAtIndex:(NSInteger)index
{
	return [self contentIconByContentId:(index + 1)];
	/*
	UIColor* color = [UIColor colorWithRed:0.125 * index
					  				 green:0.25  * index
									  blue:0.5   * index
									 alpha:1.0f];
    CGRect rect = CGRectMake(0.0f, 0.0f, 16.0f, 16.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	return image;
	*/
}
- (UIImage*)contentIconByContentId:(ContentId)cid
{
	NSString* filename = [NSString stringWithFormat:@"%@%d.%@",
						   CONTENT_ICONFILE_PREFIX,
						   cid,
						   CONTENT_ICONFILE_EXTENSION];
	//NSLog(@"filename=%@", filename);
	
	// Open image from mainBundle.
	UIImage* image = [UIImage imageNamed:filename];
	return image;
}
- (UIImage*)contentIconByUuid:(NSString*)uuid
{
	ContentId cid = (ContentId)[self contentIdFromUuid:uuid];
	NSString* filename = [NSString stringWithFormat:@"%@%d.%@",
						  CONTENT_ICONFILE_PREFIX,
						  cid,
						  CONTENT_ICONFILE_EXTENSION];
	//NSLog(@"filename=%@", filename);
	
	// Open image from mainBundle.
	UIImage* image = [UIImage imageNamed:filename];
	return image;
}
//- (NSURL*)contentIconUrlByUuid:(NSString*)uuid
//@see - (NSURL*)thumbnailUrlByUuid:(NSString*)uuid;

#pragma mark Description
- (NSString*)descriptionAtIndex:(NSInteger)index
{
	NSDictionary* tmpDict;
	tmpDict = [contentList objectAtIndex:index];
	
	return [tmpDict valueForKey:CONTENT_DESCRIPTION];
}
- (NSString*)descriptionByContentId:(ContentId)cid
{
	NSDictionary* tmpDict;
	for (tmpDict in contentList){
		if ([[tmpDict valueForKey:CONTENT_CID] intValue] == cid) {
			return [tmpDict valueForKey:CONTENT_DESCRIPTION];
		}
	}
	return @"";
}
- (NSString*)descriptionByUuid:(NSString*)uuid
{
	NSDictionary* tmpDict;
	for (tmpDict in contentList){
		if ([[tmpDict valueForKey:CONTENT_UUID] compare:uuid options:NSCaseInsensitiveSearch] == NSOrderedSame) {
			return [tmpDict valueForKey:CONTENT_DESCRIPTION];
		}
	}
	return @"";
}

#pragma mark Links.
- (NSURL*)acquisitionUrlAtIndex:(NSInteger)index
{
	NSDictionary* tmpDict;
	tmpDict = [contentList objectAtIndex:index];
	
	NSString* urlStr = [tmpDict valueForKey:CONTENT_ACQUISITION_LINK];
	return [NSURL URLWithString:urlStr];
}
- (NSURL*)acquisitionUrlByContentId:(ContentId)cid
{
	NSDictionary* tmpDict;
	for (tmpDict in contentList){
		if ([[tmpDict valueForKey:CONTENT_CID] intValue] == cid) {
			NSString* urlStr = [tmpDict valueForKey:CONTENT_ACQUISITION_LINK];
			return [NSURL URLWithString:urlStr];
		}
	}
	return nil;
}
- (NSURL*)acquisitionUrlByUuid:(NSString*)uuid
{
	NSDictionary* tmpDict;
	for (tmpDict in contentList){
		if ([[tmpDict valueForKey:CONTENT_UUID] compare:uuid options:NSCaseInsensitiveSearch] == NSOrderedSame) {
			NSString* urlStr = [tmpDict valueForKey:CONTENT_ACQUISITION_LINK];
			return [NSURL URLWithString:urlStr];
		}
	}
	return nil;
}

- (NSURL*)thumbnailUrlAtIndex:(NSInteger)index
{
	NSDictionary* tmpDict;
	tmpDict = [contentList objectAtIndex:index];
	
	NSString* urlStr = [tmpDict valueForKey:CONTENT_THUMBNAIL_LINK];
	return [NSURL URLWithString:urlStr];
}
- (NSURL*)thumbnailUrlByContentId:(ContentId)cid
{
	NSDictionary* tmpDict;
	for (tmpDict in contentList){
		if ([[tmpDict valueForKey:CONTENT_CID] intValue] == cid) {
			NSString* urlStr = [tmpDict valueForKey:CONTENT_THUMBNAIL_LINK];
			return [NSURL URLWithString:urlStr];
		}
	}
	return nil;
}
- (NSURL*)thumbnailUrlByUuid:(NSString*)uuid
{
	NSDictionary* tmpDict;
	for (tmpDict in contentList){
		if ([[tmpDict valueForKey:CONTENT_UUID] compare:uuid options:NSCaseInsensitiveSearch] == NSOrderedSame) {
			NSString* urlStr = [tmpDict valueForKey:CONTENT_THUMBNAIL_LINK];
			return [NSURL URLWithString:urlStr];
		}
	}
	return nil;
}

- (NSURL*)coverUrlAtIndex:(NSInteger)index
{
	NSDictionary* tmpDict;
	tmpDict = [contentList objectAtIndex:index];
	
	NSString* urlStr = [tmpDict valueForKey:CONTENT_COVER_LINK];
	return [NSURL URLWithString:urlStr];
}
- (NSURL*)coverUrlByContentId:(ContentId)cid
{
	NSDictionary* tmpDict;
	for (tmpDict in contentList){
		if ([[tmpDict valueForKey:CONTENT_CID] intValue] == cid) {
			NSString* urlStr = [tmpDict valueForKey:CONTENT_COVER_LINK];
			return [NSURL URLWithString:urlStr];
		}
	}
	return nil;
}
- (NSURL*)coverUrlByUuid:(NSString*)uuid
{
	NSDictionary* tmpDict;
	for (tmpDict in contentList){
		if ([[tmpDict valueForKey:CONTENT_UUID] compare:uuid options:NSCaseInsensitiveSearch] == NSOrderedSame) {
			NSString* urlStr = [tmpDict valueForKey:CONTENT_COVER_LINK];
			return [NSURL URLWithString:urlStr];
		}
	}
	return nil;
}

#pragma mark - TestData.
- (void)setupTestData
{
	NSMutableDictionary* tmpDict;
	
	tmpDict = [[NSMutableDictionary alloc] init];
	[tmpDict setValue:[NSNumber numberWithInteger:1] forKey:CONTENT_CID];
	[tmpDict setValue:@"storeProductId-01" forKey:CONTENT_STORE_PRODUCT_ID];
	[tmpDict setValue:@"title1" forKey:CONTENT_TITLE];
	[tmpDict setValue:@"author1" forKey:CONTENT_AUTHOR];
	[tmpDict setValue:@"desc1" forKey:CONTENT_DESCRIPTION];
	[contentList addObject:tmpDict];
	
	tmpDict = [[NSMutableDictionary alloc] init];
	[tmpDict setValue:[NSNumber numberWithInteger:2] forKey:CONTENT_CID];
	[tmpDict setValue:@"storeProductId-02" forKey:CONTENT_STORE_PRODUCT_ID];
	[tmpDict setValue:@"title2" forKey:CONTENT_TITLE];
	[tmpDict setValue:@"author2" forKey:CONTENT_AUTHOR];
	[tmpDict setValue:@"desc2" forKey:CONTENT_DESCRIPTION];
	[contentList addObject:tmpDict];
	
	tmpDict = [[NSMutableDictionary alloc] init];
	[tmpDict setValue:[NSNumber numberWithInteger:3] forKey:CONTENT_CID];
	[tmpDict setValue:@"storeProductId-03" forKey:CONTENT_STORE_PRODUCT_ID];
	[tmpDict setValue:@"title3" forKey:CONTENT_TITLE];
	[tmpDict setValue:@"author3" forKey:CONTENT_AUTHOR];
	[tmpDict setValue:@"desc3" forKey:CONTENT_DESCRIPTION];
	[contentList addObject:tmpDict];
	
	tmpDict = [[NSMutableDictionary alloc] init];
	[tmpDict setValue:[NSNumber numberWithInteger:4] forKey:CONTENT_CID];
	[tmpDict setValue:@"storeProductId-04" forKey:CONTENT_STORE_PRODUCT_ID];
	[tmpDict setValue:@"title4" forKey:CONTENT_TITLE];
	[tmpDict setValue:@"author4" forKey:CONTENT_AUTHOR];
	[tmpDict setValue:@"desc4" forKey:CONTENT_DESCRIPTION];
	[contentList addObject:tmpDict];
}
@end
