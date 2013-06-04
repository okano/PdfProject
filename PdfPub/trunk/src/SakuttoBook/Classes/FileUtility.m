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
		LOG_CURRENT_METHOD;
		NSLog(@"no PDF file specified in %@.%@", targetFilename, @"csv");
		pdfFilename = [NSString stringWithFormat:TEST_PDF_FILENAME];
	} else {
		pdfFilename = [self getPdfFilenameWithSingleString:[lines objectAtIndex:0]];
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
		LOG_CURRENT_METHOD;
		NSLog(@"no PDF file specified for cid=%d", cId);
		NSLog(@"内蔵コンテンツ%dのためのPDF定義ファイルが見つかりません。", cId);
		pdfFilename = [NSString stringWithFormat:TEST_PDF_FILENAME];
	} else {
		NSString* line = [lines objectAtIndex:0];
		pdfFilename = [self getPdfFilenameWithSingleString:line];
	}
	return pdfFilename;
}
//Ex: document-iphone.pdf,document-ipad.pdf,document-iphone5.pdf
+ (NSString*)getPdfFilenameWithSingleString:(NSString*)line
{
	//parse each line.
	NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
	if ([tmpCsvArray count] <= 1) {
		//NSLog(@"no comma found in %@", targetFilename);
		return [tmpCsvArray objectAtIndex:0];
	} else {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			// iPad
			return [tmpCsvArray objectAtIndex:1];
		} else {
			// iPhone
			if ([self is_4inch] == NO) {
				// iPhone(3.5-inch)
				return [tmpCsvArray objectAtIndex:0];
			} else {
				// iPhone(4-inch)
				if (3 <= [tmpCsvArray count]) {
					return [tmpCsvArray objectAtIndex:2];
				} else {
					return [tmpCsvArray objectAtIndex:0];
				}
			}
		}
	}
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

#pragma mark - Page Cache Mini.
+ (NSString*)getPageSmallFilenameFull:(int)pageNum {
	NSString* filename = [NSString stringWithFormat:@"%@%d", PAGE_FILE_SMALL_PREFIX, pageNum];
	NSString* targetFilenameFull = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:PAGE_FILE_SMALL_EXTENSION];
	return targetFilenameFull;
}

+ (NSString*)getPageSmallFilenameFull:(int)pageNum WithContentId:(ContentId)cid {
	NSString* filename = [NSString stringWithFormat:@"%@%d", PAGE_FILE_SMALL_PREFIX, pageNum];
	NSString* targetFilenameFull = [[[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
									  stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",cid]]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:PAGE_FILE_SMALL_EXTENSION];
	return targetFilenameFull;
}


#pragma mark - CSV file parser.
//only from MainBundle. because no ContentId.(single pdf mode)
//
//example: with tocDefine.csv
//(A)tocDefine-ipad.csv / tocDefine-iphone.csv (add suffix "-ipad" or "-iphone")
//(B)tocDefine.csv (not suffix)
//
+ (NSArray*)parseDefineCsv:(NSString*)filename
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"filename=%@", filename);
	
	NSString* csvFilePath = nil;
	
	//Find file (A-1)filename with suffix.
	NSString* filenameWithDevice = nil;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// iPad
		filenameWithDevice = [filename stringByAppendingString:SUFFIX_IPAD];	//@"_ipad"
	} else {
		// iPhone
		if ([self is_4inch] == YES) {
			filenameWithDevice = [filename stringByAppendingString:SUFFIX_IPHONE];	//@"_iphone"
		} else {
			//(A-1)iPhone5
			filenameWithDevice = [filename stringByAppendingString:SUFFIX_IPHONE5];	//@"_iphone5"
			csvFilePath = [[NSBundle mainBundle] pathForResource:filenameWithDevice ofType:@"csv"];
			if (csvFilePath == nil) {
				//(A-2)use iPhone(3.5-inch) file for iPhone5.
				filenameWithDevice = [filename stringByAppendingString:SUFFIX_IPHONE];	//@"_iphone";
			}
		}
	}
	csvFilePath = [[NSBundle mainBundle] pathForResource:filenameWithDevice ofType:@"csv"];

	//Find file (B)filename without suffix.
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
		NSLog(@"filenameFull=%@", filenameFull);
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
	
	//
	//Multi contents. try with cid.
	//
	//(1)get from ContentBody Directory, with suffix.
	//   Ex: ~/Document/contentBody/1/csv/tocDefine_iphone.csv
	csvFilePath = [self getCsvFilenameInFolder:filename contentId:cid withDeviceSuffix:YES];
	if ([self existsFile:csvFilePath] == NO) {
		//(2)get from ContentBody Directory, without suffix.
		//   Ex: ~/Document/contentBody/1/csv/tocDefine.csv
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
					//No file found.
					//NSLog(@"csv name=%@, cid=%d", filename, cid);
					//NSLog(@"file not found in folder, in mainBundle.");
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
//Ex: ~/tmp/contentBody/1/csv/tocDefine-iphone5.csv (with suffix for iphone5.)
+ (NSString*)getCsvFilenameInFolder:(NSString*)filename contentId:(ContentId)cid withDeviceSuffix:(BOOL)isAddSuffix;
{
	NSString* cidStr = [NSString stringWithFormat:@"%d", cid];
	NSString* csvFilePath1 = nil;
	
	if (isAddSuffix == TRUE) {
		//(A)Add suffix "_ipad" or "_iphone".
		//example: with tocDefine.csv
		//         ->tocDefine_ipad.csv / tocDefine_iphone.csv
		NSString* suffix = [NSString stringWithString:[self getDeviceSuffixForCsv]];

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
+ (NSString*)getCsvFilenameInMainBundle:(NSString*)filename withDeviceSuffix:(BOOL)isAddSuffix
{
	NSString* filenameWithoutCid = nil;
	if (isAddSuffix == YES) {
		NSString* suffix = [NSString stringWithString:[self getDeviceSuffixForCsv]];
		filenameWithoutCid = [[NSString stringWithFormat:@"%@%@", filename, suffix]
						   stringByAppendingPathExtension:@"csv"];
	} else {
		filenameWithoutCid = [[NSString stringWithFormat:@"%@", filename]
						   stringByAppendingPathExtension:@"csv"];
	}
	return filenameWithoutCid;
}
+ (NSString*)getCsvFilenameInMainBundle:(NSString*)filename contentId:(ContentId)cid withDeviceSuffix:(BOOL)isAddSuffix;
{
	NSString* filenameWithCid = nil;
	if (isAddSuffix == YES) {
		NSString* suffix = [NSString stringWithString:[self getDeviceSuffixForCsv]];
		filenameWithCid = [[NSString stringWithFormat:@"%@%@_%d", filename, suffix, cid]
						   stringByAppendingPathExtension:@"csv"];
	} else {
		filenameWithCid = [[NSString stringWithFormat:@"%@_%d", filename, cid]
						   stringByAppendingPathExtension:@"csv"];
	}
	return filenameWithCid;
}
#pragma mark CSV file copy.
+ (BOOL)copyCSVFile:(NSString*)filename withContentId:(ContentId)cid skipBackup:(BOOL)isSkipBackup
{
	NSString* resourceName;
	NSString* toFilenameFull;
	BOOL resultBool;
	
	//Copy CSV file.
	//(1)with device suffix.
#if defined(IS_MULTI_CONTENTS) && IS_MULTI_CONTENTS != 0
	//Multi contents.
	resourceName = [FileUtility getCsvFilenameInMainBundle:filename contentId:cid withDeviceSuffix:YES];
	toFilenameFull = [FileUtility getCsvFilenameInFolder:filename contentId:cid withDeviceSuffix:YES];
#else
	//Single content.
	resourceName = [FileUtility getCsvFilenameInMainBundle:filename withDeviceSuffix:YES];
	toFilenameFull = [FileUtility getCsvFilenameInFolder:filename contentId:CID_FOR_SINGLE_CONTENT withDeviceSuffix:YES];
#endif
	if ([FileUtility existsFile:[[NSBundle mainBundle] pathForResource:resourceName ofType:@""]] == NO) {
		//(2)without device suffix.
#if defined(IS_MULTI_CONTENTS) && IS_MULTI_CONTENTS != 0
		//Multi contents.
		resourceName = [FileUtility getCsvFilenameInMainBundle:filename contentId:cid withDeviceSuffix:NO];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:filename contentId:cid withDeviceSuffix:NO];
#else
		//Single content
		resourceName = [FileUtility getCsvFilenameInMainBundle:filename withDeviceSuffix:NO];
		toFilenameFull = [FileUtility getCsvFilenameInFolder:filename contentId:CID_FOR_SINGLE_CONTENT withDeviceSuffix:NO];
#endif
	}
	//NSLog(@"resourceName=%@, toFilenameFull=%@", resourceName, toFilenameFull);
	resultBool = [FileUtility res2file:resourceName fileNameFull:toFilenameFull];
	
	//Set Ignore Backup.
	if (isSkipBackup == YES) {
		[FileUtility addSkipBackupAttributeToItemWithString:toFilenameFull];
	}
	
	return resultBool;
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
+ (BOOL)makeDir:(NSString*)fileNameFull {
	//NSLog(@"fileNameFull=%@", fileNameFull);
    if ([self existsFile:fileNameFull]) {
		//NSLog(@"directory already exists at %@", fileNameFull);
		return FALSE;
	}
	
	NSError *error = nil;
	[[NSFileManager defaultManager] createDirectoryAtPath:fileNameFull
							  withIntermediateDirectories:YES
											   attributes:nil 
													error:&error];
	if (error != nil) {
		LOG_CURRENT_METHOD;
		NSLog(@"makeDir error. localizedDescription=%@, localizedFailureReason=%@, code=%d",
			  [error localizedDescription],
			  [error localizedFailureReason], [error code]);
		if ([error code] == NSFileWriteFileExistsError) {
			NSLog(@"NSFileWriteFileExistsError. file or directory already exists.");
		}
		return NO;
	}
    return YES;
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
	if (from == nil) {
		//resource file not found in mainBundle.
		//LOG_CURRENT_METHOD;
		//NSLog(@"copy from file not found in mainBundle. filenameFull=%@", filenameFull);
		return NO;
	}
    NSString* to=filenameFull;
	if (to == nil) {
		//passed nil string.(program error.)
		LOG_CURRENT_METHOD;
		NSLog(@"filenameFull is nil.");
		return NO;
	}
	
	NSError *error = nil;
    [[NSFileManager defaultManager] copyItemAtPath:from toPath:to error:&error];
	if (error != nil) {
		LOG_CURRENT_METHOD;
		NSLog(@"file copy error. localizedDescription=%@, localizedFailureReason=%@, code=%d",
			  [error localizedDescription],
			  [error localizedFailureReason], [error code]);
		if ([error code] == NSFileWriteFileExistsError) {
			NSLog(@"(NSFileWriteFileExistsError. file already exists.)");
		}
		return NO;
	}
    return YES;
}


//Technical Q&A QA1719
//https://developer.apple.com/library/ios/#qa/qa1719/_index.html
//How do I prevent files from being backed up to iCloud and iTunes?
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
	if ((URL==nil) || (![[NSFileManager defaultManager] fileExistsAtPath: [URL path]]) ) {
		//NSLog(@"%@ not found. do not ignore backup.",[URL description]);
		return NO;
	}
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
	
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}
+ (BOOL)addSkipBackupAttributeToItemWithString:(NSString *)filenameFull
{
	NSURL* ignoreBackupUrl = [NSURL fileURLWithPath:filenameFull];
	return [self addSkipBackupAttributeToItemAtURL:ignoreBackupUrl];
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

#pragma mark - get the device model number using uname from sys/utsname.h
//get the device model number using uname from sys/utsname.h
//@see: http://stackoverflow.com/questions/11197509/ios-iphone-get-device-model-and-make
/**
 * @"i386"      on the simulator
 * @"iPod1,1"   on iPod Touch
 * @"iPod2,1"   on iPod Touch Second Generation
 * @"iPod3,1"   on iPod Touch Third Generation
 * @"iPod4,1"   on iPod Touch Fourth Generation
 * @"iPhone1,1" on iPhone
 * @"iPhone1,2" on iPhone 3G
 * @"iPhone2,1" on iPhone 3GS
 * @"iPad1,1"   on iPad
 * @"iPad2,1"   on iPad 2
 * @"iPad3,1"   on 3rd Generation iPad
 * @"iPhone3,1" on iPhone 4
 * @"iPhone4,1" on iPhone 4S
 * @"iPhone5,1" on iPhone 5
 * @"iPad3,4" on 4th Generation iPad
 * @"iPad2,5" on iPad Mini
 */
+ (NSString*)machineName
{
    struct utsname systemInfo;
    uname(&systemInfo);
	
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

+(BOOL)is_4inch
{
	CGSize screenSize = [[UIScreen mainScreen] bounds].size;
	if ((screenSize.width == 320.0f) && (screenSize.height == 568.0f)) {
		return YES;	//4-inch.
	} else {
		return NO;	//3.5-inch or iPad.
	}
}

+(NSString*)getDeviceSuffixForCsv
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// iPad
		return SUFFIX_IPAD;			//@"_ipad";
	} else {
		// iPhone
		if ([self is_4inch] == YES) {
			return SUFFIX_IPHONE5;	//@"_iphone5";
		} else {
			return SUFFIX_IPHONE;	//@"_iphone";
		}
	}
}

@end
