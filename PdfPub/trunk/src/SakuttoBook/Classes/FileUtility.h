//
//  FileUtility.h
//  SakuttoBook
//
//  Created by okano on 11/06/12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"
#import "ContentFileUtility.h"
#import "Define.h"
#import "InAppPurchaseDefine.h"
#import <sys/utsname.h>		//get the device model number using uname.

@interface FileUtility : NSObject {
    
}
//Pdf(Original) file.
+ (NSString*)getPdfFilename;
+ (NSString*)getPdfFilename:(ContentId)cId;
+ (NSString*)getPdfFilenameWithSingleString:(NSString*)line;
#define TEST_PDF_FILENAME	@"document.pdf"

//Each page cache.
+ (NSString*)getPageFilenameFull:(int)pageNum;
+ (NSString*)getPageFilenameFull:(int)pageNum WithContentId:(ContentId)cid;
+ (NSString*)getPageSmallFilenameFull:(int)pageNum;
+ (NSString*)getPageSmallFilenameFull:(int)pageNum WithContentId:(ContentId)cid;

//CSV file parser.
+ (NSArray*)parseDefineCsv:(NSString*)filename;
+ (NSArray*)parseDefineCsvWithFullFilename:(NSString*)filenameFull;
+ (NSArray*)parseDefineCsv:(NSString*)filename contentId:(ContentId)cid;
+ (NSArray*)parseDefineCsvFromString:(NSString*)text;
//CSV filename utility.
+ (NSString*)getCsvFilenameInFolder:(NSString*)filename contentId:(ContentId)cid withDeviceSuffix:(BOOL)isAddSuffix;
+ (NSString*)getCsvFilenameInMainBundle:(NSString*)filename withDeviceSuffix:(BOOL)isAddSuffix;
+ (NSString*)getCsvFilenameInMainBundle:(NSString*)filename contentId:(ContentId)cid withDeviceSuffix:(BOOL)isAddSuffix;;
// CSV file copy.
+ (BOOL)copyCSVFile:(NSString*)filename withContentId:(ContentId)cid skipBackup:(BOOL)isSkipBackup;

#pragma mark - like POSIX file uty.
+ (NSArray*)fileList:(NSString*)path;
+ (BOOL)existsFile:(NSString*)fileNameFull;
+ (BOOL)makeDir:(NSString*)fileNameFull;
+ (void)removeFile:(NSString*)fileNameFull;
+ (BOOL)res2file:(NSString*)res fileNameFull:(NSString*)filenameFull;	//Resource to File.

//Technical Q&A QA1719
//https://developer.apple.com/library/ios/#qa/qa1719/_index.html
//How do I prevent files from being backed up to iCloud and iTunes?
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
+ (BOOL)addSkipBackupAttributeToItemWithString:(NSString*)filenameFull;

//String cleaner
+ (NSString*)cleanString:(NSString*)str;

//get the device model number using uname from sys/utsname.h
+ (NSString*)machineName;
+(BOOL)is_4inch;
+(NSString*)getDeviceSuffixForCsv;
@end

//
#define CSVFILE_PDFDEFINE		@"pdfDefine"
//
#define CSVFILE_URLLINK			@"urlLinkDefine"
//
#define CSVFILE_MOVIE			@"movieDefine"
#define CSVFILE_MAIL			@"mailDefine"
#define CSVFILE_SOUND			@"soundDefine"
#define CSVFILE_PAGEJUMPLINK 	@"pageJumpLinkDefine"
#define CSVFILE_INPAGE_SCROLLVIEW	@"inPageScrollViewDefine"
#define CSVFILE_INPAGE_PDF		@"inPagePdfDefine"
#define CSVFILE_INPAGE_PNG		@"inPagePngDefine"
#define CSVFILE_POPOVER_IMAGE	@"popoverScrollImageDefine"
//
#define CSVFILE_TOC				@"tocDefine"

//
#define SUFFIX_IPHONE			@"_iphone"
#define SUFFIX_IPHONE5			@"_iphone5"
#define SUFFIX_IPAD				@"_ipad"
