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
	//LOG_CURRENT_METHOD;
	//NSLog(@"pageNum=%d, ContentId=%d", pageNum, cid);
	NSString* filename = [NSString stringWithFormat:@"%@%d", PAGE_FILE_PREFIX, pageNum];
	NSString* targetFilenameFull = [[[[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]
									  stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",cid]]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:PAGE_FILE_EXTENSION];
	//NSLog(@"filename=%@", filename);
	//NSLog(@"targetFilenameFull=%@", targetFilenameFull);
	return targetFilenameFull;
}


#pragma mark - page image cache(Double pain).
+ (NSString*)getDoublePageFilenameFull:(int)pageNum {
	NSString* filename = [NSString stringWithFormat:@"%@%d-p%d", PAGE_FILE_PREFIX, pageNum, pageNum+1];
	NSString* targetFilenameFull = [[[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:PAGE_FILE_EXTENSION];
	return targetFilenameFull;
}

+ (NSString*)getDoublePageFilenameFull:(int)pageNum WithContentId:(ContentId)cid {
	//LOG_CURRENT_METHOD;
	//NSLog(@"pageNum=%d, ContentId=%d", pageNum, cid);
	NSString* filename = [NSString stringWithFormat:@"%@%d-p%d", PAGE_FILE_PREFIX, pageNum, pageNum+1];
	NSString* targetFilenameFull = [[[[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]
									  stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",cid]]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:PAGE_FILE_EXTENSION];
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

#pragma mark - CSV file parser.
+ (NSArray*)parseDefineCsv:(NSString*)filename
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"filename=%@", filename);
	
	//parse csv file.
	NSString* csvFilePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"csv"];
	if (csvFilePath == nil) {
		LOG_CURRENT_METHOD;
		NSLog(@"csvfile not found. filename=%@.%@", filename, @"csv");
		return nil;
	}
	NSError* error = nil;
	NSString* text = [NSString stringWithContentsOfFile:csvFilePath encoding:NSUTF8StringEncoding error:&error];
	if (error != nil) {
		NSLog(@"Error:%@", [error localizedDescription]);
		return nil;
	}
	
	//Replace '¥r' to '¥n'
	NSString* text2 = [text stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
	NSString* text3 = [text2 stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
	
	//Delete comment line.
	NSMutableArray* lines = [[NSMutableArray alloc] initWithArray:[text3 componentsSeparatedByString:@"\n"]];
	//NSLog(@"lines(count=%d)=%@", [lines count], [lines description]);
	for (NSString* line in [lines reverseObjectEnumerator]) {
		//NSLog(@"line(length=%d)=%@", [line length], [line stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
		if ([line length] <= 0) {
			[lines removeObject:line];	//Skip blank line.
			continue;
		}
		if ([line characterAtIndex:0] == '#'
			||
			[line characterAtIndex:0] == ';') {
			[lines removeObject:line];	//Skip comment line.
			continue;
		}
	}
	
	return lines;
}

+ (NSArray*)parseDefineCsv:(NSString*)filename contentId:(ContentId)cid 
{
	NSString* filenameWithCid = [NSString stringWithFormat:@"%@_%d", filename, cid];
	return [self parseDefineCsv:filenameWithCid];
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
	//NSLog(@"fileNameFull=%@", fileNameFull);
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
