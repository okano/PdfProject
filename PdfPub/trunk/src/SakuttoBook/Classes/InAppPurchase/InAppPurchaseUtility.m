//
//  InAppPurchaseUtility.m
//  SakuttoBook
//
//  Created by okano on 11/06/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InAppPurchaseUtility.h"

@implementation InAppPurchaseUtility

#pragma mark - initialize.
- (id)init
{
    self = [super init];
    if (self) {
		productIdList = [[NSMutableArray alloc] init];
		[self loadProductIdList];
    }
    return self;
}

#pragma mark - save/load with file.

- (void)loadProductIdList
{
	NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	id obj = [settings valueForKey:PRODUCT_ID_LIST_ARRAY];
	if (!obj) {		//no product id list exists.
		return;
	}
	if (![obj isKindOfClass:[NSArray class]]) {
		NSLog(@"illigal product id list infomation. class=%@", [obj class]);
		return;
	}
	
	if ([obj count] <= 0) {
		NSLog(@"no product Id found in standardUserDefaults.");
		/*
		UIAlertView *alert = [[[UIAlertView alloc]
							   initWithTitle:nil
							   message:@"no product id list founded."
							   delegate:nil
							   cancelButtonTitle:nil
							   otherButtonTitles:@"OK", nil]
							  autorelease];
		[alert show];
		*/
		return;		//do nothing if no data found.
	}
	
	[productIdList removeAllObjects];
	[productIdList addObjectsFromArray:obj];
	return;
}


- (void)saveProductIdList
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"all productIdList=%@", [productIdList description]);
	
	//Store bookmark infomation to UserDefault.
	NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
	[userDefault setObject:productIdList forKey:PRODUCT_ID_LIST_ARRAY];
	[userDefault synchronize];
}

- (void)refreshProductIdListFromNetwork
{
	NSString* urlStr = [self getProductIdListUrl];
	NSURL* url = [NSURL URLWithString:urlStr];
	NSError* error = nil;
	
	NSString* csvStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
	//NSString* csvStr = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
	if (csvStr == nil) {
		NSLog(@"no productIdList.csv file found.");
		NSLog(@"url=%@", url);
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil
														 message:@"no product id list found."
														delegate:nil
											   cancelButtonTitle:nil
											   otherButtonTitles:@"OK", nil]
							  autorelease];
		[alert show];
		return;		//do nothing if no data found.
	}
	//NSLog(@"csvStr=%@", csvStr);
	
	//Parse csv to Array.
	NSArray* tmpArray = [FileUtility parseDefineCsvFromString:csvStr];
	if ([tmpArray count] <= 0)
	{
		return;		//do nothing if no data found.
	}
	
	
	//Replace to new.
	[productIdList removeAllObjects];
	[productIdList addObjectsFromArray:tmpArray];
	
	//Store new list into UserDefault.
	[self saveProductIdList];
	
	LOG_CURRENT_METHOD;
	NSLog(@"tmpArray=%@", [tmpArray description]);
	NSLog(@"productIdList=%@", [productIdList description]);
}

- (void)loadProductIdListFromMainBundle	//for first launch.
{
	//load from mainBundle.
	NSError* error = nil;
	NSString* filename = [[NSBundle mainBundle]  pathForResource:PRODUCT_ID_LIST_FILENAME ofType:nil];
	NSString* csvStr = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:&error];
	
	//Parse csv to Array.
	NSArray* tmpArray = [FileUtility parseDefineCsvFromString:csvStr];
	if ([tmpArray count] <= 0)
	{
		return;		//do nothing if no data found.
	}
	
	
	//Replace to new.
	[productIdList removeAllObjects];
	[productIdList addObjectsFromArray:tmpArray];
	
	LOG_CURRENT_METHOD;
	NSLog(@"productIdList=%@", [productIdList description]);
}

- (NSString*)getProductIdListUrl
{
	NSString* urlBase = nil;
	NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	id obj;	//Get username.	
	obj = [settings valueForKey:URL_OPDS];
	if (!obj) {
		urlBase = [ConfigViewController getUrlBaseWithOpds];
		return [urlBase stringByAppendingPathComponent:PRODUCT_ID_LIST_FILENAME];
	}
	if (![obj isKindOfClass:[NSString class]]) {
		NSLog(@"illigal username infomation. class=%@", [obj class]);
		urlBase = [ConfigViewController getUrlBaseWithOpds];
		return [urlBase stringByAppendingPathComponent:PRODUCT_ID_LIST_FILENAME];
	}
	
	urlBase = [NSString stringWithString:obj];
	return [urlBase stringByAppendingPathComponent:PRODUCT_ID_LIST_FILENAME];
}



#pragma mark - Get id from file.
- (NSString*)getProductIdentifier:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	for (NSString* singleLine in productIdList) {
		NSArray* commaSeparated = [singleLine componentsSeparatedByString:@","];
		NSString* candidateCid = [commaSeparated objectAtIndex:0];
		NSString* candidatePid = [commaSeparated objectAtIndex:1];
		if ([candidateCid intValue] == cid) {
			return candidatePid;
		}
	}
	return @"";
}
- (ContentId)getContentIdentifier:(NSString *)pid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	for (NSString* singleLine in productIdList) {
		NSArray* commaSeparated = [singleLine componentsSeparatedByString:@","];
		NSString* candidateCid = [commaSeparated objectAtIndex:0];
		NSString* candidatePid = [commaSeparated objectAtIndex:1];
		if ([candidatePid compare:pid] == NSOrderedSame) {
			return (ContentId)([candidateCid intValue]);
		}
	}
	LOG_CURRENT_METHOD;
	NSLog(@"not found contentId with pid=%@", pid);
	return InvalidContentId;
}

- (NSArray*)getAllProductIdentifier
{
	return productIdList;
	/*
	//parse csv file.
	NSString* targetFilename = @"productIdList";
	return [FileUtility parseDefineCsv:targetFilename];
	*/
}


#pragma mark -
+ (NSString*)productIdWithFullQualifier:(NSString*)sinpleProductId
{
	NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	NSLog(@"original bundleIdentifier=%@", bundleIdentifier);
	if (10==0) { //Debug.
		bundleIdentifier = @"jp.kounago.PurchaseTest02";
	}
	
	NSString* fullProductId = [NSString stringWithFormat:@"%@.%@", bundleIdentifier, sinpleProductId];
	return fullProductId;
}
+ (NSString*)productIdWithoutFullQualifier:(NSString*)fullProductId
{
	 NSArray *tmpArray = [fullProductId componentsSeparatedByString:@"."];
	NSString* sinpleProductId = (NSString*)[tmpArray lastObject];
	return sinpleProductId;
}


#pragma mark - Judge free comtent.
//Check free contents for read without download.
- (BOOL)isFreeContent:(NSString*)productId
{
	for (NSString* singleLine in productIdList) {
		NSArray* commaSeparated = [singleLine componentsSeparatedByString:@","];
		NSString* candidateProductId = [commaSeparated objectAtIndex:1];
		if ([productId compare:candidateProductId] == NSOrderedSame) {
			if (1 <= [commaSeparated count] && PRODUCT_KIND_FREE == [[commaSeparated objectAtIndex:2] intValue]) {
				return TRUE;	//Free
			} else {
				return FALSE;	//Not Free
			}
			break;
		}
	}
	return FALSE;	//Not Free
}
- (BOOL)isFreeContentWithCid:(ContentId)cid{
	for (NSString* singleLine in productIdList) {
		NSArray* commaSeparated = [singleLine componentsSeparatedByString:@","];
		ContentId candidateContentId = [[commaSeparated objectAtIndex:0] intValue];
		if (candidateContentId == cid) {
			if (1 <= [commaSeparated count] && PRODUCT_KIND_FREE == [[commaSeparated objectAtIndex:2] intValue]) {
				return TRUE;	//Free
			} else {
				return FALSE;	//Not Free
			}
			break;
		}
	}
	return FALSE;	//Not Free
}


#pragma mark - Misc.
- (NSUInteger)count
{
	return [productIdList count];
}

- (NSString*)description
{
	return [productIdList description];
}

/*
- (NSString*)description
{
	int maxCount = [productIdList count];
	NSMutableString* resultStr = [[NSMutableString alloc] init];
	for (int i = 0; i < maxCount; i = i + 1) {
		[resultStr appendString:[self descriptionAtIndex:i]];
	}
	return resultStr;
}
*/

- (NSString*)descriptionAtIndex:(NSUInteger)index
{
	if ([productIdList count] <= index) {
		return @"";
	}
	
	NSDictionary* tmpDict = [productIdList objectAtIndex:index];
	//LOG_CURRENT_LINE;
	//NSLog(@"tmpDict=%@", [tmpDict description]);
	
	
	/*
	ContentId cid = [[tmpDict valueForKey:PURCHASE_CONTENT_ID] intValue];
	NSString* pid = [tmpDict valueForKey:PURCHASE_PRODUCT_ID];
	
	ContentListDS* tmpList = [[ContentListDS alloc] init];
	NSString* title = [tmpList titleByContentId:cid];
	
	//format date.
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd(E) HH:mm:ss"];
	NSString *purchaseDaytime = [formatter stringFromDate:[tmpDict valueForKey:PURCHASE_DAYTIME]];
	
	return [NSString stringWithFormat:@" %@%c w“ü“úŽž:%@%c (ContentId=%@ ProductId=%@)",
			title,
			0x0d,
			purchaseDaytime,
			0x0d,
			[NSString stringWithFormat:@"%d", cid],
			pid
			];
	*/
	
	return [tmpDict description];
}


@end
