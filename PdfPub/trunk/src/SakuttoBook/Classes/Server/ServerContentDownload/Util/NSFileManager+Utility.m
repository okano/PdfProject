//
//  NSFileManager+Utility.m
//
//  Created by hisaboh on 08/12/07.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSFileManager+Utility.h"


@implementation NSFileManager (Utility)

- (NSString *)suggestFilePath:(NSString *)path {
	if (path == nil) path = @"";
	NSString *parentPath = [path stringByDeletingLastPathComponent];
	NSArray *components = [path pathComponents];
	NSString *nameBody = ([components count] == 0) ? @"" : [components lastObject];
	NSString *ext = [nameBody pathExtension];
	nameBody = [nameBody stringByDeletingPathExtension];
	
	NSString *tmpPath = path;
	int suffix = 0;
	while ([self fileExistsAtPath:tmpPath]) {
		suffix++;
		tmpPath = [parentPath stringByAppendingPathComponent:[nameBody stringByAppendingFormat:@"%d", suffix]];
		if ([ext length] > 0) tmpPath = [tmpPath stringByAppendingPathExtension:ext];
		tmpPath = [tmpPath stringByStandardizingPath];
	}
	return tmpPath;
}

- (void) clearTmpDirectory {
	NSError* err = nil;
	NSArray *contents = [self contentsOfDirectoryAtPath:APPLICATION_TMP_DIR error:&err];
	if(err)
	{
		NSLog(@"error=%@", [err localizedDescription]);
		return;
	}
	
	NSString *path;
	for (path in contents) {
		[self removeItemAtPath:[APPLICATION_TMP_DIR stringByAppendingPathComponent:path] error:nil];
	}
}

@end
