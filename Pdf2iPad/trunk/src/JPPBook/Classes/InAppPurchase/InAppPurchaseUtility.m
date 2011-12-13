//
//  InAppPurchaseUtility.m
//  SakuttoBook
//
//  Created by okano on 11/06/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InAppPurchaseUtility.h"


@implementation InAppPurchaseUtility
#pragma mark - Get id from file.
+ (NSString*)getProductIdentifier:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	NSArray* lines = [self getAllProductIdentifier];
	for (NSString* singleLine in lines) {
		NSArray* commaSeparated = [singleLine componentsSeparatedByString:@","];
		NSString* candidateCid = [commaSeparated objectAtIndex:0];
		NSString* candidatePid = [commaSeparated objectAtIndex:1];
		if ([candidateCid intValue] == cid) {
			return candidatePid;
		}
	}
	return @"";
}
+ (ContentId)getContentIdentifier:(NSString *)pid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	NSArray* lines = [self getAllProductIdentifier];
	for (NSString* singleLine in lines) {
		NSArray* commaSeparated = [singleLine componentsSeparatedByString:@","];
		NSString* candidateCid = [commaSeparated objectAtIndex:0];
		NSString* candidatePid = [commaSeparated objectAtIndex:1];
		if ([candidatePid compare:pid] == NSOrderedSame) {
			return (ContentId)([candidateCid intValue]);
		}
	}
	return InvalidContentId;
}

+ (NSArray*)getAllProductIdentifier
{
	//parse csv file.
	NSString* targetFilename = @"productIdList";
	return [FileUtility parseDefineCsv:targetFilename];
}


#pragma mark -
+ (NSString*)productIdWithFullQualifier:(NSString*)sinpleProductId
{
	NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	if (0==0) { //Debug.
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


#pragma mark -
//Check free contents for read without download.
+ (BOOL)isFreeContent:(NSString*)productId
{
	NSArray* lines = [self getAllProductIdentifier];
	for (NSString* singleLine in lines) {
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

#pragma mark -
+ (NSString*)getBookDefineFilename:(ContentId)cid
{
	return [NSString stringWithFormat:@"bookDefine_%d", cid];	//without ext ".csv".
}


@end
