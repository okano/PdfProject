//
//  FileUtility.h
//  SakuttoBook
//
//  Created by okano on 11/06/12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"
#import "Define.h"
#import "InAppPurchaseDefine.h"

@interface FileUtility : NSObject {
    
}
+ (NSString*)getPageFilenameFull:(int)pageNum;
+ (NSString*)getPageFilenameFull:(int)pageNum WithContentId:(ContentId)cid;
+ (NSString*)getThumbnailFilenameFull:(int)pageNum;
+ (NSString*)getThumbnailFilenameFull:(int)pageNum WithContentId:(ContentId)cid;

//CSV file parser.
+ (NSArray*)parseDefineCsv:(NSString*)filename;
+ (NSArray*)parseDefineCsv:(NSString*)filename contentId:(ContentId)cid;

#pragma mark - like POSIX file uty.
+ (BOOL)existsFile:(NSString*)fileNameFull;
+ (void)makeDir:(NSString*)fileNameFull;
+ (void)removeFile:(NSString*)fileNameFull;

@end


#define CSVFILE_SOUND			@"soundDefine"
