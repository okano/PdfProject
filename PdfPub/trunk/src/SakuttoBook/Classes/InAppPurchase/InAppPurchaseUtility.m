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
	if (cid < [lines count]) {
		//return [lines objectAtIndex:(cid-1)];
		NSString* singleLine = [lines objectAtIndex:(cid-1)];
		NSArray* commaSeparated = [singleLine componentsSeparatedByString:@","];
		return [commaSeparated objectAtIndex:0];
	}
	return @"";
}

+ (NSArray*)getAllProductIdentifier
{
	//parse csv file.
	NSString* csvFilePath = [[NSBundle mainBundle] pathForResource:@"productIdList" ofType:@"csv"];
	NSError* error = nil;
	NSString* text = [NSString stringWithContentsOfFile:csvFilePath encoding:NSUTF8StringEncoding error:&error];
	if (error) {
		LOG_CURRENT_METHOD;
		LOG_CURRENT_LINE;
		NSLog(@"error=%@, error code=%d", [error localizedDescription], [error code]);
		if ([error code] == NSFileReadInvalidFileNameError) {
			NSLog(@"Read error because of an invalid file name. (file not exist?)");
		}
		return nil;
	}
	
	NSMutableArray* lines = [[NSMutableArray alloc] initWithArray:[text componentsSeparatedByString:@"\n"]];
	
	//delete comment line.
	for (NSString* line in [lines reverseObjectEnumerator] ) {
		NSLog(@"class=%@, line=%@", [line class], line);
		if ([line length] <= 0) {
			[lines removeObject:line];	//Skip comment line.
			continue;
		}
		if ([line characterAtIndex:0] == '#'
			||
			[line characterAtIndex:0] == ';') {
			[lines removeObject:line];	//Skip comment line.
			continue;
		}
	}
	return lines;
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
