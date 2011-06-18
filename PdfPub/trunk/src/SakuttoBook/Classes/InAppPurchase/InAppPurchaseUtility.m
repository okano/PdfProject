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
	if (cid <= [lines count]) {
		//return [lines objectAtIndex:(cid-1)];
		NSString* singleLine = [lines objectAtIndex:(cid-1)];
		NSArray* commaSeparated = [singleLine componentsSeparatedByString:@","];
		return [commaSeparated objectAtIndex:0];
	}
	LOG_CURRENT_METHOD;
	NSLog(@"productId not found. cid=%d", cid);
	NSLog(@"lines=%@", [lines description]);
	return @"";
}
+ (ContentId)getContentIdentifier:(NSString *)pid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	NSArray* lines = [self getAllProductIdentifier];
	int i = 0;
	for (NSString* singleLine in lines) {
		NSArray* commaSeparated = [singleLine componentsSeparatedByString:@","];
		NSString* candidatePid = [commaSeparated objectAtIndex:0];
		if ([candidatePid compare:pid] == NSOrderedSame) {
			return (ContentId)(i + 1);
		}
		i++;
	}
	return InvalidContentId;
}

+ (NSArray*)getAllProductIdentifier
{
	//parse csv file.
	NSString* targetFilename = @"productIdList";
	return [FileUtility parseDefineCsv:targetFilename];
}

//Check free contents for read without download.
+ (BOOL)isFreeContent:(NSString*)productId
{
	NSArray* lines = [self getAllProductIdentifier];
	for (NSString* singleLine in lines) {
		NSArray* commaSeparated = [singleLine componentsSeparatedByString:@","];
		NSString* candidateProductId = [commaSeparated objectAtIndex:0];
		if ([productId compare:candidateProductId] == NSOrderedSame) {
			if (1 <= [commaSeparated count] && PRODUCT_KIND_FREE == [[commaSeparated objectAtIndex:1] intValue]) {
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
