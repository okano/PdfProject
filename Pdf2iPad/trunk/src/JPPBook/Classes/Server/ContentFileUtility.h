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
#define CONTENT_DONWLOAD_DIRECTORY  @"downloads"
#define CONTENT_EXTRACT_DIRECTORY	@"extract"

@interface ContentFileUtility : NSObject {
}

//Filename utility.
+ (NSString*)getContentDetailDirectoryWithContentId:(NSString*)cId;
+ (NSString*)getContentDetailFilename:(NSString*)cId;
+ (NSString*)getContentBodyDirectory;
//+ (NSString*)getContentBodyDirectoryWithContentId:(NSString*)cId;
+ (NSString*)getContentBodyFilename:(NSString*)targetContentId;
//
+ (NSString*)getContentTmpDirectory;
+ (NSString*)getContentTmpDirectoryWithContentId:(NSString*)cId;
+ (NSString*)getContentTmpDirectoryHasResourcesWithContentId:(NSString*)cId;
//
+ (NSString*)getContentDownloadDirectory;
+ (NSString*)getContentExtractDirectory;

//thumbnail image.
+ (NSString*)getThumbnailIconFilenameWithContentId:(NSString*)cId;
//preview image.
//+ (NSString*)getPreviewImage1FilenameWithContentId:(NSString*)cId;

//Cover image
+ (NSString*)getCoverIconDirectory;
+ (NSString*)getCoverIconDirectory:(NSString*)cId;
+ (UIImage*)getCoverImage:(NSString*)cId;



@end
