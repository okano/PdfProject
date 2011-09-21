//
//  ContentUrlUtility.m
//  DowntownTokyo
//
//  Created by okano on 09/10/20.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ContentUrlUtility.h"


@implementation ContentUrlUtility

+ (NSString*)getContentBodyDirUrl
{
	NSString* urlStr = [[NSString stringWithString:URL_BASE_CONTENT]
						stringByAppendingPathComponent:BODY_DIR];
	return urlStr;
}

+ (NSString*)getContentBodyUrl:(NSString*)cId
{
	NSString* urlStr = [[[self getContentBodyDirUrl]
						 stringByAppendingPathComponent:cId]
						stringByAppendingString:@".zip"];
	return urlStr;
}

+ (NSString*)getContentMetadataDirUrl
{
	NSString* urlStr = [[NSString stringWithString:URL_BASE_CONTENT]
						stringByAppendingPathComponent:DETAIL_DIR];
	return urlStr;
}

+ (NSString*)getContentDetailUrl:(NSString*)cId
{
	NSString* urlStr = [[[[self getContentMetadataDirUrl]
						  stringByAppendingPathComponent:cId]
						 stringByAppendingPathComponent:cId]
						stringByAppendingString:@".xml"];
	return urlStr;
}



/**
 *Thumbnail image URL.
 */
+ (NSString*)getContentThumbnailUrl:(NSString*)cId
{
	NSString* detailUrl = [self getContentDetailUrl:cId];
	return [[[[NSString stringWithString:detailUrl]
			  stringByAppendingPathComponent:cId]
			 stringByAppendingPathComponent:cId]
			stringByAppendingString:@".png"];
}

/**
 *Preview image URL.
 */
+ (NSString*)getContentPreviewUrl:(NSString*)cId
					   withNumber:(NSUInteger)num
{
	NSString* detailUrl = [self getContentDetailUrl:cId];
	return [[[[NSString stringWithString:detailUrl]
				stringByAppendingPathComponent:cId]
			   stringByAppendingPathComponent:cId]
			stringByAppendingString:[NSString stringWithFormat:@"-preview%d.jpg", num]];
}

+ (NSString*)getContentPreview1Url:(NSString*)cId {
	return [self getContentPreviewUrl:cId withNumber:1];
}
+ (NSString*)getContentPreview2Url:(NSString*)cId {
	return [self getContentPreviewUrl:cId withNumber:2];
}
+ (NSString*)getContentPreview3Url:(NSString*)cId {
	return [self getContentPreviewUrl:cId withNumber:3];
}
+ (NSString*)getContentPreview4Url:(NSString*)cId {
	return [self getContentPreviewUrl:cId withNumber:4];
}
+ (NSString*)getContentPreview5Url:(NSString*)cId {
	return [self getContentPreviewUrl:cId withNumber:5];
}
+ (NSArray*)getContentPreviewUrlArray:(NSString*)cId {
	NSArray* resultArray = [NSArray arrayWithObjects:
							[self getContentPreview1Url:cId],
							[self getContentPreview2Url:cId],
							[self getContentPreview3Url:cId],
							[self getContentPreview4Url:cId],
							[self getContentPreview5Url:cId],
							nil];
	return resultArray;
}

#pragma mark Comment List.
+ (NSString*)getCommentUrl:(NSString*)cId
{
	NSString* urlStr = [[[[NSString stringWithString:URL_BASE_CMS]
						  stringByAppendingPathComponent:COMMENT_LIST_DIR]
						 stringByAppendingPathComponent:cId]
						stringByAppendingString:@""];	//no-extension for wellcomfort.jp
						//stringByAppendingString:@".xml"];

	return urlStr;
}

+ (NSString*)getCommentPostUrl:(NSString*)cId
{
	NSString* urlStr = [[[[NSString stringWithString:URL_BASE_CMS]
						  stringByAppendingPathComponent:COMMENT_POST_DIR]
						 stringByAppendingPathComponent:cId]
						stringByAppendingString:@""];	//no-extension.
	return urlStr;
}

@end
