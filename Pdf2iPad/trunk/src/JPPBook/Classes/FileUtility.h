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
#import "UrlDefine.h"
#import "InAppPurchaseDefine.h"

@interface FileUtility : NSObject {
    
}
//Pdf(Original) file.
+ (NSString*)getPdfFilename;
+ (NSString*)getPdfFilename:(ContentId)cId;
#define TEST_PDF_FILENAME	@"TestPage.pdf"

//Each page cache.
+ (NSString*)getPageFilenameFull:(int)pageNum;
+ (NSString*)getPageFilenameFull:(int)pageNum WithContentId:(ContentId)cid;
+ (NSString*)getThumbnailFilenameFull:(int)pageNum;
+ (NSString*)getThumbnailFilenameFull:(int)pageNum WithContentId:(ContentId)cid;

//CSV file parser.
+ (NSArray*)parseDefineCsv:(NSString*)filename;
+ (NSArray*)parseDefineCsvWithFullFilename:(NSString*)filenameFull;
+ (NSArray*)parseDefineCsv:(NSString*)filename contentId:(ContentId)cid;
//CSV filename utility.
+ (NSString*)getCsvFilenameInFolder:(NSString*)filename contentId:(ContentId)cid;
+ (NSString*)getCsvFilenameInMainBundle:(NSString*)filename contentId:(ContentId)cid;

#pragma mark - like POSIX file uty.
+ (NSArray*)fileList:(NSString*)path;
+ (BOOL)existsFile:(NSString*)fileNameFull;
+ (void)makeDir:(NSString*)fileNameFull;
+ (void)removeFile:(NSString*)fileNameFull;
+ (BOOL)res2file:(NSString*)res fileNameFull:(NSString*)filenameFull;	//Resource to File.

//String cleaner
+ (NSString*)cleanString:(NSString*)str;
@end

//
#define CSVFILE_PDFDEFINE		@"pdfDefine"
//
#define CSVFILE_URLLINK			@"urlLinkDefine"
//
#define CSVFILE_MOVIE			@"movieDefine"
#define CSVFILE_SOUND			@"soundDefine"
#define CSVFILE_PAGEJUMPLINK 	@"pageJumpLinkDefine"
#define CSVFILE_INPAGE_SCROLLVIEW	@"inPageScrollViewDefine"
#define CSVFILE_INPAGE_PDF		@"inPagePdfDefine"
#define CSVFILE_INPAGE_PNG		@"inPagePngDefine"
#define CSVFILE_POPOVER_IMAGE	@"popoverImageDefine"
//
#define CSVFILE_TOC				@"tocDefine"
