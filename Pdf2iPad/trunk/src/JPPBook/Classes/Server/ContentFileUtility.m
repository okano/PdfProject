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
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	NSString* dir = [documentsDirectory
					 stringByAppendingPathComponent:CONTENT_BODY_DIRECTORY];
	return dir;
}

/*
+ (NSString*)getContentBodyDirectoryWithContentId:(NSString*)cId
{
	NSString* dir = [self getContentBodyDirectory];
	return [dir stringByAppendingPathComponent:cId];
}
*/

/**
 *
 */
+ (NSString*)getContentBodyFilename:(NSString*)cId
{
	// generate file name.
	/*
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	NSString* filename = [NSString stringWithFormat:@"%@.zip", cId];
	NSString* filenameFull = [ [documentsDirectory
								stringByAppendingPathComponent:@"contentBody"]
							  stringByAppendingPathComponent:filename];
	*/
	NSString* contentDirectory = [self getContentBodyDirectory];
	NSString* filename = [NSString stringWithFormat:@"%@.zip", cId];
	NSString* filenameFull = [ contentDirectory stringByAppendingPathComponent:filename];
	
	return filenameFull;
}


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


@end
