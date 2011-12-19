//
//  ContentFileUtility.m
//  DowntownTokyo
//
//  Created by okano on 09/10/08.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ContentFileUtility.h"


@implementation ContentFileUtility


#pragma mark file utility.
/**
 *Content Detail.
 */
+ (NSString*)getContentDetailDirectoryWithContentId:(NSString*)cId
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	NSString* dir = [[documentsDirectory
					  stringByAppendingPathComponent:CONTENT_DETAIL_DIRECTORY]
					 stringByAppendingPathComponent:cId];
	return dir;
}

+ (NSString*)getContentDetailFilename:(NSString*)cId
{
	NSString* dir = [self getContentDetailDirectoryWithContentId:cId];
	return [[dir stringByAppendingPathComponent:cId]
			stringByAppendingPathExtension:@"xml"];
}

/**
 *Content Body.
 */
+ (NSString*)getContentBodyDirectory
{
	//NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	//NSString* documentsDirectory = [paths objectAtIndex:0];
	NSString* tmpDirectory = [self getContentTmpDirectory];
	NSString* dir = [tmpDirectory
					 stringByAppendingPathComponent:CONTENT_BODY_DIRECTORY];
	return dir;
}
+ (NSString*)getContentBodyDirectoryWithContentId:(NSString*)cId
{
	return [[self getContentBodyDirectory]
			stringByAppendingPathComponent:cId];
}
+ (NSString*)getContentBodyPdfDirectoryWithContentId:(NSString*)cId
{
	return [[self getContentBodyDirectoryWithContentId:cId]
			 stringByAppendingPathComponent:@"pdf"];
}

/**
 *
 */
+ (NSString*)getContentBodyFilenamePdf:(NSString*)cId
{
	// generate file name.
	NSString* contentDirectory = [self getContentBodyPdfDirectoryWithContentId:cId];
	NSString* filename = [NSString stringWithFormat:@"%@.pdf", cId];
	NSString* filenameFull = [contentDirectory stringByAppendingPathComponent:filename];
	
	return filenameFull;
}
+ (NSString*)getContentBodyFilenameZip:(NSString*)cId
{
	return [[[self getContentBodyFilenamePdf:cId]
			 stringByDeletingPathExtension]
			stringByAppendingPathComponent:@"zip"];
}
+ (NSString*)getContentBodyImageDirectoryWithContentId:(NSString*)cId
{
	//contentBody/{cId}/image/
	return [[self getContentBodyDirectoryWithContentId:cId]
			stringByAppendingPathComponent:@"image"];
}
+ (NSString*)getContentBodyMovieDirectoryWithContentId:(NSString*)cId
{
	//contentBody/{cId}/movie/
	return [[self getContentBodyDirectoryWithContentId:cId]
			stringByAppendingPathComponent:@"movie"];
}
+ (NSString*)getContentBodySoundDirectoryWithContentId:(NSString*)cId
{
	//contentBody/{cId}/sound/
	return [[self getContentBodyDirectoryWithContentId:cId]
			stringByAppendingPathComponent:@"sound"];
}


#pragma mark - Temporary Directory.
/**
 *Temporary Directory.
 */
+ (NSString*)getContentTmpDirectory
{
	return [NSHomeDirectory() stringByAppendingPathComponent:CONTENT_TMP_DIRECTORY];
}

+ (NSString*)getContentTmpDirectoryWithContentId:(NSString*)cId
{
	NSString* dir = [self getContentTmpDirectory];
	return [dir stringByAppendingPathComponent:cId];
}

+ (NSString*)getContentTmpDirectoryHasResourcesWithContentId:(NSString*)cId
{
	NSString* tmpDir = [self getContentTmpDirectoryWithContentId:cId];
	return [tmpDir stringByAppendingPathComponent:EPUB_RESOURCES_DIRECTORY];
}


#pragma mark - Download/Extract director for zip file.
+ (NSString*)getContentDownloadDirectory
{
	return [[self getContentTmpDirectory]
			stringByAppendingPathComponent:CONTENT_DONWLOAD_DIRECTORY];
}
+ (NSString*)getContentExtractDirectory
{
	return [[self getContentTmpDirectory]
			stringByAppendingPathComponent:CONTENT_EXTRACT_DIRECTORY];
}


#pragma mark - Cover image Directory.
/**
 *Thumbnail Directory.
 */
+ (NSString*)getThumbnailIconFilenameWithContentId:(NSString*)cId
{
	NSString* dir = [self getContentDetailDirectoryWithContentId:cId];
	NSString* filename = [[dir stringByAppendingPathComponent:cId]
						  stringByAppendingPathExtension:@"jpg"];
	return filename;
}

+ (NSString*)getCoverIconDirectory{
	return [NSHomeDirectory() stringByAppendingPathComponent:CONTENT_TMP_DIRECTORY];
}

+ (NSString*)getCoverIconDirectory:(NSString*)cId;
{
	return  [[[self getCoverIconDirectory]
			  stringByAppendingPathComponent:cId]
			 stringByAppendingPathExtension:@"jpg"];
}

+ (UIImage*)getCoverImage:(NSString*)cId
{
	NSString* filenameFull = [self getCoverIconDirectory:cId];
	UIImage* image = [UIImage imageNamed:filenameFull];
	return image;
}


@end
