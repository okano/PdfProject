//
//  ContentUrlUtility.h
//  DowntownTokyo
//
//  Created by okano on 09/10/20.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UrlDefine.h"

@interface ContentUrlUtility : NSObject {
}

+ (NSString*)getContentBodyDirUrl;
+ (NSString*)getContentBodyUrl:(NSString*)cId;

+ (NSString*)getContentMetadataDirUrl;
//Detail XML URL.
+ (NSString*)getContentDetailUrl:(NSString*)cId;
//Thumbnail image URL.
+ (NSString*)getContentThumbnailUrl:(NSString*)cId;
//Preview image URL.
+ (NSString*)getContentPreviewUrl:(NSString*)cId withNumber:(NSUInteger)num;
+ (NSString*)getContentPreview1Url:(NSString*)cId;
+ (NSString*)getContentPreview2Url:(NSString*)cId;
+ (NSString*)getContentPreview3Url:(NSString*)cId;
+ (NSString*)getContentPreview4Url:(NSString*)cId;
+ (NSString*)getContentPreview5Url:(NSString*)cId;
+ (NSArray*)getContentPreviewUrlArray:(NSString*)cId;

//Comment list.
+ (NSString*)getCommentUrl:(NSString*)cId;
+ (NSString*)getCommentPostUrl:(NSString*)cId;

@end
