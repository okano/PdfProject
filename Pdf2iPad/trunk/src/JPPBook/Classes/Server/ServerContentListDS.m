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
}
@end