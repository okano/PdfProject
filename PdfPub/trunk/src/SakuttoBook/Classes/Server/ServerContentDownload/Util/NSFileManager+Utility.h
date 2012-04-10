//
//  NSFileManager+Utility.h
//
//  Created by hisaboh on 08/12/07.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSFileManager (Utility)

- (NSString *)suggestFilePath:(NSString *)path;
- (void) clearTmpDirectory;

@end

#define APPLICATION_TMP_DIR	[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]
#define APPLICATION_DOC_DIR	[NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"]
