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

- (NSString*)productIdFromContentId:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	if (cid == 0) {
		return @"storeProductId-00";
	} else 	if (cid == 1) {
		return @"storeProductId-01";
	} else 	if (cid == 2) {
		return @"storeProductId-02";
	} else 	if (cid == 3) {
		return @"storeProductId-03";
	} else {
		return @"storeProductId-04";
	}
}

#pragma mark - setup data.
- (void)setupData
{
#if defined(IS_MULTI_CONTENTS) && IS_MULTI_CONTENTS != 0
	
	//Foreach contentId.
	int contentIdInt = 0;
	while (0==0) {
		//Open define file.
		NSString* csvFilename = [InAppPurchaseUtility getBookDefineFilename:contentIdInt];
		NSString* csvFilePath = [[NSBundle mainBundle] pathForResource:csvFilename ofType:@"csv"];
		if (! csvFilePath) {
			break;
		}
		NSLog(@"csvFilename=%@", csvFilename);
		NSLog(@"csvFilePath=%@", csvFilePath);
		NSError* error = nil;
		NSString* text = [NSString stringWithContentsOfFile:csvFilePath encoding:NSUTF8StringEncoding error:&error];
		if (error) {
			NSLog(@"book define file not found. filename=%@", [csvFilePath lastPathComponent]);
			NSLog(@"error=%@, error code=%d", [error localizedDescription], [error code]);
			break;
		}
		if (! text) { LOG_CURRENT_LINE; }
		
		//Read book define.
		NSArray* lines = [text componentsSeparatedByString:@"\n"];
		//NSArray* lines = [[text stringByAppendingString:@"\n"] componentsSeparatedByString:@"\n"];
		if ([lines count] <= 0) {
			continue;	//skip to next file.
		}
		
		//set book infomation to inner var.
		NSMutableDictionary* tmpDict;
		tmpDict = [[NSMutableDictionary alloc] init];
		[tmpDict setValue:[NSNumber numberWithInteger:contentIdInt] forKey:CONTENT_CID];
		[tmpDict setValue:[self productIdFromContentId:contentIdInt] forKey:CONTENT_STORE_PRODUCT_ID];
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
		if (5 <= [lines count]) {	//[FIXME]enable multi-line.
			[tmpDict setValue:[lines objectAtIndex:4] forKey:CONTENT_DESCRIPTION];
		}
		[contentList addObject:tmpDict];
		
		contentIdInt++;
	}//end-while.
#else
	[self setupTestData];
#endif
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

#pragma mark Thumbnail Image
- (UIImage*)contentIconAtIndex:(NSInteger)index
{
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
}
- (UIImage*)contentIconByContentId:(ContentId)cid
{
	NSString* filename = [NSString stringWithFormat:@"%@%d.%@",
						   CONTENT_ICONFILE_PREFIX,
						   (cid + 1),
						   CONTENT_ICONFILE_EXTENSION];
	//NSLog
	NSLog(@"filename=%@", filename);
	
	// Open image from mainBundle.
	UIImage* image = [UIImage imageNamed:filename];
	return image;
}

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

#pragma mark - Payment Infomation Check.
- (NSUInteger)checkPaymentStatusByContentId:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	if (cid == 0) {
		return PAYMENT_STATUS_PAYED;
	} else 	if (cid == 1) {
		return PAYMENT_STATUS_PAYED;
	} else 	if (cid == 2) {
		return PAYMENT_STATUS_NOT_PAYED;
	} else 	if (cid == 3) {
		return PAYMENT_STATUS_NOT_PAYED;
	} else {
		return PAYMENT_STATUS_PAYED;
	}
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
