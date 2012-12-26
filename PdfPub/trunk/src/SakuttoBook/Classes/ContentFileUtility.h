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

#import "InAppPurchaseDefine.h"	//for ContentId.

@interface ContentFileUtility : NSObject {
}

//Filename utility.
+ (NSString*)getContentDetailDirectory;
+ (NSString*)getContentDetailDirectoryWithContentId:(NSString*)cId;
+ (NSString*)getContentDetailFilename:(NSString*)cId;
+ (NSString*)getContentBodyDirectory;								//contentBody/
+ (NSString*)getContentBodyDirectoryWithContentId:(NSString*)cId;	//contentBody/{cId}/
+ (NSString*)getContentBodyPdfDirectoryWithContentId:(NSString*)cId;//contentBody/{cId}/pdf/
+ (NSString*)getContentBodyFilenamePdf:(NSString*)targetContentId;	//contentBody/{cId}/pdf/{cId}.pdf
+ (NSString*)getContentBodyFilenameZip:(NSString*)targetContentId;	//contentBody/{cId}/pdf/{cId}.zip
+ (NSString*)getContentBodyImageDirectoryWithContentId:(NSString*)cId;	//contentBody/{cId}/image/
+ (NSString*)getContentBodyMovieDirectoryWithContentId:(NSString*)cId;	//contentBody/{cId}/movie/
+ (NSString*)getContentBodySoundDirectoryWithContentId:(NSString*)cId;	//contentBody/{cId}/sound/
//
+ (NSString*)getDocumentDirectory;
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

//Other files.
+ (NSString*)getBookDefineFilename;
+ (NSString*)getBookDefineFilename:(ContentId)cid;


@end
