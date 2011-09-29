//
//  CoverUtility.m
//  JPPBook
//
//  Created by okano on 11/09/21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CoverUtility.h"


@implementation CoverUtility

+ (UIImage*)coverImageWithContentId:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	if (cid == InvalidContentId) {
		LOG_CURRENT_METHOD;
		NSLog(@"Invalid ContentId");
		return nil;
	} else if (cid == UndefinedContentId) {
		LOG_CURRENT_METHOD;
		NSLog(@"Undefined ContentId.");
		return nil;
	}
	
	NSString* targetFilenameFull = [FileUtility getThumbnailFilenameFull:1 WithContentId:cid];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:targetFilenameFull]) {
		UIImage* image = [UIImage imageWithContentsOfFile:targetFilenameFull];
		return image;
	}
	else
	{
		//download.
		Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
		NSURL* url = [appDelegate.serverContentListDS thumbnailUrlByContentId:cid];
		NSData* data = [NSData dataWithContentsOfURL:url];
		if (data != nil) {
			//save to local folder.
			[data writeToFile:targetFilenameFull atomically:YES];
			//Generate image.
			UIImage* img = [[UIImage alloc] initWithData:data];
			return img;
		} else {
			NSLog(@"thumbnail image not found. url=%@", [url description]);
		}
		return nil;
	}
}
+ (NSString*)getCoverFilenameFull:(ContentId)cid
{
	return @"";
}


//force download from url.
+ (UIImage*)coverImageWithUuid:(NSString*)uuid
{
	//download.
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSURL* url = [appDelegate.serverContentListDS thumbnailUrlByUuid:uuid];
	NSData* data = [NSData dataWithContentsOfURL:url];
	if (data != nil) {
		//Generate directory for save.
		NSString* targetFilenameFull = [self getCoverCacheFilenameFull:uuid];
		[FileUtility makeDir:[targetFilenameFull stringByDeletingLastPathComponent]];
		//Save to file.
		NSLog(@"targetFilenameFull=%@", targetFilenameFull);
		[data writeToFile:targetFilenameFull atomically:YES];
		
		//Generate image.
		UIImage* img = [[UIImage alloc] initWithData:data];
		return img;
	} else {
		NSLog(@"thumbnail image not found. url=%@", [url description]);
	}
	return nil;
}

+ (NSString*)getCoverLocalFilenameFull:(ContentId)cid
{
	NSString* filename = [NSString stringWithFormat:@"%@%d", COVER_FILE_PREFIX, cid];
	NSString* targetFilenameFull = [[[[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
									   stringByAppendingPathComponent:DETAIL_DIR]
									  stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",cid]]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:COVER_FILE_EXTENSION];
	return targetFilenameFull;
}

+ (NSString*)getCoverCacheFilenameFull:(NSString*)uuid
{
	NSString* targetFilenameFull = [[[[NSHomeDirectory() stringByAppendingPathComponent:@"Tmp"]
									   stringByAppendingPathComponent:COVER_CACHE_DIR]
									 stringByAppendingPathComponent:uuid]
									stringByAppendingPathExtension:COVER_FILE_EXTENSION];
	return targetFilenameFull;
}
										
@end
