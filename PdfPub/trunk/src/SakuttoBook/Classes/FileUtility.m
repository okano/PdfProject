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
		NSLog(@"no PDF file specified for cid=%d", cId);
		NSLog(@"内蔵コンテンツ%dのためのPDF定義ファイルが見つかりません。", cId);
		pdfFilename = [NSString stringWithFormat:TEST_PDF_FILENAME];
	} else {
		NSString* line = [lines objectAtIndex:0];
		
		//parse each line.
		NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
		if ([tmpCsvArray count] <= 1) {
			//NSLog(@"no comma found in %@", targetFilename);
			pdfFilename = [tmpCsvArray objectAtIndex:1];
		} else {
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				// iPad
				pdfFilename = [tmpCsvArray objectAtIndex:1];
			} else {
				// iPhone
				pdfFilename = [tmpCsvArray objectAtIndex:0];
			}
		}
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
	NSString* targetFilenameFull = [[[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
									  stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",cid]]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:THUMBNAIL_FILE_EXTENSION];
	return targetFilenameFull;
}


#pragma mark - CSV file parser.
//only from MainBundle. because no ContentId.(single pdf mode)
//
//example: with tocDefine.csv
//(A)tocDefine-ipad.csv / tocDefine-iphone.csv (add suffix "-iad" or "-iphone")
//(B)tocDefine.csv (not suffix)
//
+ (NSArray*)parseDefineCsv:(NSString*)filename
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"filename=%@", filename);
	
	NSString* csvFilePath = nil;
	
	//Find file (A)
	NSString* filenameWithDevice = nil;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// iPad
		filenameWithDevice = [filename stringByAppendingString:@"-ipad"];
	} else {
		// iPhone
		filenameWithDevice = filename;
	}
	csvFilePath = [[NSBundle mainBundle] pathForResource:filenameWithDevice ofType:@"csv"];

	//Find file (B)
	if (csvFilePath == nil) {
		csvFilePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"csv"];
		if (csvFilePath == nil) {
			//LOG_CURRENT_METHOD;
			//NSLog(@"csvfile not found in mainBundle. filename=%@.%@", filename, @"csv");
			return nil;
		}
	}
	
	//Parse csv file.
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
	//LOG_CURRENT_METHOD;
	//NSLog(@"filename=%@, cid=%d", filename, cid);
	
	//Open CSV file from (1)ContentBody Directory (2)mainBundle
	NSString* csvFilePath = nil;
	NSString* filenameInMainBundle = nil;
	
	//(1)get from ContentBody Directory, with suffix.
	//   Ex: ~/tmp/contentBody/1/csv/tocDefine_iphone.csv
	csvFilePath = [self getCsvFilenameInFolder:filename contentId:cid withDeviceSuffix:YES];
	if ([self existsFile:csvFilePath] == NO) {
		//(2)get from ContentBody Directory, without suffix.
		//   Ex: ~/tmp/contentBody/1/csv/tocDefine.csv
		csvFilePath = [self getCsvFilenameInFolder:filename contentId:cid withDeviceSuffix:NO];
		if ([self existsFile:csvFilePath] == NO) {
			//(3)get from mainBundle, with suffix.
			//   Ex: ~/SakuttoBook.app/tocDefine_iphone_1.csv
			filenameInMainBundle = [self getCsvFilenameInMainBundle:filename contentId:cid withDeviceSuffix:YES];
			csvFilePath = [[NSBundle mainBundle] pathForResource:filenameInMainBundle ofType:@""];
			if ((csvFilePath == nil) || [self existsFile:csvFilePath] == NO) {
				//(4)get from mainBundle, without suffix.
				//   Ex: ~/SakuttoBook.app/tocDefine_1.csv
				filenameInMainBundle  = [self getCsvFilenameInMainBundle:filename contentId:cid withDeviceSuffix:NO];
				csvFilePath = [[NSBundle mainBundle] pathForResource:filenameInMainBundle ofType:@""];
				if ((csvFilePath == nil) || [self existsFile:csvFilePath] == NO) {
					LOG_CURRENT_METHOD;
					NSLog(@"csv name=%@, cid=%d", filename, cid);
					NSLog(@"file not found in folder, in mainBundle.");
					return nil;
				}
			}
		}
	}
	//NSLog(@"csvFilePath=%@", csvFilePath);
	
	return [self parseDefineCsvWithFullFilename:csvFilePath];
}

#pragma mark CSV filename utility.
//Ex: ~/tmp/contentBody/1/csv/tocDefine.csv        (without suffix.)
//Ex: ~/tmp/contentBody/1/csv/tocDefine-iphone.csv (with suffix for iphone.)
//Ex: ~/tmp/contentBody/1/csv/tocDefine-ipad.csv   (with suffix for ipad.)
+ (NSString*)getCsvFilenameInFolder:(NSString*)filename contentId:(ContentId)cid withDeviceSuffix:(BOOL)isAddSuffix;
{
	NSString* cidStr = [NSString stringWithFormat:@"%d", cid];
	NSString* csvFilePath1 = nil;
	
	if (isAddSuffix == TRUE) {
		//(A)Add suffix "-iad" or "-iphone".
		//example: with tocDefine.csv
		//         ->tocDefine-ipad.csv / tocDefine-iphone.csv
		NSString* suffix = nil;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			// iPad
			suffix = @"_ipad";
		} else {
			// iPhone
			suffix = @"_iphone";
		}

		csvFilePath1 = [[[[[ContentFileUtility getContentBodyDirectoryWithContentId:cidStr]
						   stringByAppendingPathComponent:@"csv"]
						  stringByAppendingPathComponent:filename]
						 stringByAppendingString:suffix]
						stringByAppendingPathExtension:@"csv"];
	} else {
		//(B)Does not add suffix.
		//example: with tocDefine.csv
		//         ->tocDefine.csv
		csvFilePath1 = [[[[ContentFileUtility getContentBodyDirectoryWithContentId:cidStr]
						  stringByAppendingPathComponent:@"csv"]
						 stringByAppendingPathComponent:filename]
						stringByAppendingPathExtension:@"csv"];

	}
	return csvFilePath1;
}
+ (NSString*)getCsvFilenameInMainBundle:(NSString*)filename contentId:(ContentId)cid withDeviceSuffix:(BOOL)isAddSuffix;
{
	NSString* filenameWithCid = nil;
	if (isAddSuffix == YES) {
		NSString* suffix = nil;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			// iPad
			suffix = @"_ipad";
		} else {
			// iPhone
			suffix = @"_iphone";
		}
		filenameWithCid = [[NSString stringWithFormat:@"%@%@_%d", filename, suffix, cid]
						   stringByAppendingPathExtension:@"csv"];
	} else {
		filenameWithCid = [[NSString stringWithFormat:@"%@_%d", filename, cid]
						   stringByAppendingPathExtension:@"csv"];
	}
	return filenameWithCid;
}



#pragma mark - like POSIX file uty.
//@see:http://www.saturn.dti.ne.jp/~npaka/iphone/util/index.html
//Get file list.
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
