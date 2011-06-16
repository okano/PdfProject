//
//  FileUtility.m
//  SakuttoBook
//
//  Created by okano on 11/06/12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FileUtility.h"


@implementation FileUtility

#pragma mark - page image cache.
+ (NSString*)getPageFilenameFull:(int)pageNum {
	NSString* filename = [NSString stringWithFormat:@"%@%d", PAGE_FILE_PREFIX, pageNum];
	NSString* targetFilenameFull = [[[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:PAGE_FILE_EXTENSION];
	return targetFilenameFull;
}

+ (NSString*)getPageFilenameFull:(int)pageNum WithContentId:(ContentId)cid {
	LOG_CURRENT_METHOD;
	NSLog(@"pageNum=%d, ContentId=%d", pageNum, cid);
	NSString* filename = [NSString stringWithFormat:@"%@%d", PAGE_FILE_PREFIX, pageNum];
	NSString* targetFilenameFull = [[[[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]
									  stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",cid]]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:PAGE_FILE_EXTENSION];
	NSLog(@"filename=%@", filename);
	NSLog(@"targetFilenameFull=%@", targetFilenameFull);
	return targetFilenameFull;
}

#pragma mark - thumbnail.
+ (NSString*)getThumbnailFilenameFull:(int)pageNum {
	NSString* filename = [NSString stringWithFormat:@"%@%d", THUMBNAIL_FILE_PREFIX, pageNum];
	NSString* targetFilenameFull = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:THUMBNAIL_FILE_EXTENSION];
	return targetFilenameFull;
}

+ (NSString*)getThumbnailFilenameFull:(int)pageNum WithContentId:(ContentId)cid {
	NSString* filename = [NSString stringWithFormat:@"%@%d", THUMBNAIL_FILE_PREFIX, pageNum];
	NSString* targetFilenameFull = [[[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
									  stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",cid]]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:THUMBNAIL_FILE_EXTENSION];
	return targetFilenameFull;
}


#pragma mark - like POSIX file uty.
//@see:http://www.saturn.dti.ne.jp/~npaka/iphone/util/index.html
/*
//Get file list.
+ (NSArray*)fileNames:(NSString*)fileName {
    NSString* path=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	path=[path stringByAppendingPathComponent:fileName]; 
	return [[NSFileManager defaultManager] directoryContentsAtPath:path];
}
*/

//Check file/directory exist.
+ (BOOL)existsFile:(NSString*)fileNameFull {
	return [[NSFileManager defaultManager] fileExistsAtPath:fileNameFull];
}

//Generate Directory.
+ (void)makeDir:(NSString*)fileNameFull {
	NSLog(@"fileNameFull=%@", fileNameFull);
    if ([self existsFile:fileNameFull]) {
		return;
	}
	[[NSFileManager defaultManager] createDirectoryAtPath:fileNameFull
							  withIntermediateDirectories:YES
											   attributes:nil 
													error:nil];
}

//Delete file/directory.
+ (void)removeFile:(NSString*)fileNameFull {
    if (![self existsFile:fileNameFull]) {
		return;
	}
    [[NSFileManager defaultManager] removeItemAtPath:fileNameFull error:nil];
}


@end
