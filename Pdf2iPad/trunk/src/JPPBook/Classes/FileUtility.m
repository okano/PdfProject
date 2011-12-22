//
//  FileUtility.m
//  SakuttoBook
//
//  Created by okano on 11/06/12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FileUtility.h"


@implementation FileUtility

#pragma mark - PDF original file.
//Pdf(Original) file.
+ (NSString*)getPdfFilename
{
	NSString* targetFilename = CSVFILE_PDFDEFINE;
	NSArray* lines;
	lines = [FileUtility parseDefineCsv:targetFilename];
	
	NSString* pdfFilename;
	if ([lines count] < 1) {
		NSLog(@"no PDF file specified in %@.%@", targetFilename, @"csv");
		pdfFilename = [NSString stringWithFormat:TEST_PDF_FILENAME];
	} else {
		pdfFilename = [lines objectAtIndex:0];
	}
	return pdfFilename;
}
+ (NSString*)getPdfFilename:(ContentId)cId
{
	NSString* targetFilename = CSVFILE_PDFDEFINE;
	NSArray* lines;
	lines = [FileUtility parseDefineCsv:targetFilename contentId:cId];
	
	NSString* pdfFilename;
	if ([lines count] < 1) {
		NSLog(@"no PDF file specified in %@.%@", targetFilename, @"csv");
		pdfFilename = [NSString stringWithFormat:TEST_PDF_FILENAME];
	} else {
		pdfFilename = [lines objectAtIndex:0];
	}
	return pdfFilename;
}

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
	NSString* targetFilenameFull = [[[[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
									   stringByAppendingPathComponent:DETAIL_DIR]
									  stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",cid]]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:THUMBNAIL_FILE_EXTENSION];
	return targetFilenameFull;
}

#pragma mark - CSV file parser.
//only from MainBundle.
+ (NSArray*)parseDefineCsv:(NSString*)filename
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"filename=%@", filename);
	
	//parse csv file.
	NSString* csvFilePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"csv"];
	if (csvFilePath == nil) {
		//LOG_CURRENT_METHOD;
		//NSLog(@"csvfile not found in mainBundle. filename=%@.%@", filename, @"csv");
		return nil;
	}
	
	return [self parseDefineCsvWithFullFilename:csvFilePath];
}


+ (NSArray*)parseDefineCsvWithFullFilename:(NSString*)filenameFull
{
	NSError* error = nil;
	NSString* text = [NSString stringWithContentsOfFile:filenameFull encoding:NSUTF8StringEncoding error:&error];
	if (error != nil) {
		NSLog(@"Error:%@", [error localizedDescription]);
		return nil;
	}
	return [self parseDefineCsvFromString:text];
}

+ (NSArray*)parseDefineCsvFromString:(NSString*)text
{
	//Replace '¥r' to '¥n'
	NSString* text2 = [text stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
	NSString* text3 = [text2 stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
	
	//Delete comment line.
	NSMutableArray* lines = [[NSMutableArray alloc] initWithArray:[text3 componentsSeparatedByString:@"\n"]];
	if ([lines count] <= 0) {
		LOG_CURRENT_METHOD;
		NSLog(@"no line found.");
		return lines;
	}
	//NSLog(@"lines(count=%d)=%@", [lines count], [lines description]);
	NSMutableArray* resultArray = [[NSMutableArray alloc] init];
	//for (NSString* line in [lines reverseObjectEnumerator]) {
	for (NSString* line in [lines objectEnumerator]) {
		//NSLog(@"line(length=%d)=%@", [line length], [line stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
		if ([line length] <= 0) {
			//[lines removeObject:line];	//Skip blank line.
			continue;
		}
		if ([line characterAtIndex:0] == '#'
			||
			[line characterAtIndex:0] == ';') {
			//[lines removeObject:line];	//Skip comment line.
			continue;
		}
		[resultArray addObject:line];
	}
	
	return resultArray;
}

+ (NSArray*)parseDefineCsv:(NSString*)filename contentId:(ContentId)cid 
{
	//NSString* filenameWithCid = [NSString stringWithFormat:@"%@_%d", filename, cid];
	//return [self parseDefineCsv:filenameWithCid];


	//Open CSV file from (1)ContentBody Directory (2)mainBundle
	NSString* csvFilePath1 = [self getCsvFilenameInFolder:filename contentId:cid];
	if ([self existsFile:csvFilePath1] == YES) {
		//(1)get from ContentBody Directory.
		return [self parseDefineCsvWithFullFilename:csvFilePath1];
	} else {
		//NSLog(@"csv file not found in ContentBody directory. file=%@", csvFilePath1);
	}
	
	//(2)get from mainBundle
	//NSString* filenameWithCid = [NSString stringWithFormat:@"%@_%d", filename, cid];
	NSString* filenameWithCid = [self getCsvFilenameInMainBundle:filename contentId:cid];
	return [self parseDefineCsv:filenameWithCid];
}

#pragma mark CSV filename utility.
+ (NSString*)getCsvFilenameInFolder:(NSString*)filename contentId:(ContentId)cid
{
	NSString* cidStr = [NSString stringWithFormat:@"%d", cid];
	NSString* csvFilePath1 = [[[[ContentFileUtility getContentBodyDirectoryWithContentId:cidStr]
								stringByAppendingPathComponent:@"csv"]
							   stringByAppendingPathComponent:filename]
							  stringByAppendingPathExtension:@"csv"];
	return csvFilePath1;
}
+ (NSString*)getCsvFilenameInMainBundle:(NSString*)filename contentId:(ContentId)cid
{
	NSString* filenameWithCid = [NSString stringWithFormat:@"%@_%d", filename, cid];
	return filenameWithCid;
}


#pragma mark - like POSIX file uty.
//@see:http://www.saturn.dti.ne.jp/~npaka/iphone/util/index.html
//Get file list.
//+ (NSArray*)fileNames:(NSString*)fileName {
+ (NSArray*)fileList:(NSString*)path {
	NSError* error = nil;
	return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error];
}

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

//Resource to File.
+ (BOOL)res2file:(NSString*)res fileNameFull:(NSString*)filenameFull {
    NSString* from=[[NSBundle mainBundle] pathForResource:res ofType:@""];
    NSString* to=filenameFull;
	if (from == nil || to == nil) {
		//resource or file not found.
		return NO;
	}
    [[NSFileManager defaultManager] copyItemAtPath:from toPath:to error:nil];
    return YES;
}

#pragma mark -
+ (NSString*)cleanString:(NSString*)str
{
	NSString* tmpStrWithoutDoubleQuote = [str stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x22]
																		withString:@""];	/* delete DoubleQuote. */
	NSString* tmpStrWithoutCR = [tmpStrWithoutDoubleQuote stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x0d]
																					withString:@""];	/* delete CR. */
	NSString* tmpStrWithoutLF = [tmpStrWithoutCR stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x22]
																		   withString:@""];	/* delete LF. */
	return tmpStrWithoutLF;
}

@end
