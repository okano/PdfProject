//
//  ContentFileUtility.h
//  DowntownTokyo
//
//  Created by okano on 09/10/08.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define EPUB_RESOURCES_DIRECTORY	@"content/resources"
#define CONTENT_DETAIL_DIRECTORY	@"contentDetail"
#define CONTENT_BODY_DIRECTORY		@"contentBody"
#define CONTENT_TMP_DIRECTORY		@"tmp"

@interface ContentFileUtility : NSObject {
}

//Filename utility.
+ (NSString*)getContentDetailDirectoryWithContentId:(NSString*)cId;
+ (NSString*)getContentDetailFilename:(NSString*)cId;
+ (NSString*)getContentBodyDirectory;
//+ (NSString*)getContentBodyDirectoryWithContentId:(NSString*)cId;
+ (NSString*)getContentBodyFilename:(NSString*)targetContentId;
+ (NSString*)getContentTmpDirectory;
+ (NSString*)getContentTmpDirectoryWithContentId:(NSString*)cId;
+ (NSString*)getContentTmpDirectoryHasResourcesWithContentId:(NSString*)cId;
//thumbnail image.
+ (NSString*)getThumbnailIconFilenameWithContentId:(NSString*)cId;
//preview image.
//+ (NSString*)getPreviewImage1FilenameWithContentId:(NSString*)cId;

@end
