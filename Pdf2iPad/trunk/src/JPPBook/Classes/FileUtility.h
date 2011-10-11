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

#pragma mark - like POSIX file uty.
+ (NSArray*)fileList:(NSString*)path;
+ (BOOL)existsFile:(NSString*)fileNameFull;
+ (void)makeDir:(NSString*)fileNameFull;
+ (void)removeFile:(NSString*)fileNameFull;
+ (BOOL)res2file:(NSString*)res fileNameFull:(NSString*)filenameFull;	//Resource to File.

@end
