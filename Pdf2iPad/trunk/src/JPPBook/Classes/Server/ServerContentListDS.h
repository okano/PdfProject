//
//  ServerContentListDS.h
//  JPPBook
//
//  Created by okano on 11/08/17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentListDS.h"
#import "InAppPurchaseDefine.h"
#import "InAppPurchaseUtility.h"
#import "FileUtility.h"
#import "UrlDefine.h"

@interface ServerContentListDS : ContentListDS {
}

#pragma mark -
- (void)loadContentList:(NSUInteger)maxCount delegate:(id)delegate;
- (NSArray*)loadContentListFromPlist;
- (NSArray*)loadContentListFromNetwork;
- (void)storeContentListToPlist:(NSMutableArray*)pListArray;
#pragma mark -
- (NSString*)getContentListDirectoryname;
- (NSString*)getContentListFilename;

@end



//
#define PFILE_LAST_UPDATE	@"LastUpdate"
#define PFILE_CONTENT_SUMMARY_ARRAY @"ContentSummaryArray"	/* tag name in *.pfile */
//
#define ITEM_CONTENT_ID		@"ContentId"
//Basic Infomation.
#define ITEM_TITLE			@"Title"
#define ITEM_ARTIST			@"Artist"
#define ITEM_THUMBNAIL_URL	@"ThumbnailUrl"
#define ITEM_THUMBNAIL_DATA	@"ThumbnailData"	//[NSData dataWithContentsOfURL:url]
// for content Detail.
#define ITEM_DESCRIPTION	@"Description"
#define ITEM_PREVIEW_URL_1	@"PreviewUrl1"
#define ITEM_PREVIEW_URL_2	@"PreviewUrl2"
#define ITEM_PREVIEW_URL_3	@"PreviewUrl3"
#define ITEM_PREVIEW_URL_4	@"PreviewUrl4"
#define ITEM_PREVIEW_URL_5	@"PreviewUrl5"
//
#define SUMMARY_TYPE_NEWEST		@"Newest"
#define SUMMARY_TYPE_FAVORITE	@"Favorite"
#define SUMMARY_TYPE_SEARCH		@"Search"

